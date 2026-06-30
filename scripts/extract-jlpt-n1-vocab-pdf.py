import json
import re
import sys

import pdfplumber


def clean(value):
    if value is None:
        return ""
    return " ".join(str(value).split())


def is_header(line):
    return (
        not line
        or line == "JLPT N1 VOCABULARY"
        or line == "STT 漢字 ひらがな Meaning"
        or line.startswith("Migii JLPT")
        or line.startswith("https://")
    )


def normalize_text(value):
    return re.sub(r"\s+", " ", value).strip()


def extract_rows(path):
    rows = []

    with pdfplumber.open(path) as pdf:
        for page in pdf.pages:
            tables = page.extract_tables() or []
            if not tables:
                continue

            for table in tables:
                pending_entry = None
                for row in table:
                    cells = [clean(cell) for cell in row]
                    if len(cells) < 4:
                        continue
                    if cells[0] == "STT":
                        continue

                    source_number = int(cells[0]) if cells[0].isdigit() else None
                    japanese = normalize_text(cells[1])
                    reading = normalize_text(cells[2])
                    english = normalize_text(cells[3])

                    if source_number is not None and japanese:
                        rows.append(
                            {
                                "sourceNumber": source_number,
                                "japanese": japanese,
                                "reading": reading,
                                "english": english,
                            }
                        )
                        pending_entry = None
                        continue

                    if source_number is None and japanese:
                        pending_entry = {
                            "japanese": japanese,
                            "reading": reading,
                            "english": english,
                        }
                        continue

                    if source_number is not None and pending_entry:
                        rows.append(
                            {
                                "sourceNumber": source_number,
                                "japanese": pending_entry["japanese"],
                                "reading": pending_entry["reading"],
                                "english": pending_entry["english"],
                            }
                        )
                        pending_entry = None

            # Recover rare missed rows from page text when a numbered entry did not land in the table.
            text_lines = [clean(line) for line in (page.extract_text() or "").splitlines()]
            for line in text_lines:
                if is_header(line):
                    continue
                match = re.match(r"^(\d+)\s+(.+?)\s+([^\s]+)\s+(.+)$", line)
                if not match:
                    continue
                source_number = int(match.group(1))
                if any(item["sourceNumber"] == source_number for item in rows):
                    continue
                rows.append(
                    {
                        "sourceNumber": source_number,
                        "japanese": normalize_text(match.group(2)),
                        "reading": normalize_text(match.group(3)),
                        "english": normalize_text(match.group(4)),
                    }
                )

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
    highest = max((row["sourceNumber"] for row in rows), default=0)

    return {
        "highestSourceNumber": highest,
        "missingSourceNumbers": sorted(set(range(1, highest + 1)) - {row["sourceNumber"] for row in rows}),
        "rawRowCount": len(rows),
        "rows": deduped,
        "uniqueRowCount": len(deduped),
    }


def main():
    path = sys.argv[1]
    print(json.dumps(extract_rows(path), ensure_ascii=False))


if __name__ == "__main__":
    main()
