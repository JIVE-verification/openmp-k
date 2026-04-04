#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
"""
from __future__ import print_function
import sys, json, re, argparse
from typing import Any, List, Tuple

INDENT_SPACES = 2
NUMERIC_PATTERN = re.compile(r'^-?(?:0|[1-9][0-9]*)$')

def json_quote(s: str) -> str:
    return json.dumps(s, ensure_ascii=False)

def is_numeric_token(sort: str, tok: str) -> bool:
    return bool(NUMERIC_PATTERN.match(tok))

def is_cell_label(label: str) -> bool:
    return isinstance(label, str) and label.startswith('<') and label.endswith('>')

def normalize_label(label: str) -> str:
    # Strip auto-generated *_*-SYNTAX suffixes commonly seen in front-ends
    return re.sub(r'_[A-Z][A-Z-]*-SYNTAX$', '', label)

def flatten_map(term: Any) -> List[Any]:
    if isinstance(term, dict) and term.get('node') == 'KApply':
        label = term.get('label')
        args = term.get('args', [])
        if label == '_Map_':
            out: List[Any] = []
            for a in args:
                out.extend(flatten_map(a))
            return out
        elif label == '.Map':
            return []
        else:
            return [term]
    return [term]

def flatten_kseq(term: Any) -> List[Any]:
    if not isinstance(term, dict):
        return [term]
    if term.get('node') == 'KSequence':
        items = term.get('items', [])
        flat: List[Any] = []
        for it in items:
            flat.extend(flatten_kseq(it))
        return flat
    return [term]

def flatten_bracket_chain(node: Any) -> Tuple[Any, List[Tuple[Any, Any]]]:
    """Flatten _[_<-_] chain into (base, [(key, val), ...]) with keys in ascending order
    according to inner-to-outer traversal (reverse of the right-nested structure).
    """
    entries: List[Tuple[Any, Any]] = []
    cur = node
    while isinstance(cur, dict) and cur.get('node') == 'KApply' and cur.get('label') == '_[_<-_]':
        prev, k, v = cur.get('args', [None, None, None])
        entries.append((k, v))
        cur = prev
    entries.reverse()  # present inner-most first (often index 0..N)
    base = cur
    return base, entries

def pp_token(t: dict) -> str:
    tok = t.get('token', '')
    sort = t.get('sort', '')
    if isinstance(tok, str) and len(tok) >= 2 and tok[0] == '"' and tok[-1] == '"':
        return tok
    if is_numeric_token(sort, tok):
        return tok
    else:
        return json_quote(tok)

def pp_apply(label: str, args: List[Any], indent: int) -> str:
    # Special: bracket-update chain
    if label == '_[_<-_]' and len(args) == 3:
        base, kvs = flatten_bracket_chain({'node':'KApply','label':label,'args':args})
        base_s = pp(base, indent, inline=True)
        entries = [f"[ {pp(k, indent, inline=True)} <- {pp(v, indent, inline=True)} ]" for (k,v) in kvs]
        return f"{base_s} ( " + " ".join(entries) + " )"
    if label == '_|->_' and len(args) == 2:
        left = pp(args[0], indent, inline=True)
        right = pp(args[1], indent, inline=True)
        return f"{left} |-> {right}"
    if label == '_Map_':
        parts = [pp(a, indent, inline=True) for a in args]
        return "_Map_ ( " + " , ".join(parts) + " )"
    if label in ('.Map', '.List', '.Set', '.TCell') and not args:
        return label
    if label == '_List_':
        parts = [pp(a, indent, inline=True) for a in args]
        return "_List_ ( " + " , ".join(parts) + " )"
    if label == '_Set_':
        parts = [pp(a, indent, inline=True) for a in args]
        return "_Set_ ( " + " , ".join(parts) + " )"
    parts = [pp(a, indent, inline=True) for a in args]
    plabel = normalize_label(label)
    return f"{plabel} ( " + " , ".join(parts) + " )"

def pp_cell(label: str, args: List[Any], indent: int) -> str:
    open_tag = " " * indent + label
    close_tag = " " * indent + label.replace('<','</',1)
    cindent = indent + INDENT_SPACES
    lines: List[str] = [open_tag]
    if not args:
        pass
    else:
        for child in args:
            if isinstance(child, dict) and child.get('node') == 'KApply' and child.get('label') in ('_Map_', '.Map'):
                entries = flatten_map(child)
                if not entries:
                    lines.append(" " * cindent + ".Map")
                else:
                    ein = cindent  # entries align directly under the content indent (matches K pretty)
                    for e in entries:
                        lines.append(" " * ein + pp(e, ein, inline=True))
            else:
                rendered = pp(child, cindent, inline=True if not (isinstance(child, dict) and is_cell_label(child.get('label',''))) else False)
                if '\n' in rendered:
                    lines.append(rendered)
                else:
                    lines.append(" " * cindent + rendered)
    lines.append(close_tag)
    return "\n".join(lines)

def pp(term: Any, indent: int, inline: bool=False) -> str:
    if isinstance(term, dict):
        node = term.get('node')
        if node == 'KToken':
            return pp_token(term)
        if node == 'KSequence':
            items = flatten_kseq(term)
            parts = [pp(it, indent, inline=True) for it in items]
            return " ~> ".join(parts) if parts else ".List"
        if node == 'KApply':
            label = term.get('label', '<?>')
            args = term.get('args', [])
            if is_cell_label(label):
                return pp_cell(label, args, indent)
            else:
                return pp_apply(label, args, indent)
        return str(term)
    elif isinstance(term, list):
        parts = [pp(x, indent, inline=True) for x in term]
        return "_List_ ( " + " , ".join(parts) + " )"
    else:
        return json_quote(str(term))

def run(in_path: str, out_path: str=None) -> int:
    with open(in_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    term = data.get('term', data)
    out = pp(term, indent=0, inline=True)
    if out_path:
        with open(out_path, 'w', encoding='utf-8', newline='\n') as g:
            g.write(out)
            g.write("\n")
    else:
        sys.stdout.write(out + "\n")
    return 0

def main():
    ap = argparse.ArgumentParser(description="K JSON -> Pretty Printer (mixfix/XML-like)")
    ap.add_argument("input", help="Input JSON file produced by K")
    ap.add_argument("-o", "--output", help="Output file (default: stdout)")
    args = ap.parse_args()
    try:
        return_code = run(args.input, args.output)
    except Exception as e:
        sys.stderr.write("ERROR: %s\n" % (str(e)))
        return_code = 2
    sys.exit(return_code)

if __name__ == "__main__":
    main()
