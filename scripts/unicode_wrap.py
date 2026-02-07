#!/usr/bin/env python3
"""Unicode-aware text wrapper that handles CJK double-width characters."""
import sys
import unicodedata


def char_width(c):
    """Return visual width: 2 for CJK/fullwidth, 1 for others."""
    eaw = unicodedata.east_asian_width(c)
    return 2 if eaw in ('W', 'F') else 1


def wrap_line(line, max_width):
    """Wrap a single line respecting character visual widths."""
    if not line:
        return ['']
    result = []
    current = []
    width = 0
    for ch in line:
        w = char_width(ch)
        if width + w > max_width:
            result.append(''.join(current))
            current = [ch]
            width = w
        else:
            current.append(ch)
            width += w
    if current:
        result.append(''.join(current))
    return result


def main():
    max_width = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    for line in sys.stdin:
        line = line.rstrip('\n')
        for wrapped in wrap_line(line, max_width):
            print(wrapped)


if __name__ == '__main__':
    main()
