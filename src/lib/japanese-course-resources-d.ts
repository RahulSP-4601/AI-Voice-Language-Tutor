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

export const japaneseVocabularyBankD = [
  category("basic-adjectives", "Basic Adjectives", [
    ["おいしい", "oishii", "delicious", "このすしはおいしいです。"],
    ["きれい", "kirei", "beautiful / clean", "このへやはきれいです。"],
    ["しずか", "shizuka", "quiet", "としょかんはしずかです。"],
    ["べんり", "benri", "convenient", "スマホはべんりです。"],
    ["おおきい", "ookii", "big", "おおきいやまです。"],
    ["ちいさい", "chiisai", "small", "ちいさいいぬです。"],
  ]),
  category("shopping-words", "Shopping Words", [
    ["これ", "kore", "this", "これをください。"],
    ["それ", "sore", "that", "それはたかいです。"],
    ["どれ", "dore", "which", "どれがいいですか。"],
    ["ください", "kudasai", "please give me", "みずをください。"],
    ["カード", "kaado", "card", "カードはだいじょうぶですか。"],
    ["げんきん", "genkin", "cash", "げんきんでください。"],
  ]),
  category("direction-words", "Direction Words", [
    ["みぎ", "migi", "right", "みぎです。"],
    ["ひだり", "hidari", "left", "ひだりへまがってください。"],
    ["まっすぐ", "massugu", "straight", "まっすぐです。"],
    ["うえ", "ue", "up", "うえをみてください。"],
    ["した", "shita", "down", "したにあります。"],
    ["となり", "tonari", "next to", "えきのとなりです。"],
  ]),
  category("school-words", "School Words", [
    ["じゅぎょう", "jugyou", "class", "じゅぎょうがはじまります。"],
    ["しゅくだい", "shukudai", "homework", "しゅくだいをします。"],
    ["ノート", "nooto", "notebook", "ノートにかきます。"],
    ["つくえ", "tsukue", "desk", "つくえのうえにほんがあります。"],
    ["いす", "isu", "chair", "いすにすわります。"],
    ["れんしゅう", "renshuu", "practice", "まいにちれんしゅうします。"],
  ]),
  category("house-words", "House Words", [
    ["へや", "heya", "room", "へやはしずかです。"],
    ["ドア", "doa", "door", "ドアをあけてください。"],
    ["まど", "mado", "window", "まどをしめます。"],
    ["だいどころ", "daidokoro", "kitchen", "だいどころでりょうりします。"],
    ["ベッド", "beddo", "bed", "ベッドでやすみます。"],
    ["でんき", "denki", "light / electricity", "でんきをつけます。"],
  ]),
  category("travel-words", "Travel Words", [
    ["きっぷ", "kippu", "ticket", "きっぷをかいます。"],
    ["パスポート", "pasupooto", "passport", "パスポートがあります。"],
    ["にもつ", "nimotsu", "luggage", "にもつはおもいです。"],
    ["ちず", "chizu", "map", "ちずをみます。"],
    ["りょこう", "ryokou", "trip", "にほんへりょこうします。"],
    ["よやく", "yoyaku", "reservation", "ホテルをよやくしました。"],
  ]),
  category("question-words", "Question Words", [
    ["なに", "nani", "what", "これはなにですか。"],
    ["どこ", "doko", "where", "えきはどこですか。"],
    ["だれ", "dare", "who", "あのひとはだれですか。"],
    ["いつ", "itsu", "when", "いついきますか。"],
    ["どう", "dou", "how", "どうですか。"],
    ["どうして", "doushite", "why", "どうしていきますか。"],
  ]),
  category("common-adverbs", "Common Adverbs", [
    ["よく", "yoku", "often / well", "よくにほんごをききます。"],
    ["あまり", "amari", "not very", "あまりさむくないです。"],
    ["すこし", "sukoshi", "a little", "すこしわかります。"],
    ["とても", "totemo", "very", "とてもおいしいです。"],
    ["もう", "mou", "already / more", "もういちどおねがいします。"],
    ["まだ", "mada", "not yet / still", "まだべんきょうしています。"],
  ]),
  category("basic-expressions", "Basic Expressions", [
    ["はい", "hai", "yes", "はい、そうです。"],
    ["いいえ", "iie", "no", "いいえ、ちがいます。"],
    ["だいじょうぶです", "daijoubu desu", "it is okay", "カードはだいじょうぶです。"],
    ["すみません", "sumimasen", "excuse me / sorry", "すみません、えきはどこですか。"],
    ["おねがいします", "onegaishimasu", "please", "もういちどおねがいします。"],
    ["どういたしまして", "douitashimashite", "you are welcome", "どういたしまして。"],
  ]),
] as const;
