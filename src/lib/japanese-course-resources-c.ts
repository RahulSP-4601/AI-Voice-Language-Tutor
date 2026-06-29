import { type VocabularyCategory } from "@/lib/course-types";

type VocabRow = [string, string, string, string];

function category(
  id: string,
  title: string,
  entries: VocabRow[],
): VocabularyCategory {
  return {
    entries: entries.map(([japanese, romaji, english, example], index) => ({
      english,
      example,
      id: `${id}-${index + 1}`,
      japanese,
      romaji,
      sortOrder: index + 1,
    })),
    id,
    title,
  };
}

export const japaneseVocabularyBankC = [
  category("transportation", "Transportation", [
    ["でんしゃ", "densha", "train", "でんしゃでいきます。"],
    ["バス", "basu", "bus", "バスよりでんしゃがはやいです。"],
    ["タクシー", "takushii", "taxi", "タクシーをよびます。"],
    ["くるま", "kuruma", "car", "くるまでがっこうへいきます。"],
    ["じてんしゃ", "jitensha", "bicycle", "じてんしゃにのります。"],
    ["ひこうき", "hikouki", "airplane", "ひこうきでにほんへいきます。"],
  ]),
  category("everyday-objects", "Everyday Objects", [
    ["ほん", "hon", "book", "これはほんです。"],
    ["ペン", "pen", "pen", "ペンでかきます。"],
    ["かばん", "kaban", "bag", "かばんはつくえのうえです。"],
    ["かさ", "kasa", "umbrella", "あめですからかさをもちます。"],
    ["でんわ", "denwa", "phone", "でんわでともだちとはなします。"],
    ["とけい", "tokei", "watch / clock", "とけいをみます。"],
  ]),
  category("clothing", "Clothing", [
    ["シャツ", "shatsu", "shirt", "しろいシャツです。"],
    ["くつ", "kutsu", "shoes", "あたらしいくつをかいました。"],
    ["ぼうし", "boushi", "hat", "ぼうしをかぶります。"],
    ["ズボン", "zubon", "trousers", "ズボンはやすいです。"],
    ["コート", "kooto", "coat", "ふゆはコートをきます。"],
    ["セーター", "seetaa", "sweater", "セーターはあたたかいです。"],
  ]),
  category("weather", "Weather", [
    ["はれ", "hare", "sunny", "きょうははれです。"],
    ["あめ", "ame", "rain", "あめがふっています。"],
    ["ゆき", "yuki", "snow", "ゆきはしろいです。"],
    ["くもり", "kumori", "cloudy", "あしたはくもりです。"],
    ["あつい", "atsui", "hot", "きょうはあついです。"],
    ["さむい", "samui", "cold", "ふゆはさむいです。"],
  ]),
  category("nature", "Nature", [
    ["やま", "yama", "mountain", "やまはたかいです。"],
    ["かわ", "kawa", "river", "かわのみずはきれいです。"],
    ["そら", "sora", "sky", "そらはあおいです。"],
    ["はな", "hana", "flower", "はなをみます。"],
    ["き", "ki", "tree", "おおきいきがあります。"],
    ["うみ", "umi", "sea", "うみへいきたいです。"],
  ]),
  category("body-parts", "Body Parts", [
    ["あたま", "atama", "head", "あたまがいたいです。"],
    ["め", "me", "eye", "めでみます。"],
    ["みみ", "mimi", "ear", "みみでききます。"],
    ["て", "te", "hand", "てでかきます。"],
    ["あし", "ashi", "leg / foot", "あしがつかれました。"],
    ["くち", "kuchi", "mouth", "くちをあけてください。"],
  ]),
  category("colors", "Colors", [
    ["しろ", "shiro", "white", "しろいシャツです。"],
    ["くろ", "kuro", "black", "くろいくつです。"],
    ["あか", "aka", "red", "あかいバッグです。"],
    ["あお", "ao", "blue", "あおいそらです。"],
    ["みどり", "midori", "green", "みどりのきです。"],
    ["きいろ", "kiiro", "yellow", "きいろいはなです。"],
  ]),
  category("basic-verbs", "Basic Verbs", [
    ["たべます", "tabemasu", "eat", "ラーメンをたべます。"],
    ["のみます", "nomimasu", "drink", "みずをのみます。"],
    ["いきます", "ikimasu", "go", "がっこうにいきます。"],
    ["きます", "kimasu", "come", "ともだちがきます。"],
    ["みます", "mimasu", "see / watch", "テレビをみます。"],
    ["はなします", "hanashimasu", "speak", "にほんごではなします。"],
  ]),
] as const;
