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

export const japaneseVocabularyBankB = [
  category("people", "People", [
    ["わたし", "watashi", "I", "わたしはラフルです。"],
    ["あなた", "anata", "you", "あなたはがくせいですか。"],
    ["ひと", "hito", "person", "あのひとはせんせいです。"],
    ["ともだち", "tomodachi", "friend", "ともだちとえきへいきます。"],
    ["がくせい", "gakusei", "student", "わたしはがくせいです。"],
    ["せんせい", "sensei", "teacher", "せんせいはやさしいです。"],
  ]),
  category("jobs", "Jobs", [
    ["エンジニア", "enjinia", "engineer", "わたしはエンジニアです。"],
    ["いしゃ", "isha", "doctor", "ちちはいしゃです。"],
    ["かいしゃいん", "kaishain", "office worker", "あにはかいしゃいんです。"],
    ["てんいん", "tenin", "shop clerk", "てんいんにききます。"],
    ["りょうりにん", "ryourinin", "cook", "りょうりにんはラーメンをつくります。"],
    ["せいと", "seito", "pupil", "せいとはきいています。"],
  ]),
  category("countries", "Countries", [
    ["にほん", "nihon", "Japan", "にほんへいきたいです。"],
    ["インド", "indo", "India", "インドからきました。"],
    ["アメリカ", "amerika", "America", "アメリカのともだちです。"],
    ["ちゅうごく", "chuugoku", "China", "ちゅうごくごをべんきょうします。"],
    ["かんこく", "kankoku", "Korea", "かんこくへいったことがあります。"],
    ["イギリス", "igirisu", "United Kingdom", "イギリスのホテルです。"],
  ]),
  category("languages", "Languages", [
    ["にほんご", "nihongo", "Japanese language", "にほんごをべんきょうしています。"],
    ["えいご", "eigo", "English", "えいごはわかりますか。"],
    ["ちゅうごくご", "chuugokugo", "Chinese language", "ちゅうごくごはむずかしいです。"],
    ["かんこくご", "kankokugo", "Korean language", "かんこくごもすきです。"],
    ["フランスご", "furansugo", "French language", "フランスごをききます。"],
    ["スペインご", "supeingo", "Spanish language", "スペインごのうたです。"],
  ]),
  category("food", "Food", [
    ["ごはん", "gohan", "rice / meal", "ごはんをたべます。"],
    ["すし", "sushi", "sushi", "すしがすきです。"],
    ["ラーメン", "raamen", "ramen", "ラーメンをください。"],
    ["パン", "pan", "bread", "パンとコーヒーをのみます。"],
    ["さかな", "sakana", "fish", "さかなをたべません。"],
    ["やさい", "yasai", "vegetables", "やさいをかいます。"],
  ]),
  category("drinks", "Drinks", [
    ["みず", "mizu", "water", "みずをください。"],
    ["おちゃ", "ocha", "tea", "おちゃをのみます。"],
    ["コーヒー", "koohii", "coffee", "コーヒーがすきです。"],
    ["ぎゅうにゅう", "gyuunyuu", "milk", "ぎゅうにゅうをかいました。"],
    ["ジュース", "juusu", "juice", "ジュースをのみたいです。"],
    ["さけ", "sake", "alcohol / sake", "さけはのみません。"],
  ]),
  category("places", "Places", [
    ["いえ", "ie", "house", "いえへかえります。"],
    ["がっこう", "gakkou", "school", "がっこうにいきます。"],
    ["えき", "eki", "station", "えきはどこですか。"],
    ["みせ", "mise", "shop", "みせでかいます。"],
    ["レストラン", "resutoran", "restaurant", "レストランでたべます。"],
    ["ホテル", "hoteru", "hotel", "ホテルにとまります。"],
  ]),
  category("buildings", "Buildings", [
    ["びょういん", "byouin", "hospital", "びょういんへいきます。"],
    ["としょかん", "toshokan", "library", "としょかんでほんをよみます。"],
    ["デパート", "depaato", "department store", "デパートでふくをかいます。"],
    ["ぎんこう", "ginkou", "bank", "ぎんこうはどこですか。"],
    ["ゆうびんきょく", "yuubinkyoku", "post office", "ゆうびんきょくへいきます。"],
    ["こうえん", "kouen", "park", "こうえんでともだちにあいます。"],
  ]),
] as const;
