#!/usr/bin/env bash
# Tests for vault-unwrap: every construct a note uses, before and after.
set -uo pipefail
U="$(cd "$(dirname "$0")" && pwd)/vault-unwrap"; fail=0
T="$(mktemp -d)"
cat > "$T/in.md" <<'MD'
---
id: x
aliases:
  - A long alias that
type: concept
---

# A heading that stays
on its own line

A paragraph that was
hard-wrapped at some
column.

Line with a hard break  
kept apart.

- a list item that
  wraps under itself
  - a nested item
    that wraps too
- second item
1. numbered item that
   wraps

> [!note] Callout title
> callout body that
> wraps here

> plain quote that
> wraps

| col | col |
| --- | --- |
| a   | b   |

```js
const a = 1
const b = 2
```

Text with a footnote.[^n]

[^n]: footnote one
[^m]: footnote two

<div>
html stays
</div>

> [!example] Code in a callout
> ```js
> const a = 1
> const b = 2
> ```
MD
cat > "$T/want.md" <<'MD'
---
id: x
aliases:
  - A long alias that
type: concept
---

# A heading that stays
on its own line

A paragraph that was hard-wrapped at some column.

Line with a hard break  
kept apart.

- a list item that wraps under itself
  - a nested item that wraps too
- second item
1. numbered item that wraps

> [!note] Callout title
> callout body that wraps here

> plain quote that wraps

| col | col |
| --- | --- |
| a   | b   |

```js
const a = 1
const b = 2
```

Text with a footnote.[^n]

[^n]: footnote one
[^m]: footnote two

<div>
html stays
</div>

> [!example] Code in a callout
> ```js
> const a = 1
> const b = 2
> ```
MD
cp "$T/in.md" "$T/note.md"
"$U" "$T/note.md" >/dev/null
if diff -u "$T/want.md" "$T/note.md"; then echo "ok   every construct unwraps or stays as it should"; else echo "FAIL construct handling"; fail=1; fi
cp "$T/note.md" "$T/once.md"; "$U" "$T/note.md" >/dev/null
cmp -s "$T/once.md" "$T/note.md" && echo "ok   a second run changes nothing" || { echo "FAIL not idempotent"; fail=1; }
cp "$T/in.md" "$T/dry.md"; "$U" --dry-run "$T/dry.md" >/dev/null
cmp -s "$T/in.md" "$T/dry.md" && echo "ok   --dry-run writes nothing" || { echo "FAIL dry-run wrote"; fail=1; }
rm -rf "$T"; exit $fail
