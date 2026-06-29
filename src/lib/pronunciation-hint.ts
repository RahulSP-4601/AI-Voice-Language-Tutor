const ROMAJI_HINTS: Array<[string, string]> = [
  ["kya", "kyah"],
  ["kyu", "kyoo"],
  ["kyo", "kyoh"],
  ["gya", "gyah"],
  ["gyu", "gyoo"],
  ["gyo", "gyoh"],
  ["sha", "shah"],
  ["shu", "shoo"],
  ["sho", "shoh"],
  ["ja", "jah"],
  ["ju", "joo"],
  ["jo", "joh"],
  ["cha", "chah"],
  ["chu", "choo"],
  ["cho", "choh"],
  ["nya", "nyah"],
  ["nyu", "nyoo"],
  ["nyo", "nyoh"],
  ["hya", "hyah"],
  ["hyu", "hyoo"],
  ["hyo", "hyoh"],
  ["bya", "byah"],
  ["byu", "byoo"],
  ["byo", "byoh"],
  ["pya", "pyah"],
  ["pyu", "pyoo"],
  ["pyo", "pyoh"],
  ["mya", "myah"],
  ["myu", "myoo"],
  ["myo", "myoh"],
  ["rya", "ryah"],
  ["ryu", "ryoo"],
  ["ryo", "ryoh"],
  ["shi", "shee"],
  ["chi", "chee"],
  ["tsu", "tsoo"],
  ["fu", "foo"],
  ["ji", "jee"],
  ["ka", "kah"],
  ["ki", "kee"],
  ["ku", "koo"],
  ["ke", "keh"],
  ["ko", "koh"],
  ["ga", "gah"],
  ["gi", "gee"],
  ["gu", "goo"],
  ["ge", "geh"],
  ["go", "goh"],
  ["sa", "sah"],
  ["su", "soo"],
  ["se", "seh"],
  ["so", "soh"],
  ["za", "zah"],
  ["zu", "zoo"],
  ["ze", "zeh"],
  ["zo", "zoh"],
  ["ta", "tah"],
  ["te", "teh"],
  ["to", "toh"],
  ["da", "dah"],
  ["de", "deh"],
  ["do", "doh"],
  ["na", "nah"],
  ["ni", "nee"],
  ["nu", "noo"],
  ["ne", "neh"],
  ["no", "noh"],
  ["ha", "hah"],
  ["hi", "hee"],
  ["he", "heh"],
  ["ho", "hoh"],
  ["ba", "bah"],
  ["bi", "bee"],
  ["bu", "boo"],
  ["be", "beh"],
  ["bo", "boh"],
  ["pa", "pah"],
  ["pi", "pee"],
  ["pu", "poo"],
  ["pe", "peh"],
  ["po", "poh"],
  ["ma", "mah"],
  ["mi", "mee"],
  ["mu", "moo"],
  ["me", "meh"],
  ["mo", "moh"],
  ["ya", "yah"],
  ["yu", "yoo"],
  ["yo", "yoh"],
  ["ra", "rah"],
  ["ri", "ree"],
  ["ru", "roo"],
  ["re", "reh"],
  ["ro", "roh"],
  ["wa", "wah"],
  ["wo", "woh"],
  ["a", "ah"],
  ["i", "ee"],
  ["u", "oo"],
  ["e", "eh"],
  ["o", "oh"],
  ["n", "n"],
];

function tokenizeRomaji(value: string) {
  const cleaned = value.toLowerCase().replace(/[^a-z\s/,-]/g, " ").trim();
  const tokens: string[] = [];
  let index = 0;

  while (index < cleaned.length) {
    const char = cleaned[index];
    if ([" ", "-", "/", ","].includes(char)) {
      tokens.push(char);
      index += 1;
      continue;
    }

    if (
      index + 1 < cleaned.length &&
      cleaned[index] === cleaned[index + 1] &&
      !"aeioun".includes(cleaned[index])
    ) {
      tokens.push(`${cleaned[index]}-pause`);
      index += 1;
      continue;
    }

    const match = ROMAJI_HINTS.find(([source]) =>
      cleaned.startsWith(source, index),
    );
    if (match) {
      tokens.push(match[1]);
      index += match[0].length;
      continue;
    }

    tokens.push(cleaned[index]);
    index += 1;
  }

  return tokens;
}

export function generatePronunciationHint(reading: string) {
  const tokens = tokenizeRomaji(reading);
  const compact = tokens.reduce<string[]>((acc, token) => {
    if ([" ", "-", "/", ","].includes(token)) {
      if (acc.at(-1) !== "/") {
        acc.push("/");
      }
      return acc;
    }

    if (token.endsWith("-pause")) {
      acc.push(`${token.replace("-pause", "")}...`);
      return acc;
    }

    acc.push(token);
    return acc;
  }, []);

  return compact.join("-").replace(/-\/-/g, " / ").replace(/--+/g, "-");
}
