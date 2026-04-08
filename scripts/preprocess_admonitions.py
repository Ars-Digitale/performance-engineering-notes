#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import NamedTuple

HEADER_RE = re.compile(r'^([ \t]*)!!![ \t]+([A-Za-z0-9_-]+)(?:[ \t]+"([^"]+)")?[ \t]*$')
HEADER_ANCHOR_PATTERN = re.compile(r'^<a id="([^"]+)"></a>\s*(#{1,6})\s*(.*)')
ANCHOR_ONLY_PATTERN = re.compile(r'^<a id="([^"]+)"></a>\s*$')
MD_LINK_PATTERN = re.compile(
    r'(\[[^\]]+\]\()'
    r'((?![a-zA-Z][a-zA-Z0-9+.-]*:)[^)#]+?)'
    r'\.md'
    r'(?:#[^)]+)?'
    r'(\))'
)

class HeaderMatch(NamedTuple):
    indent: str
    admonition_type: str
    title: str | None

def match_admonition_header(line: str) -> HeaderMatch | None:
    m = HEADER_RE.match(line)
    if not m:
        return None
    indent, admonition_type, title = m.groups()
    return HeaderMatch(indent, admonition_type.lower(), title)

def chapter_slug_from_md_path(path_without_ext: str) -> str:
    normalized = path_without_ext.replace('\\', '/')
    return normalized.split('/')[-1].strip()

def rewrite_md_links(line: str) -> str:
    def repl(match: re.Match[str]) -> str:
        prefix, path_without_ext, suffix = match.groups()
        slug = chapter_slug_from_md_path(path_without_ext)
        return f"{prefix}#chap-{slug}{suffix}"
    return MD_LINK_PATTERN.sub(repl, line)

def indent_width(line: str) -> int:
    width = 0
    for ch in line:
        if ch == ' ': width += 1
        elif ch == '\t': width += 4
        else: break
    return width

def is_blank(line: str) -> bool:
    return line.strip() == ''

def trim_blank_edges(lines: list[str]) -> list[str]:
    start, end = 0, len(lines)
    while start < end and is_blank(lines[start]):
        start += 1
    while end > start and is_blank(lines[end-1]):
        end -= 1
    return lines[start:end]

def collect_admonition_body(lines: list[str], start_index: int, base_indent_width: int) -> tuple[list[str], int]:
    body: list[str] = []
    i = start_index
    while i < len(lines):
        line = lines[i]
        if is_blank(line):
            body.append(line)
            i += 1
            continue
        if indent_width(line) > base_indent_width:
            body.append(rewrite_md_links(line))
            i += 1
            continue
        break
    return body, i

def dedent_body(lines: list[str]) -> list[str]:
    nonblank = [line for line in lines if not is_blank(line)]
    if not nonblank:
        return lines[:]
    min_indent = min(indent_width(line) for line in nonblank)
    dedented: list[str] = []
    for line in lines:
        if is_blank(line):
            dedented.append('')
            continue
        to_remove = min_indent
        pos = 0
        width = 0
        while pos < len(line) and width < to_remove:
            if line[pos] == ' ': width += 1
            elif line[pos] == '\t': width += 4
            else: break
            pos += 1
        dedented.append(line[pos:])
    return dedented

def default_title_from_type(admonition_type: str) -> str:
    parts = admonition_type.replace('-', ' ').replace('_', ' ').split()
    return ' '.join(p.capitalize() for p in parts) if parts else 'Note'

def convert_admonition_block(header: HeaderMatch, body_lines: list[str]) -> list[str]:
    title = header.title if header.title else default_title_from_type(header.admonition_type)
    dedented = dedent_body(trim_blank_edges(body_lines))
    return [f'::: {{.admonition .{header.admonition_type}}}', f'**{title}**', '', *dedented, ':::']

def normalize_anchor_heading_pair(line: str, next_line: str | None) -> tuple[str | None, bool]:
    m = HEADER_ANCHOR_PATTERN.match(line)
    if m:
        anchor, hashes, title = m.groups()
        return f"{hashes} {title} {{#{anchor}}}", False
    m = ANCHOR_ONLY_PATTERN.match(line)
    if m and next_line is not None:
        hm = re.match(r'^(#{1,6})\s+(.*)', next_line)
        if hm:
            anchor = m.group(1)
            hashes, title = hm.groups()
            return f"{hashes} {title} {{#{anchor}}}", True
    return None, False

def convert_lines(lines: list[str]) -> list[str]:
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        next_line = lines[i+1] if i+1 < len(lines) else None
        normalized_line, consume_next = normalize_anchor_heading_pair(line, next_line)
        if normalized_line is not None:
            out.append(rewrite_md_links(normalized_line))
            i += 2 if consume_next else 1
            continue
        line = rewrite_md_links(line)
        header = match_admonition_header(line)
        if header is None:
            out.append(line)
            i += 1
            continue
        base_indent = indent_width(header.indent)
        body_lines, next_i = collect_admonition_body(lines, i+1, base_indent)
        trimmed = trim_blank_edges(body_lines)
        if not any(not is_blank(x) for x in trimmed):
            out.append(line)
            i += 1
            continue
        out.extend(convert_admonition_block(header, body_lines))
        i = next_i
    return out

def convert_file(src: Path, dst: Path) -> None:
    text = src.read_text(encoding='utf-8')
    converted = convert_lines(text.splitlines())
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text('\n'.join(converted) + '\n', encoding='utf-8')

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('src_dir')
    parser.add_argument('dst_dir')
    args = parser.parse_args()
    src_dir = Path(args.src_dir)
    dst_dir = Path(args.dst_dir)
    for src in src_dir.rglob('*.md'):
        rel = src.relative_to(src_dir)
        convert_file(src, dst_dir / rel)

if __name__ == '__main__':
    main()
