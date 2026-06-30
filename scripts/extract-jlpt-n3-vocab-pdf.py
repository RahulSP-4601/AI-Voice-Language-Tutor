import json
import re
import sys

import pdfplumber


def clean(value):
    if value is None:
        return ""
    return " ".join(str(value).split())


def normalize_japanese(value):
    return re.sub(r"^(が|を|に|へ|で|と)\s+", "", value).strip()


def normalize_reading(value):
    value = normalize_japanese(value)
    return re.sub(r"（.*?）", "", value).strip()


def is_kana_token(value):
    return bool(re.fullmatch(r"[\u3040-\u30ffー・/（）()]+", value))


def should_skip_line(value):
    return value in {
        "",
        "JLPT N3 VOCABULARY",
        "STT 漢字 ひらがな Meaning",
    } or value.startswith("Migii JLPT") or value.startswith("https://")


def parse_line(line):
    match = re.match(r"^(\d+)\s+(.+)$", line)
    if not match:
        return None

    source_number = int(match.group(1))
    tokens = match.group(2).split()
    if not tokens:
        return None

    meaning_start = None
    for index, token in enumerate(tokens):
        if re.search(r"[A-Za-z]", token):
            meaning_start = index
            break

    if meaning_start is None:
        if len(tokens) < 3:
            return None
        meaning_start = len(tokens) - 1

    japanese_tokens = tokens[:meaning_start]
    meaning = " ".join(tokens[meaning_start:]).strip()
    if not japanese_tokens or not meaning:
        return None

    if len(japanese_tokens) >= 2 and is_kana_token(japanese_tokens[-1]) and not is_kana_token(
        "".join(japanese_tokens[:-1])
    ):
        japanese = " ".join(japanese_tokens[:-1])
        reading = japanese_tokens[-1]
    else:
        japanese = " ".join(japanese_tokens)
        reading = japanese

    japanese = normalize_japanese(japanese)
    reading = normalize_reading(reading)

    if not japanese or not reading:
        return None

    return {
        "sourceNumber": source_number,
        "japanese": japanese,
        "reading": reading,
        "english": meaning,
    }


def extract_rows(path):
    rows = []
    pending_number = None

    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            lines = [clean(line) for line in (page.extract_text() or "").splitlines()]
            for line in lines:
                if should_skip_line(line):
                    continue

                if pending_number and not re.match(r"^\d+\b", line):
                    line = f"{pending_number} {line}"
                    pending_number = None

                if re.fullmatch(r"\d+", line):
                    pending_number = line
                    continue

                parsed = parse_line(line)
                if not parsed:
                    continue

                rows.append(parsed)

    deduped = []
    seen = {}
    for row in rows:
        key = (row["japanese"], row["reading"])
        existing = seen.get(key)
        if existing is None:
            seen[key] = {
                **row,
                "sourceNumbers": [row["sourceNumber"]],
            }
            deduped.append(seen[key])
            continue

        if row["english"] and row["english"] not in existing["english"].split("; "):
            existing["english"] = f'{existing["english"]}; {row["english"]}'
        existing["sourceNumbers"].append(row["sourceNumber"])

    deduped.sort(key=lambda row: row["sourceNumber"])

    return rows, deduped


def main():
    path = sys.argv[1]
    rows, deduped = extract_rows(path)
    source_numbers = [row["sourceNumber"] for row in rows]
    highest = max(source_numbers) if source_numbers else 0
    missing = sorted(set(range(1, highest + 1)) - set(source_numbers))
    print(
        json.dumps(
            {
                "highestSourceNumber": highest,
                "missingSourceNumbers": missing,
                "rawRowCount": len(rows),
                "uniqueRowCount": len(deduped),
                "rows": deduped,
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
