const ROMAJI_HINTS = [
  ["kya", "kyah"], ["kyu", "kyoo"], ["kyo", "kyoh"], ["gya", "gyah"],
  ["gyu", "gyoo"], ["gyo", "gyoh"], ["sha", "shah"], ["shu", "shoo"],
  ["sho", "shoh"], ["ja", "jah"], ["ju", "joo"], ["jo", "joh"],
  ["cha", "chah"], ["chu", "choo"], ["cho", "choh"], ["nya", "nyah"],
  ["nyu", "nyoo"], ["nyo", "nyoh"], ["hya", "hyah"], ["hyu", "hyoo"],
  ["hyo", "hyoh"], ["bya", "byah"], ["byu", "byoo"], ["byo", "byoh"],
  ["pya", "pyah"], ["pyu", "pyoo"], ["pyo", "pyoh"], ["mya", "myah"],
  ["myu", "myoo"], ["myo", "myoh"], ["rya", "ryah"], ["ryu", "ryoo"],
  ["ryo", "ryoh"], ["shi", "shee"], ["chi", "chee"], ["tsu", "tsoo"],
  ["fu", "foo"], ["ji", "jee"], ["ka", "kah"], ["ki", "kee"],
  ["ku", "koo"], ["ke", "keh"], ["ko", "koh"], ["ga", "gah"],
  ["gi", "gee"], ["gu", "goo"], ["ge", "geh"], ["go", "goh"],
  ["sa", "sah"], ["su", "soo"], ["se", "seh"], ["so", "soh"],
  ["za", "zah"], ["zu", "zoo"], ["ze", "zeh"], ["zo", "zoh"],
  ["ta", "tah"], ["te", "teh"], ["to", "toh"], ["da", "dah"],
  ["de", "deh"], ["do", "doh"], ["na", "nah"], ["ni", "nee"],
  ["nu", "noo"], ["ne", "neh"], ["no", "noh"], ["ha", "hah"],
  ["hi", "hee"], ["he", "heh"], ["ho", "hoh"], ["ba", "bah"],
  ["bi", "bee"], ["bu", "boo"], ["be", "beh"], ["bo", "boh"],
  ["pa", "pah"], ["pi", "pee"], ["pu", "poo"], ["pe", "peh"],
  ["po", "poh"], ["ma", "mah"], ["mi", "mee"], ["mu", "moo"],
  ["me", "meh"], ["mo", "moh"], ["ya", "yah"], ["yu", "yoo"],
  ["yo", "yoh"], ["ra", "rah"], ["ri", "ree"], ["ru", "roo"],
  ["re", "reh"], ["ro", "roh"], ["wa", "wah"], ["wo", "woh"],
  ["a", "ah"], ["i", "ee"], ["u", "oo"], ["e", "eh"], ["o", "oh"],
  ["n", "n"],
];

const KANA_DIGRAPHS = [
  ["きゃ", "kya"], ["きゅ", "kyu"], ["きょ", "kyo"], ["ぎゃ", "gya"],
  ["ぎゅ", "gyu"], ["ぎょ", "gyo"], ["しゃ", "sha"], ["しゅ", "shu"],
  ["しょ", "sho"], ["じゃ", "ja"], ["じゅ", "ju"], ["じょ", "jo"],
  ["ちゃ", "cha"], ["ちゅ", "chu"], ["ちょ", "cho"], ["にゃ", "nya"],
  ["にゅ", "nyu"], ["にょ", "nyo"], ["ひゃ", "hya"], ["ひゅ", "hyu"],
  ["ひょ", "hyo"], ["びゃ", "bya"], ["びゅ", "byu"], ["びょ", "byo"],
  ["ぴゃ", "pya"], ["ぴゅ", "pyu"], ["ぴょ", "pyo"], ["みゃ", "mya"],
  ["みゅ", "myu"], ["みょ", "myo"], ["りゃ", "rya"], ["りゅ", "ryu"],
  ["りょ", "ryo"], ["キャ", "kya"], ["キュ", "kyu"], ["キョ", "kyo"],
  ["ギャ", "gya"], ["ギュ", "gyu"], ["ギョ", "gyo"], ["シャ", "sha"],
  ["シュ", "shu"], ["ショ", "sho"], ["ジャ", "ja"], ["ジュ", "ju"],
  ["ジョ", "jo"], ["チャ", "cha"], ["チュ", "chu"], ["チョ", "cho"],
  ["ニャ", "nya"], ["ニュ", "nyu"], ["ニョ", "nyo"], ["ヒャ", "hya"],
  ["ヒュ", "hyu"], ["ヒョ", "hyo"], ["ビャ", "bya"], ["ビュ", "byu"],
  ["ビョ", "byo"], ["ピャ", "pya"], ["ピュ", "pyu"], ["ピョ", "pyo"],
  ["ミャ", "mya"], ["ミュ", "myu"], ["ミョ", "myo"], ["リャ", "rya"],
  ["リュ", "ryu"], ["リョ", "ryo"],
];

const KANA_MONOGRAPHS = {
  あ: "a", い: "i", う: "u", え: "e", お: "o",
  か: "ka", き: "ki", く: "ku", け: "ke", こ: "ko",
  さ: "sa", し: "shi", す: "su", せ: "se", そ: "so",
  た: "ta", ち: "chi", つ: "tsu", て: "te", と: "to",
  な: "na", に: "ni", ぬ: "nu", ね: "ne", の: "no",
  は: "ha", ひ: "hi", ふ: "fu", へ: "he", ほ: "ho",
  ま: "ma", み: "mi", む: "mu", め: "me", も: "mo",
  や: "ya", ゆ: "yu", よ: "yo",
  ら: "ra", り: "ri", る: "ru", れ: "re", ろ: "ro",
  わ: "wa", を: "wo", ん: "n",
  が: "ga", ぎ: "gi", ぐ: "gu", げ: "ge", ご: "go",
  ざ: "za", じ: "ji", ず: "zu", ぜ: "ze", ぞ: "zo",
  だ: "da", ぢ: "ji", づ: "zu", で: "de", ど: "do",
  ば: "ba", び: "bi", ぶ: "bu", べ: "be", ぼ: "bo",
  ぱ: "pa", ぴ: "pi", ぷ: "pu", ぺ: "pe", ぽ: "po",
  ア: "a", イ: "i", ウ: "u", エ: "e", オ: "o",
  カ: "ka", キ: "ki", ク: "ku", ケ: "ke", コ: "ko",
  サ: "sa", シ: "shi", ス: "su", セ: "se", ソ: "so",
  タ: "ta", チ: "chi", ツ: "tsu", テ: "te", ト: "to",
  ナ: "na", ニ: "ni", ヌ: "nu", ネ: "ne", ノ: "no",
  ハ: "ha", ヒ: "hi", フ: "fu", ヘ: "he", ホ: "ho",
  マ: "ma", ミ: "mi", ム: "mu", メ: "me", モ: "mo",
  ヤ: "ya", ユ: "yu", ヨ: "yo",
  ラ: "ra", リ: "ri", ル: "ru", レ: "re", ロ: "ro",
  ワ: "wa", ヲ: "wo", ン: "n",
  ガ: "ga", ギ: "gi", グ: "gu", ゲ: "ge", ゴ: "go",
  ザ: "za", ジ: "ji", ズ: "zu", ゼ: "ze", ゾ: "zo",
  ダ: "da", ヂ: "ji", ヅ: "zu", デ: "de", ド: "do",
  バ: "ba", ビ: "bi", ブ: "bu", ベ: "be", ボ: "bo",
  パ: "pa", ピ: "pi", プ: "pu", ペ: "pe", ポ: "po",
};

function looksLikeKana(value) {
  return /[\u3040-\u30ff]/.test(value);
}

function normalizeReading(value) {
  return value.replaceAll("／", "/").replaceAll("・", " ").trim();
}

function findDigraph(pair) {
  return KANA_DIGRAPHS.find(([kana]) => kana === pair)?.[1] ?? null;
}

function prolongLastVowel(chars) {
  const prev = chars.at(-1);
  if (!prev) return;
  chars.push(prev.at(-1) ?? "");
}

function pushKanaRomaji(chars, char, pauseNext) {
  const romaji = KANA_MONOGRAPHS[char];
  if (!romaji) {
    chars.push(char);
    return false;
  }

  if (pauseNext && !"aeioun".includes(romaji[0])) {
    chars.push(`${romaji[0]}-pause`);
  }

  chars.push(romaji);
  return false;
}

function kanaToRomaji(value) {
  const chars = [];
  const reading = normalizeReading(value);
  let pauseNext = false;

  for (let index = 0; index < reading.length; index += 1) {
    const pair = reading.slice(index, index + 2);
    const digraph = findDigraph(pair);
    if (digraph) {
      chars.push(digraph);
      index += 1;
      pauseNext = false;
      continue;
    }

    const char = reading[index];
    if (char === "っ" || char === "ッ") {
      pauseNext = true;
      continue;
    }

    if (char === "ー") {
      prolongLastVowel(chars);
      continue;
    }

    if (char === "/" || char === " " || char === ",") {
      chars.push(char);
      pauseNext = false;
      continue;
    }

    pauseNext = pushKanaRomaji(chars, char, pauseNext);
  }

  return chars.join("");
}

function tokenizeRomaji(value) {
  const cleaned = value.toLowerCase().replace(/[^a-z\s/,-]/g, " ").trim();
  const tokens = [];
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

    const match = ROMAJI_HINTS.find(([source]) => cleaned.startsWith(source, index));
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

function compactTokens(tokens) {
  return tokens.reduce((acc, token) => {
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
}

export function generatePronunciationHint(reading) {
  const normalized = normalizeReading(reading);
  if (!normalized) {
    return "";
  }

  const source = looksLikeKana(normalized) ? kanaToRomaji(normalized) : normalized;
  const hint = compactTokens(tokenizeRomaji(source))
    .join("-")
    .replace(/-\/-/g, " / ")
    .replace(/--+/g, "-")
    .trim();

  return hint === "/" ? "" : hint;
}
