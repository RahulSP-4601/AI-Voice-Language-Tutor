import json
import re
import sys

import pdfplumber


VOCAB_HEADERS = {
    "",
    "JLPT N2 VOCABULARY",
    "STT 漢字 ひらがな Meaning",
}

KANJI_HEADERS = {
    "",
    "JLPT N2 KANJI LIST",
    "No Vocabulary Kanji Meaning",
}


def clean(value):
    if value is None:
        return ""
    return " ".join(str(value).split())


def is_kana_token(value):
    return bool(re.fullmatch(r"[\u3040-\u30ffー・/（）()]+", value))


def is_header(line, kind):
    headers = VOCAB_HEADERS if kind == "vocabulary" else KANJI_HEADERS
    return (
        line in headers
        or line.startswith("Migii JLPT")
        or line.startswith("Migii - ")
        or line.startswith("https://")
    )


def normalize_japanese(value):
    return re.sub(r"\s+", " ", value).strip()


def normalize_reading(value):
    return normalize_japanese(value)


def append_continuation(rows, line):
    if not rows:
        return
    english = rows[-1]["english"]
    rows[-1]["english"] = f"{english} {line}".strip() if english else line


def parse_vocab_line(line, pending_japanese=None):
    match = re.match(r"^(\d+)\s+(.+)$", line)
    if not match:
        return None

    source_number = int(match.group(1))
    tokens = match.group(2).split()
    meaning_start = None

    for index, token in enumerate(tokens):
        if re.search(r"[A-Za-z]", token):
            meaning_start = index
            break

    if meaning_start is None:
        if pending_japanese and len(tokens) >= 1 and is_kana_token(tokens[0]):
            return {
                "sourceNumber": source_number,
                "japanese": normalize_japanese(pending_japanese),
                "reading": normalize_reading(tokens[0]),
                "english": " ".join(tokens[1:]).strip(),
            }
        if len(tokens) == 2 and is_kana_token(tokens[1]):
            return {
                "sourceNumber": source_number,
                "japanese": normalize_japanese(tokens[0]),
                "reading": normalize_reading(tokens[1]),
                "english": "",
            }
        if len(tokens) == 1:
            return {
                "sourceNumber": source_number,
                "japanese": normalize_japanese(tokens[0]),
                "reading": "",
                "english": "",
            }
        return None

    japanese_tokens = tokens[:meaning_start]
    meaning = " ".join(tokens[meaning_start:]).strip()
    if pending_japanese and len(japanese_tokens) == 1 and is_kana_token(japanese_tokens[0]):
        return {
            "sourceNumber": source_number,
            "japanese": normalize_japanese(pending_japanese),
            "reading": normalize_reading(japanese_tokens[0]),
            "english": meaning,
        }
    if len(japanese_tokens) == 2 and japanese_tokens[0] == japanese_tokens[1]:
        return {
            "sourceNumber": source_number,
            "japanese": normalize_japanese(japanese_tokens[0]),
            "reading": normalize_reading(japanese_tokens[1]),
            "english": meaning,
        }
    if len(japanese_tokens) < 2:
        return None

    reading = japanese_tokens[-1]
    japanese = " ".join(japanese_tokens[:-1])
    if not is_kana_token(reading) and not pending_japanese:
        return None

    return {
        "sourceNumber": source_number,
        "japanese": normalize_japanese(japanese),
        "reading": normalize_reading(reading),
        "english": meaning,
    }


def extract_vocabulary(path):
    rows = []
    pending_number = None
    pending_japanese = None

    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            for raw in (page.extract_text() or "").splitlines():
                line = clean(raw)
                if is_header(line, "vocabulary"):
                    continue

                if pending_number and not re.match(r"^\d+\b", line):
                    line = f"{pending_number} {line}"
                    pending_number = None

                if re.fullmatch(r"\d+", line):
                    pending_number = line
                    continue

                if re.search(r"[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff々]", line) and not re.search(r"[A-Za-z]", line) and not re.match(r"^\d+\b", line):
                    if rows and not rows[-1]["reading"]:
                        rows[-1]["reading"] = normalize_reading(line.split()[0])
                        rows[-1]["english"] = " ".join(line.split()[1:]).strip() or rows[-1]["english"]
                    else:
                        pending_japanese = line
                    continue

                parsed = parse_vocab_line(line, pending_japanese)
                if parsed:
                    if not parsed["english"] and rows and rows[-1]["reading"] == parsed["reading"] and rows[-1]["english"]:
                        parsed["english"] = rows[-1]["english"]
                    rows.append(parsed)
                    pending_japanese = None
                    continue

                if rows and not rows[-1]["reading"] and not re.match(r"^\d+\b", line):
                    tokens = line.split()
                    if tokens and is_kana_token(tokens[0]):
                        rows[-1]["reading"] = normalize_reading(tokens[0])
                        rows[-1]["english"] = " ".join(tokens[1:]).strip()
                        continue

                if not re.match(r"^\d+\b", line):
                    append_continuation(rows, line)

    return dedupe_rows(rows)


def clean_kanji_term(value):
    return re.sub(r"\s+", " ", value).strip()


def extract_kanji(path):
    rows = []

    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            for table in page.extract_tables() or []:
                for row in table:
                    cells = [clean(cell) for cell in row]
                    if len(cells) < 4 or not cells[0].isdigit():
                        continue

                    source_number = int(cells[0])
                    reading = normalize_reading(cells[1])
                    japanese = clean_kanji_term(cells[2])
                    meaning = cells[3].strip()
                    if not japanese or not reading:
                        continue

                    rows.append(
                        {
                            "sourceNumber": source_number,
                            "japanese": japanese,
                            "reading": reading,
                            "english": meaning,
                        }
                    )

    return dedupe_rows(rows)


def dedupe_rows(rows):
    deduped = []
    seen = {}

    for row in rows:
        key = (row["japanese"], row["reading"])
        existing = seen.get(key)
        if existing is None:
            seen[key] = {**row, "sourceNumbers": [row["sourceNumber"]]}
            deduped.append(seen[key])
            continue

        if row["english"] and row["english"] not in existing["english"].split("; "):
            existing["english"] = f'{existing["english"]}; {row["english"]}'
        existing["sourceNumbers"].append(row["sourceNumber"])

    deduped.sort(key=lambda row: row["sourceNumber"])
    return {
        "highestSourceNumber": max((row["sourceNumber"] for row in rows), default=0),
        "missingSourceNumbers": sorted(
            set(range(1, max((row["sourceNumber"] for row in rows), default=0) + 1))
            - {row["sourceNumber"] for row in rows}
        ),
        "rawRowCount": len(rows),
        "rows": deduped,
        "uniqueRowCount": len(deduped),
    }


def main():
    vocab_path = sys.argv[1]
    kanji_path = sys.argv[2]
    print(
        json.dumps(
            {
                "kanji": extract_kanji(kanji_path),
                "vocabulary": extract_vocabulary(vocab_path),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
