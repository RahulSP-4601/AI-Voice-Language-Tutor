import { type VocabularyCategory } from "@/lib/course-types";

type VocabRow = [string, string, string, string];

function category(
  id: string,
  title: string,
  entries: VocabRow[],
): VocabularyCategory {
  return {
    entries: entries.map(([japanese, romaji, english, example]) => ({
      english,
      example,
      japanese,
      romaji,
    })),
    id,
    title,
  };
}

export const japaneseVocabularyBankA = [
  category("greetings", "Greetings", [
    ["おはようございます", "ohayou gozaimasu", "good morning", "おはようございます、ゆきさん。"],
    ["こんにちは", "konnichiwa", "hello", "こんにちは、はじめまして。"],
    ["こんばんは", "konbanwa", "good evening", "こんばんは、さくらさん。"],
    ["おやすみなさい", "oyasuminasai", "good night", "おやすみなさい。またあした。"],
    ["さようなら", "sayounara", "goodbye", "さようなら。きをつけて。"],
    ["またね", "mata ne", "see you", "またね。あしたあおう。"],
  ]),
  category("classroom-japanese", "Classroom Japanese", [
    ["きいてください", "kiite kudasai", "please listen", "せんせいのこえをきいてください。"],
    ["いってください", "itte kudasai", "please say it", "もういちどいってください。"],
    ["みてください", "mite kudasai", "please look", "ここのれいをみてください。"],
    ["かいてください", "kaite kudasai", "please write", "ノートにかいてください。"],
    ["よんでください", "yonde kudasai", "please read", "このぶんをよんでください。"],
    ["わかりました", "wakarimashita", "I understood", "はい、わかりました。"],
  ]),
  category("time-expressions", "Time Expressions", [
    ["いま", "ima", "now", "いまべんきょうしています。"],
    ["きょう", "kyou", "today", "きょうはあめです。"],
    ["あした", "ashita", "tomorrow", "あしたにほんごをべんきょうします。"],
    ["きのう", "kinou", "yesterday", "きのうほんをよみました。"],
    ["まいにち", "mainichi", "every day", "まいにちれんしゅうします。"],
    ["あとで", "ato de", "later", "あとでコーヒーをのみます。"],
  ]),
  category("weekdays", "Days of the Week", [
    ["げつようび", "getsuyoubi", "Monday", "げつようびにがっこうへいきます。"],
    ["かようび", "kayoubi", "Tuesday", "かようびはしごとです。"],
    ["すいようび", "suiyoubi", "Wednesday", "すいようびにともだちにあいます。"],
    ["もくようび", "mokuyoubi", "Thursday", "もくようびによるべんきょうします。"],
    ["きんようび", "kinyoubi", "Friday", "きんようびはレストランへいきます。"],
    ["にちようび", "nichiyoubi", "Sunday", "にちようびにやすみます。"],
  ]),
  category("months-dates", "Months and Dates", [
    ["いちがつ", "ichigatsu", "January", "いちがつはさむいです。"],
    ["しがつ", "shigatsu", "April", "しがつにがっこうがはじまります。"],
    ["しちがつ", "shichigatsu", "July", "しちがつはあついです。"],
    ["じゅうにがつ", "juunigatsu", "December", "じゅうにがつにかえります。"],
    ["ついたち", "tsuitachi", "first day of month", "ついたちにかいものします。"],
    ["じゅうよっか", "juuyokka", "fourteenth day", "じゅうよっかにともだちとあいます。"],
  ]),
  category("numbers", "Numbers", [
    ["いち", "ichi", "one", "いちからごまでいってください。"],
    ["さん", "san", "three", "さんこください。"],
    ["よん", "yon", "four", "よんじです。"],
    ["なな", "nana", "seven", "ななにんいます。"],
    ["じゅう", "juu", "ten", "じゅうえんです。"],
    ["ひゃく", "hyaku", "one hundred", "ひゃくえんです。"],
  ]),
  category("money", "Money", [
    ["えん", "en", "yen", "ごひゃくえんです。"],
    ["いくら", "ikura", "how much", "これはいくらですか。"],
    ["たかい", "takai", "expensive", "このバッグはたかいです。"],
    ["やすい", "yasui", "cheap", "このパンはやすいです。"],
    ["せんえん", "sen en", "one thousand yen", "せんえんあります。"],
    ["おつり", "otsuri", "change", "おつりをください。"],
  ]),
  category("family", "Family Terms", [
    ["かぞく", "kazoku", "family", "わたしのかぞくはよにんです。"],
    ["ちち", "chichi", "my father", "ちちはせんせいです。"],
    ["はは", "haha", "my mother", "はははりょうりがじょうずです。"],
    ["あに", "ani", "older brother", "あにはとうきょうにいます。"],
    ["あね", "ane", "older sister", "あねはがくせいです。"],
    ["いもうと", "imouto", "younger sister", "いもうとはげんきです。"],
  ]),
] as const;
