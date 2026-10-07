"""Shared by vault-index, vault-lint and vault-graph, so the three can't drift apart."""
import re


def parse_frontmatter(text):
    """Minimal YAML front-matter reader for the shapes this vault uses: scalars, and block
    lists under aliases / tags / sources. Returns None when the note has no front matter."""
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 3)
    if end == -1:
        return None
    fm, key = {}, None
    for raw in text[4:end].split("\n"):
        if not raw.strip():
            continue
        if re.match(r"^\s+-\s", raw) and key:
            # A bare `aliases:` sets "" first; the items that follow turn it into a list.
            if not isinstance(fm.get(key), list):
                fm[key] = []
            fm[key].append(raw.strip()[1:].strip().strip("\"'"))
            continue
        m = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", raw)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        if val in ("", "[]", "~", "null"):
            fm[key] = [] if val == "[]" else ""
        else:
            fm[key] = val.strip("\"'")
    return fm
