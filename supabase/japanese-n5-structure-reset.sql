begin;

update public.curriculum_levels
set
  objective = 'Build the full JLPT N5 journey from absolute zero through romaji, kana, vocabulary, grammar, kanji, conversation, and the final certificate challenge.',
  exam_title = 'JLPT N5 final certificate exam',
  pass_requirement = 'Complete every N5 module, then clear the final integrated N5 exam to unlock the course certificate.',
  certificate_title = 'JLPT N5 completion certificate',
  certificate_summary = 'Issued after the learner completes the full N5 speaking-first journey and passes the integrated certificate exam.'
where id = 'jp-n5'
  and language_slug = 'japanese';

delete from public.curriculum_modules
where level_id = 'jp-n5'
  and language_slug = 'japanese';

do $$
declare
  module_row jsonb;
  lesson_row jsonb;
  lesson_sort integer;
  module_sort integer := 0;
  support_hint constant text :=
    'Use short English rescue notes only when they help the learner return to speaking faster.';
  feedback constant jsonb := $json$
    {
      "focus": "Pronunciation, clarity, and response confidence",
      "successSignal": "Learner can answer naturally without needing a long written script.",
      "correctionStyle": "Give one practical correction at a time in simple English, then return to speaking.",
      "retryCue": "Repeat once more with calmer pacing, stronger rhythm, and cleaner vowel timing."
    }
  $json$::jsonb;
  modules constant jsonb := $json$
  [
    {
      "id": "n5-module-01-what-is-japanese",
      "title": "What Is Japanese?",
      "objective": "Introduce Japanese from absolute zero and explain the full N5 learning journey in simple English.",
      "checkpointLabel": "Japanese overview check",
      "rewardBadge": "First Step in Japan",
      "rewardXp": 10,
      "coverage": ["What Japanese is", "How the course works", "Beginner-safe learning promise"],
      "missionTitle": "Mission 1: Understand the language you are entering",
      "storyHook": "You just landed in Japan and need a simple map before saying your first real word.",
      "resourceLinks": {
        "examSectionIds": ["sounds-romaji", "vocabulary"],
        "vocabularyCategoryIds": ["languages", "countries", "basic-expressions"]
      },
      "lessons": [
        {
          "id": "n5-lesson-01-what-is-japanese",
          "title": "What is Japanese?",
          "mode": "listening",
          "demoPhrase": "nihongo",
          "replyPrompt": "Say nihongo clearly once.",
          "targetPattern": "language identity",
          "learnerOutcome": "Learner understands that Japanese is a real spoken language they can unlock step by step.",
          "acceptableResponses": ["nihongo", "にほんご"]
        },
        {
          "id": "n5-lesson-02-how-japanese-differs",
          "title": "How Japanese is different from English",
          "mode": "listening",
          "demoPhrase": "watashi wa Rahul desu",
          "replyPrompt": "Repeat the sentence once with even rhythm.",
          "targetPattern": "basic sentence rhythm",
          "learnerOutcome": "Learner hears that Japanese rhythm and structure feel different from English.",
          "acceptableResponses": ["watashi wa rahul desu", "わたしは ラフルです"]
        },
        {
          "id": "n5-lesson-03-no-abcd",
          "title": "Japanese does not use ABCD",
          "mode": "repeat",
          "demoPhrase": "hiragana, katakana, kanji",
          "replyPrompt": "Say hiragana, katakana, and kanji in order.",
          "targetPattern": "script awareness",
          "learnerOutcome": "Learner can name the three Japanese writing systems aloud.",
          "acceptableResponses": ["hiragana katakana kanji", "ひらがな", "カタカナ", "かんじ"]
        },
        {
          "id": "n5-lesson-04-what-is-hiragana",
          "title": "What is Hiragana?",
          "mode": "listening",
          "demoPhrase": "hiragana",
          "replyPrompt": "Say hiragana once with clean pacing.",
          "targetPattern": "script naming",
          "learnerOutcome": "Learner knows hiragana is the main beginner script for native Japanese sounds.",
          "acceptableResponses": ["hiragana", "ひらがな"]
        },
        {
          "id": "n5-lesson-05-what-is-katakana",
          "title": "What is Katakana?",
          "mode": "listening",
          "demoPhrase": "katakana",
          "replyPrompt": "Say katakana clearly once.",
          "targetPattern": "script naming",
          "learnerOutcome": "Learner knows katakana is used for many foreign and modern words.",
          "acceptableResponses": ["katakana", "カタカナ"]
        },
        {
          "id": "n5-lesson-06-what-is-kanji",
          "title": "What is Kanji?",
          "mode": "listening",
          "demoPhrase": "kanji",
          "replyPrompt": "Say kanji once with confidence.",
          "targetPattern": "script naming",
          "learnerOutcome": "Learner understands that kanji are meaning-based characters introduced later in the course.",
          "acceptableResponses": ["kanji", "かんじ"]
        },
        {
          "id": "n5-lesson-07-what-is-jlpt",
          "title": "What is JLPT N5?",
          "mode": "listening",
          "demoPhrase": "N5",
          "replyPrompt": "Say N5 once and keep the tone confident.",
          "targetPattern": "course goal awareness",
          "learnerOutcome": "Learner understands that N5 is the beginner checkpoint this course prepares them for.",
          "acceptableResponses": ["N5", "n5"]
        }
      ]
    },
    {
      "id": "n5-module-02-romaji-bridge",
      "title": "Romaji Bridge",
      "objective": "Use English letters as a safe bridge into Japanese pronunciation before moving into real script.",
      "checkpointLabel": "Romaji bridge check",
      "rewardBadge": "Romaji Bridge Badge",
      "rewardXp": 15,
      "coverage": ["What romaji is", "Why romaji helps", "Moving from romaji toward kana"],
      "missionTitle": "Mission 2: Cross the romaji bridge",
      "storyHook": "You recognize sushi, arigatou, and nihon in English letters first. This bridge helps you start speaking immediately.",
      "resourceLinks": {
        "examSectionIds": ["sounds-romaji", "vocabulary"],
        "vocabularyCategoryIds": ["greetings", "travel-words", "basic-expressions", "languages"]
      },
      "lessons": [
        {
          "id": "n5-lesson-08-what-is-romaji",
          "title": "What is Romaji?",
          "mode": "repeat",
          "demoPhrase": "sushi, arigatou, nihon",
          "replyPrompt": "Read sushi, arigatou, and nihon with Japanese rhythm.",
          "targetPattern": "romaji support",
          "learnerOutcome": "Learner understands romaji as a pronunciation bridge, not the final goal.",
          "acceptableResponses": ["sushi", "arigatou", "nihon", "すし", "ありがとう", "にほん"]
        },
        {
          "id": "n5-lesson-09-vowels-in-romaji",
          "title": "Japanese vowels in Romaji",
          "mode": "repeat",
          "demoPhrase": "a, i, u, e, o",
          "replyPrompt": "Say a, i, u, e, o once with even rhythm.",
          "targetPattern": "romaji vowels",
          "learnerOutcome": "Learner can hear and repeat the five vowel sounds before kana pressure begins.",
          "acceptableResponses": ["a i u e o", "aiueo", "あいうえお"]
        },
        {
          "id": "n5-lesson-10-romaji-consonants",
          "title": "Japanese consonant sounds",
          "mode": "repeat",
          "demoPhrase": "ka, ki, ku, ke, ko",
          "replyPrompt": "Say the ka-row once with clean vowel timing.",
          "targetPattern": "consonant plus vowel rhythm",
          "learnerOutcome": "Learner hears the core consonant-plus-vowel pattern used throughout Japanese.",
          "acceptableResponses": ["ka ki ku ke ko", "かきくけこ"]
        },
        {
          "id": "n5-lesson-11-reading-romaji-words",
          "title": "Reading Japanese words with Romaji",
          "mode": "repeat",
          "demoPhrase": "konnichiwa",
          "replyPrompt": "Say konnichiwa once like one flowing word.",
          "targetPattern": "romaji word reading",
          "learnerOutcome": "Learner can speak a simple romaji word without reading it like English.",
          "acceptableResponses": ["konnichiwa", "こんにちは"]
        },
        {
          "id": "n5-lesson-12-romaji-to-hiragana",
          "title": "Moving from Romaji to Hiragana",
          "mode": "listening",
          "demoPhrase": "nihon and にほん",
          "replyPrompt": "Say nihon and then にほん once.",
          "targetPattern": "bridge to kana",
          "learnerOutcome": "Learner is ready to let romaji lead into real kana reading.",
          "acceptableResponses": ["nihon", "にほん"]
        }
      ]
    },
    {
      "id": "n5-module-03-japanese-vowels",
      "title": "Japanese Vowels",
      "objective": "Teach the five Japanese vowels as the foundation for every later word and row.",
      "checkpointLabel": "Vowel mastery check",
      "rewardBadge": "Vowel Master",
      "rewardXp": 15,
      "coverage": ["Five core vowels", "Mouth shape", "Tiny vowel words"],
      "missionTitle": "Mission 3: Hear the five core sounds",
      "storyHook": "Every future Japanese word depends on five stable vowel sounds.",
      "resourceLinks": {
        "examSectionIds": ["sounds-romaji"],
        "vocabularyCategoryIds": ["basic-expressions", "greetings"]
      },
      "lessons": [
        {
          "id": "n5-lesson-13-vowel-a",
          "title": "Vowel あ",
          "mode": "repeat",
          "demoPhrase": "あ",
          "replyPrompt": "Say あ once and keep it open and relaxed.",
          "targetPattern": "vowel a",
          "learnerOutcome": "Learner can say あ with the correct open vowel sound.",
          "acceptableResponses": ["あ", "a"]
        },
        {
          "id": "n5-lesson-14-vowel-i",
          "title": "Vowel い",
          "mode": "repeat",
          "demoPhrase": "い",
          "replyPrompt": "Say い once and keep the sound bright and clean.",
          "targetPattern": "vowel i",
          "learnerOutcome": "Learner can say い without turning it into an English diphthong.",
          "acceptableResponses": ["い", "i"]
        },
        {
          "id": "n5-lesson-15-vowel-u",
          "title": "Vowel う",
          "mode": "repeat",
          "demoPhrase": "う",
          "replyPrompt": "Say う once with soft rounded lips.",
          "targetPattern": "vowel u",
          "learnerOutcome": "Learner can control the softer Japanese u sound.",
          "acceptableResponses": ["う", "u"]
        },
        {
          "id": "n5-lesson-16-vowel-e",
          "title": "Vowel え",
          "mode": "repeat",
          "demoPhrase": "え",
          "replyPrompt": "Say え once and keep it short and clean.",
          "targetPattern": "vowel e",
          "learnerOutcome": "Learner can say え clearly inside a short syllable.",
          "acceptableResponses": ["え", "e"]
        },
        {
          "id": "n5-lesson-17-vowel-o",
          "title": "Vowel お",
          "mode": "repeat",
          "demoPhrase": "お",
          "replyPrompt": "Say お once and keep the sound round and even.",
          "targetPattern": "vowel o",
          "learnerOutcome": "Learner can say お without drifting into English stress.",
          "acceptableResponses": ["お", "o"]
        },
        {
          "id": "n5-lesson-18-mini-vowel-words",
          "title": "Mini vowel words",
          "mode": "repeat",
          "demoPhrase": "ai, ie, ue",
          "replyPrompt": "Say ai, ie, and ue one after another.",
          "targetPattern": "tiny vowel combinations",
          "learnerOutcome": "Learner moves from isolated vowels into tiny useful sound combinations.",
          "acceptableResponses": ["ai ie ue", "あい", "いえ", "うえ"]
        }
      ]
    },
    {
      "id": "n5-module-04-japanese-sound-pattern",
      "title": "Japanese Sound Pattern",
      "objective": "Teach the consonant-plus-vowel row system that makes Japanese feel predictable and readable.",
      "checkpointLabel": "Sound row check",
      "rewardBadge": "Sound Pattern Scout",
      "rewardXp": 15,
      "coverage": ["Consonant plus vowel logic", "Sound rows", "Core rhythm awareness"],
      "missionTitle": "Mission 4: Unlock the sound rows",
      "storyHook": "Once the rows click, the script stops feeling random and starts feeling built.",
      "resourceLinks": {
        "examSectionIds": ["sounds-romaji"],
        "vocabularyCategoryIds": ["basic-expressions", "question-words"]
      },
      "lessons": [
        {
          "id": "n5-lesson-19-ka-row",
          "title": "Ka-row sounds",
          "mode": "repeat",
          "demoPhrase": "ka, ki, ku, ke, ko",
          "replyPrompt": "Say the ka-row once smoothly.",
          "targetPattern": "ka row",
          "learnerOutcome": "Learner can hear how one consonant moves through the same five vowels.",
          "acceptableResponses": ["ka ki ku ke ko", "かきくけこ"]
        },
        {
          "id": "n5-lesson-20-sa-row",
          "title": "Sa-row sounds",
          "mode": "repeat",
          "demoPhrase": "sa, shi, su, se, so",
          "replyPrompt": "Say the sa-row and keep shi distinct.",
          "targetPattern": "sa row",
          "learnerOutcome": "Learner notices the special し sound inside an otherwise regular row.",
          "acceptableResponses": ["sa shi su se so", "さしすせそ"]
        },
        {
          "id": "n5-lesson-21-ta-row",
          "title": "Ta-row sounds",
          "mode": "repeat",
          "demoPhrase": "ta, chi, tsu, te, to",
          "replyPrompt": "Say the ta-row and keep chi and tsu clean.",
          "targetPattern": "ta row",
          "learnerOutcome": "Learner can produce the less-English-like chi and tsu syllables with control.",
          "acceptableResponses": ["ta chi tsu te to", "たちつてと"]
        },
        {
          "id": "n5-lesson-22-na-ha-rows",
          "title": "Na and ha rows",
          "mode": "repeat",
          "demoPhrase": "na, ni, nu, ne, no / ha, hi, fu, he, ho",
          "replyPrompt": "Say the na-row and ha-row once.",
          "targetPattern": "na and ha rows",
          "learnerOutcome": "Learner becomes comfortable with the fu sound and wider row practice.",
          "acceptableResponses": ["na ni nu ne no", "ha hi fu he ho"]
        },
        {
          "id": "n5-lesson-23-ma-ya-ra-wa",
          "title": "M, Y, R, and W rows",
          "mode": "repeat",
          "demoPhrase": "ma, mi, mu, me, mo / ya, yu, yo / ra, ri, ru, re, ro / wa, wo, n",
          "replyPrompt": "Say the final sound rows once with calm pacing.",
          "targetPattern": "final core rows",
          "learnerOutcome": "Learner can hear the full beginner map of Japanese sound rows before kana starts.",
          "acceptableResponses": ["ma mi mu me mo", "ya yu yo", "ra ri ru re ro", "wa wo n"]
        }
      ]
    },
    {
      "id": "n5-module-05-hiragana-basics",
      "title": "Hiragana Basics",
      "objective": "Teach all 46 core hiragana through readable rows, practice words, and full-chart review.",
      "checkpointLabel": "Hiragana chart check",
      "rewardBadge": "Hiragana Hero",
      "rewardXp": 20,
      "coverage": ["46 hiragana", "Row reading", "Simple words", "Full chart review"],
      "missionTitle": "Mission 5: Read your first Japanese script",
      "storyHook": "Hiragana is where the language starts to feel real on the page.",
      "resourceLinks": {
        "examSectionIds": ["hiragana"],
        "vocabularyCategoryIds": ["greetings", "food", "basic-expressions", "places"]
      },
      "lessons": [
        { "id": "n5-lesson-24-hiragana-aiueo", "title": "あいうえお", "mode": "repeat", "demoPhrase": "あ, い, う, え, お", "replyPrompt": "Say the hiragana vowels once.", "targetPattern": "hiragana vowels", "learnerOutcome": "Learner reads the first real hiragana row aloud.", "acceptableResponses": ["あいうえお", "a i u e o"] },
        { "id": "n5-lesson-25-hiragana-ka", "title": "かきくけこ", "mode": "repeat", "demoPhrase": "か, き, く, け, こ", "replyPrompt": "Say the ka-row in hiragana once.", "targetPattern": "hiragana ka row", "learnerOutcome": "Learner connects the ka-row sounds to their hiragana symbols.", "acceptableResponses": ["かきくけこ", "ka ki ku ke ko"] },
        { "id": "n5-lesson-26-hiragana-sa", "title": "さしすせそ", "mode": "repeat", "demoPhrase": "さ, し, す, せ, そ", "replyPrompt": "Say the sa-row in hiragana once.", "targetPattern": "hiragana sa row", "learnerOutcome": "Learner can read し naturally inside the hiragana row.", "acceptableResponses": ["さしすせそ", "sa shi su se so"] },
        { "id": "n5-lesson-27-hiragana-ta", "title": "たちつてと", "mode": "repeat", "demoPhrase": "た, ち, つ, て, と", "replyPrompt": "Say the ta-row in hiragana once.", "targetPattern": "hiragana ta row", "learnerOutcome": "Learner can read ち and つ without hesitation.", "acceptableResponses": ["たちつてと", "ta chi tsu te to"] },
        { "id": "n5-lesson-28-hiragana-na-ha", "title": "なにぬねの / はひふへほ", "mode": "repeat", "demoPhrase": "な, に, ぬ, ね, の / は, ひ, ふ, へ, ほ", "replyPrompt": "Say the na-row and ha-row once.", "targetPattern": "hiragana na and ha rows", "learnerOutcome": "Learner expands kana control across two more major rows.", "acceptableResponses": ["なにぬねの", "はひふへほ"] },
        { "id": "n5-lesson-29-hiragana-ma-ya-ra-wa", "title": "まみむめも / やゆよ / らりるれろ / わをん", "mode": "repeat", "demoPhrase": "ま, み, む, め, も / や, ゆ, よ / ら, り, る, れ, ろ / わ, を, ん", "replyPrompt": "Say the remaining hiragana rows once.", "targetPattern": "remaining hiragana rows", "learnerOutcome": "Learner completes the full base hiragana chart.", "acceptableResponses": ["まみむめも", "やゆよ", "らりるれろ", "わをん"] },
        { "id": "n5-lesson-30-hiragana-words", "title": "Practice hiragana words", "mode": "repeat", "demoPhrase": "すし, ねこ, いぬ, やま", "replyPrompt": "Read the four hiragana words once.", "targetPattern": "hiragana words", "learnerOutcome": "Learner turns character reading into real beginner words.", "acceptableResponses": ["すし", "ねこ", "いぬ", "やま"] },
        { "id": "n5-lesson-31-hiragana-full-reading", "title": "Full hiragana reading practice", "mode": "speaking", "demoPhrase": "にほん", "replyPrompt": "Read にほん once with calm pacing.", "targetPattern": "full chart review", "learnerOutcome": "Learner can read simple hiragana words without heavy romaji support.", "acceptableResponses": ["にほん", "nihon"] },
        { "id": "n5-lesson-32-hiragana-full-writing", "title": "Full hiragana writing practice", "mode": "checkpoint", "demoPhrase": "ありがとう", "replyPrompt": "Say ありがとう once before the writing check.", "targetPattern": "hiragana confidence", "learnerOutcome": "Learner is ready to review the full 46-character system with confidence.", "acceptableResponses": ["ありがとう", "arigatou"] }
      ]
    },
    {
      "id": "n5-module-06-hiragana-special-sounds",
      "title": "Hiragana Special Sounds",
      "objective": "Master dakuon, handakuon, yoon, sokuon, and long vowels so beginner reading becomes realistic.",
      "checkpointLabel": "Special hiragana check",
      "rewardBadge": "Hiragana Detail Master",
      "rewardXp": 20,
      "coverage": ["Dakuon", "Handakuon", "Yoon", "Small tsu", "Long vowels"],
      "missionTitle": "Mission 6: Hear the hidden sound changes",
      "storyHook": "Japanese looks simple until the special sounds appear. This mission turns those surprises into patterns.",
      "resourceLinks": {
        "examSectionIds": ["special-kana", "hiragana"],
        "vocabularyCategoryIds": ["school-words", "basic-expressions", "everyday-objects"]
      },
      "lessons": [
        { "id": "n5-lesson-33-dakuon", "title": "Dakuon", "mode": "repeat", "demoPhrase": "ga, gi, gu, ge, go", "replyPrompt": "Say the ga-row once with a voiced start.", "targetPattern": "voiced hiragana", "learnerOutcome": "Learner hears how two marks create a voiced sound change.", "acceptableResponses": ["ga gi gu ge go", "がぎぐげご"] },
        { "id": "n5-lesson-34-handakuon", "title": "Handakuon", "mode": "repeat", "demoPhrase": "pa, pi, pu, pe, po", "replyPrompt": "Say the pa-row once with a clean pop.", "targetPattern": "p sounds", "learnerOutcome": "Learner can hear and produce the handakuon pa-row clearly.", "acceptableResponses": ["pa pi pu pe po", "ぱぴぷぺぽ"] },
        { "id": "n5-lesson-35-yoon", "title": "Yoon", "mode": "repeat", "demoPhrase": "kya, kyu, kyo", "replyPrompt": "Say kya, kyu, and kyo once.", "targetPattern": "blended small ya yu yo sounds", "learnerOutcome": "Learner can blend yoon combinations into one compact syllable.", "acceptableResponses": ["kya kyu kyo", "きゃ きゅ きょ"] },
        { "id": "n5-lesson-36-sokuon", "title": "Sokuon", "mode": "repeat", "demoPhrase": "gakkou", "replyPrompt": "Say gakkou once and keep the small pause.", "targetPattern": "small tsu timing", "learnerOutcome": "Learner can hear and reproduce the stop created by small っ.", "acceptableResponses": ["gakkou", "がっこう"] },
        { "id": "n5-lesson-37-long-vowels", "title": "Long vowels", "mode": "repeat", "demoPhrase": "obaasan", "replyPrompt": "Say obaasan once and lengthen the long vowel cleanly.", "targetPattern": "long vowel timing", "learnerOutcome": "Learner can lengthen vowels without flattening the word's meaning.", "acceptableResponses": ["obaasan", "おばあさん"] }
      ]
    },
    {
      "id": "n5-module-07-katakana-basics",
      "title": "Katakana Basics",
      "objective": "Teach the 46 basic katakana through foreign-word reading, travel words, and full-chart familiarity.",
      "checkpointLabel": "Katakana chart check",
      "rewardBadge": "Katakana Explorer",
      "rewardXp": 20,
      "coverage": ["46 katakana", "Travel words", "Loanwords", "Full chart review"],
      "missionTitle": "Mission 7: Read the foreign-word script",
      "storyHook": "Once katakana opens up, signs, menus, and transport words feel far less mysterious.",
      "resourceLinks": {
        "examSectionIds": ["katakana"],
        "vocabularyCategoryIds": ["countries", "transportation", "drinks", "travel-words"]
      },
      "lessons": [
        { "id": "n5-lesson-38-katakana-aiueo", "title": "アイウエオ", "mode": "repeat", "demoPhrase": "ア, イ, ウ, エ, オ", "replyPrompt": "Say the katakana vowels once.", "targetPattern": "katakana vowels", "learnerOutcome": "Learner reads the katakana vowel row aloud with confidence.", "acceptableResponses": ["アイウエオ", "a i u e o"] },
        { "id": "n5-lesson-39-katakana-ka", "title": "カキクケコ", "mode": "repeat", "demoPhrase": "カ, キ, ク, ケ, コ", "replyPrompt": "Say the katakana ka-row once.", "targetPattern": "katakana ka row", "learnerOutcome": "Learner connects the katakana ka-row to familiar sounds.", "acceptableResponses": ["カキクケコ", "ka ki ku ke ko"] },
        { "id": "n5-lesson-40-katakana-sa", "title": "サシスセソ", "mode": "repeat", "demoPhrase": "サ, シ, ス, セ, ソ", "replyPrompt": "Say the katakana sa-row once.", "targetPattern": "katakana sa row", "learnerOutcome": "Learner keeps the script change while preserving the same sound rhythm.", "acceptableResponses": ["サシスセソ", "sa shi su se so"] },
        { "id": "n5-lesson-41-katakana-ta", "title": "タチツテト", "mode": "repeat", "demoPhrase": "タ, チ, ツ, テ, ト", "replyPrompt": "Say the katakana ta-row once.", "targetPattern": "katakana ta row", "learnerOutcome": "Learner reads katakana chi and tsu with growing ease.", "acceptableResponses": ["タチツテト", "ta chi tsu te to"] },
        { "id": "n5-lesson-42-katakana-remaining", "title": "Remaining katakana rows", "mode": "repeat", "demoPhrase": "ナ, ニ, ヌ, ネ, ノ / ハ, ヒ, フ, ヘ, ホ / マ, ミ, ム, メ, モ / ヤ, ユ, ヨ / ラ, リ, ル, レ, ロ / ワ, ヲ, ン", "replyPrompt": "Say the remaining katakana rows once.", "targetPattern": "remaining katakana rows", "learnerOutcome": "Learner completes the full base katakana chart.", "acceptableResponses": ["ナニヌネノ", "ハヒフヘホ", "マミムメモ", "ヤユヨ", "ラリルレロ", "ワヲン"] },
        { "id": "n5-lesson-43-katakana-words", "title": "Practice katakana words", "mode": "repeat", "demoPhrase": "ホテル, バス, タクシー, コーヒー", "replyPrompt": "Read the four katakana words once.", "targetPattern": "loanword reading", "learnerOutcome": "Learner reads practical travel and cafe words in katakana.", "acceptableResponses": ["ホテル", "バス", "タクシー", "コーヒー"] },
        { "id": "n5-lesson-44-katakana-full-reading", "title": "Full katakana reading practice", "mode": "speaking", "demoPhrase": "アメリカ", "replyPrompt": "Read アメリカ once like one natural word.", "targetPattern": "katakana review", "learnerOutcome": "Learner reads full katakana words without breaking the rhythm.", "acceptableResponses": ["アメリカ", "amerika"] },
        { "id": "n5-lesson-45-katakana-full-writing", "title": "Full katakana writing practice", "mode": "checkpoint", "demoPhrase": "インド", "replyPrompt": "Say インド once before the writing check.", "targetPattern": "katakana confidence", "learnerOutcome": "Learner is ready for full katakana recall and writing review.", "acceptableResponses": ["インド", "indo"] }
      ]
    },
    {
      "id": "n5-module-08-katakana-special-sounds",
      "title": "Katakana Special Sounds",
      "objective": "Handle voiced katakana, long vowels, and foreign-sound combinations used in modern everyday words.",
      "checkpointLabel": "Special katakana check",
      "rewardBadge": "Katakana Detail Master",
      "rewardXp": 20,
      "coverage": ["Dakuon", "Handakuon", "Yoon", "Small tsu", "Long vowels"],
      "missionTitle": "Mission 8: Speak modern katakana clearly",
      "storyHook": "Menus, transport signs, and borrowed words all get easier once these katakana patterns click.",
      "resourceLinks": {
        "examSectionIds": ["special-kana", "katakana"],
        "vocabularyCategoryIds": ["clothing", "drinks", "everyday-objects", "travel-words"]
      },
      "lessons": [
        { "id": "n5-lesson-46-katakana-dakuon", "title": "Katakana dakuon and handakuon", "mode": "repeat", "demoPhrase": "ga, gi, gu, ge, go / pa, pi, pu, pe, po", "replyPrompt": "Say the voiced and p rows once.", "targetPattern": "voiced katakana", "learnerOutcome": "Learner can hear and produce voiced katakana contrasts.", "acceptableResponses": ["ga gi gu ge go", "pa pi pu pe po"] },
        { "id": "n5-lesson-47-katakana-yoon", "title": "Katakana yoon", "mode": "repeat", "demoPhrase": "sha, shu, sho / cha, chu, cho", "replyPrompt": "Say the blended katakana sounds once.", "targetPattern": "katakana blended sounds", "learnerOutcome": "Learner can blend foreign-sound style combinations inside katakana.", "acceptableResponses": ["sha shu sho", "cha chu cho"] },
        { "id": "n5-lesson-48-katakana-sokuon", "title": "Katakana small tsu", "mode": "repeat", "demoPhrase": "beddo", "replyPrompt": "Say beddo once and keep the small pause.", "targetPattern": "katakana pause timing", "learnerOutcome": "Learner can produce the short stop used inside common katakana words.", "acceptableResponses": ["beddo", "ベッド"] },
        { "id": "n5-lesson-49-katakana-long-vowels", "title": "Katakana long vowels", "mode": "repeat", "demoPhrase": "koohii, juusu, geemu", "replyPrompt": "Say the three long-vowel katakana words once.", "targetPattern": "katakana long vowels", "learnerOutcome": "Learner can stretch the long vowels in common borrowed words naturally.", "acceptableResponses": ["koohii", "juusu", "geemu", "コーヒー", "ジュース", "ゲーム"] }
      ]
    },
    {
      "id": "n5-module-09-numbers-0-100",
      "title": "Numbers 0 to 100",
      "objective": "Teach counting from zero to one hundred with clean number-building logic and live speech use.",
      "checkpointLabel": "Numbers check",
      "rewardBadge": "Number Ninja",
      "rewardXp": 20,
      "coverage": ["0 to 10", "11 to 20", "Tens", "Practical numbers"],
      "missionTitle": "Mission 9: Count in Japanese",
      "storyHook": "You need numbers for everything in Japan: money, time, age, shopping, and directions.",
      "resourceLinks": {
        "examSectionIds": ["numbers", "speaking"],
        "vocabularyCategoryIds": ["numbers", "money"]
      },
      "lessons": [
        { "id": "n5-lesson-50-zero-to-ten", "title": "0 to 10", "mode": "repeat", "demoPhrase": "zero, ichi, ni, san, yon, go, roku, nana, hachi, kyuu, juu", "replyPrompt": "Count from 0 to 10 once.", "targetPattern": "basic counting", "learnerOutcome": "Learner can count the first ten numbers aloud with control.", "acceptableResponses": ["ichi ni san yon go roku nana hachi kyuu juu"] },
        { "id": "n5-lesson-51-eleven-to-twenty", "title": "11 to 20", "mode": "repeat", "demoPhrase": "juuichi, juuni, juusan, juuyon, juugo", "replyPrompt": "Say 11 to 15 once with calm rhythm.", "targetPattern": "teen numbers", "learnerOutcome": "Learner sees how 10 combines with later digits inside teen numbers.", "acceptableResponses": ["juuichi", "juuni", "juusan", "juuyon", "juugo"] },
        { "id": "n5-lesson-52-tens", "title": "Tens", "mode": "repeat", "demoPhrase": "nijuu, sanjuu, yonjuu, gojuu, rokujuu, nanajuu, hachijuu, kyuujuu", "replyPrompt": "Say the tens once from 20 to 90.", "targetPattern": "tens pattern", "learnerOutcome": "Learner can build tens without pausing between every number.", "acceptableResponses": ["nijuu", "sanjuu", "yonjuu", "gojuu", "rokujuu", "nanajuu", "hachijuu", "kyuujuu"] },
        { "id": "n5-lesson-53-practical-counting", "title": "Practical counting", "mode": "speaking", "demoPhrase": "nijuuichi, sanjuugo, yonjuuhachi, kyuujuukyuu", "replyPrompt": "Say 21, 35, 48, and 99 in Japanese.", "targetPattern": "combined numbers", "learnerOutcome": "Learner can combine tens and units into practical spoken numbers.", "acceptableResponses": ["nijuuichi", "sanjuugo", "yonjuuhachi", "kyuujuukyuu"] }
      ]
    },
    {
      "id": "n5-module-10-money-age-time-dates",
      "title": "Money, Age, Time, and Dates",
      "objective": "Turn number knowledge into survival Japanese for prices, age, time, weekdays, and dates.",
      "checkpointLabel": "Life numbers check",
      "rewardBadge": "Daily Numbers Badge",
      "rewardXp": 20,
      "coverage": ["Money", "Age", "Time", "Weekdays", "Dates"],
      "missionTitle": "Mission 10: Use numbers in real life",
      "storyHook": "Counting matters most when it becomes useful in shops, schedules, and introductions.",
      "resourceLinks": {
        "examSectionIds": ["numbers", "speaking"],
        "kanjiGroupIds": ["kanji-numbers-money", "kanji-time-nature"],
        "vocabularyCategoryIds": ["numbers", "money", "time-expressions", "weekdays", "months-dates"]
      },
      "lessons": [
        { "id": "n5-lesson-54-money", "title": "Money", "mode": "speaking", "demoPhrase": "hyaku en, gohyaku en, sen en", "replyPrompt": "Say 100 yen, 500 yen, and 1000 yen in Japanese.", "targetPattern": "money amounts", "learnerOutcome": "Learner can handle core yen amounts aloud.", "acceptableResponses": ["hyaku en", "gohyaku en", "sen en"] },
        { "id": "n5-lesson-55-age", "title": "Age", "mode": "speaking", "demoPhrase": "nan sai desu ka", "replyPrompt": "Ask 'How old are you?' once in Japanese.", "targetPattern": "age question", "learnerOutcome": "Learner can ask and hear the basic age question naturally.", "acceptableResponses": ["nan sai desu ka", "なんさいですか"] },
        { "id": "n5-lesson-56-time", "title": "Time", "mode": "repeat", "demoPhrase": "ichi ji, ni ji, san ji, yo ji, go ji", "replyPrompt": "Say 1 to 5 o'clock in Japanese.", "targetPattern": "telling time", "learnerOutcome": "Learner can produce the basic hour expressions used in N5 conversation.", "acceptableResponses": ["ichi ji", "ni ji", "san ji", "yo ji", "go ji"] },
        { "id": "n5-lesson-57-weekdays", "title": "Days of the week", "mode": "repeat", "demoPhrase": "getsuyoubi, kayoubi, suiyoubi", "replyPrompt": "Say Monday, Tuesday, and Wednesday in Japanese.", "targetPattern": "weekday words", "learnerOutcome": "Learner begins to answer schedule questions with weekday vocabulary.", "acceptableResponses": ["getsuyoubi", "kayoubi", "suiyoubi"] }
      ]
    },
    {
      "id": "n5-module-11-first-100-words",
      "title": "First 100 Words",
      "objective": "Build the first wave of real N5 vocabulary across people, food, places, objects, and weather.",
      "checkpointLabel": "First words check",
      "rewardBadge": "First Words Badge",
      "rewardXp": 20,
      "coverage": ["People", "Family", "Food and drink", "Places", "Objects", "Weather"],
      "missionTitle": "Mission 11: Unlock your first useful words",
      "storyHook": "Now the course shifts from sound systems into vocabulary you can actually use in real life.",
      "resourceLinks": {
        "examSectionIds": ["vocabulary", "speaking"],
        "vocabularyCategoryIds": ["people", "family", "food", "drinks", "places", "everyday-objects", "weather"]
      },
      "lessons": [
        { "id": "n5-lesson-58-people-words", "title": "People words", "mode": "repeat", "demoPhrase": "watashi, anata, tomodachi, sensei, gakusei", "replyPrompt": "Say the five people words once.", "targetPattern": "people vocabulary", "learnerOutcome": "Learner starts speaking core identity and classroom words naturally.", "acceptableResponses": ["watashi", "anata", "tomodachi", "sensei", "gakusei"] },
        { "id": "n5-lesson-59-family-words", "title": "Family words", "mode": "repeat", "demoPhrase": "kazoku, chichi, haha, otousan, okaasan", "replyPrompt": "Say the family words once.", "targetPattern": "family vocabulary", "learnerOutcome": "Learner can name close family relationships with basic Japanese words.", "acceptableResponses": ["kazoku", "chichi", "haha", "otousan", "okaasan"] },
        { "id": "n5-lesson-60-food-drink-words", "title": "Food and drink words", "mode": "repeat", "demoPhrase": "gohan, mizu, ocha, pan, sushi", "replyPrompt": "Say the food and drink words once.", "targetPattern": "food vocabulary", "learnerOutcome": "Learner gains the first survival words for food and drink requests.", "acceptableResponses": ["gohan", "mizu", "ocha", "pan", "sushi"] },
        { "id": "n5-lesson-61-place-words", "title": "Place words", "mode": "repeat", "demoPhrase": "ie, gakkou, eki, mise, hoteru", "replyPrompt": "Say the place words once.", "targetPattern": "place vocabulary", "learnerOutcome": "Learner can name common destinations and buildings.", "acceptableResponses": ["ie", "gakkou", "eki", "mise", "hoteru"] },
        { "id": "n5-lesson-62-object-weather-words", "title": "Objects and weather words", "mode": "repeat", "demoPhrase": "hon, pen, kaban, ame, hare", "replyPrompt": "Say the object and weather words once.", "targetPattern": "object and weather vocabulary", "learnerOutcome": "Learner can use the first practical nouns for objects and weather.", "acceptableResponses": ["hon", "pen", "kaban", "ame", "hare"] }
      ]
    },
    {
      "id": "n5-module-12-full-n5-vocabulary-bank",
      "title": "Full N5 Vocabulary Bank",
      "objective": "Expand into the full N5 vocabulary bank without making the learner feel like they are memorizing disconnected lists.",
      "checkpointLabel": "Vocabulary bank check",
      "rewardBadge": "Vocabulary Builder",
      "rewardXp": 20,
      "coverage": ["Core N5 categories", "Examples", "Audio-first practice", "Meaning plus use"],
      "missionTitle": "Mission 12: Grow the full beginner vocabulary bank",
      "storyHook": "The course now widens into the major word families that appear throughout N5 conversation and reading.",
      "resourceLinks": {
        "examSectionIds": ["vocabulary", "speaking"],
        "vocabularyCategoryIds": ["classroom-japanese", "time-expressions", "weekdays", "months-dates", "jobs", "countries", "languages", "buildings", "transportation", "clothing", "nature", "body-parts", "colors", "shopping-words", "direction-words", "school-words", "house-words", "travel-words", "question-words", "common-adverbs", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-63-time-and-schedule", "title": "Time and schedule words", "mode": "repeat", "demoPhrase": "kyou, ashita, getsuyoubi, ima", "replyPrompt": "Say the time and schedule words once.", "targetPattern": "time vocabulary", "learnerOutcome": "Learner expands into daily planning words used across N5.", "acceptableResponses": ["kyou", "ashita", "getsuyoubi", "ima"] },
        { "id": "n5-lesson-64-people-jobs-countries", "title": "People, jobs, and countries", "mode": "repeat", "demoPhrase": "sensei, isha, Indo, nihongo", "replyPrompt": "Say the four words once.", "targetPattern": "identity vocabulary", "learnerOutcome": "Learner adds country, job, and language words to self-introduction practice.", "acceptableResponses": ["sensei", "isha", "indo", "nihongo"] },
        { "id": "n5-lesson-65-transport-and-buildings", "title": "Transportation and buildings", "mode": "repeat", "demoPhrase": "densha, basu, toshokan, byouin", "replyPrompt": "Say the transport and building words once.", "targetPattern": "location vocabulary", "learnerOutcome": "Learner gains the words needed for travel and navigation scenes.", "acceptableResponses": ["densha", "basu", "toshokan", "byouin"] },
        { "id": "n5-lesson-66-shopping-and-house", "title": "Shopping, house, and object words", "mode": "repeat", "demoPhrase": "mise, kaban, kasa, heya", "replyPrompt": "Say the four words once.", "targetPattern": "shopping and house vocabulary", "learnerOutcome": "Learner gains everyday nouns for shopping and home contexts.", "acceptableResponses": ["mise", "kaban", "kasa", "heya"] },
        { "id": "n5-lesson-67-question-and-adverb", "title": "Question words and adverbs", "mode": "speaking", "demoPhrase": "doko, nani, mada, yukkuri", "replyPrompt": "Say the words once and keep the pacing steady.", "targetPattern": "question words and adverbs", "learnerOutcome": "Learner adds flexible question and pacing words to live speech.", "acceptableResponses": ["doko", "nani", "mada", "yukkuri"] }
      ]
    },
    {
      "id": "n5-module-13-greetings",
      "title": "Greetings",
      "objective": "Teach the highest-frequency greetings and polite expressions that make a learner sound respectful from day one.",
      "checkpointLabel": "Greeting check",
      "rewardBadge": "Greeting Guide",
      "rewardXp": 15,
      "coverage": ["Morning to night greetings", "Polite phrases", "Thanks and apology language"],
      "missionTitle": "Mission 13: Open every conversation well",
      "storyHook": "Before grammar grows, the learner needs social language that feels human and welcoming.",
      "resourceLinks": {
        "examSectionIds": ["vocabulary", "speaking"],
        "vocabularyCategoryIds": ["greetings", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-68-basic-greetings", "title": "Basic greetings", "mode": "repeat", "demoPhrase": "ohayou gozaimasu, konnichiwa, konbanwa", "replyPrompt": "Say the three greetings once.", "targetPattern": "daily greetings", "learnerOutcome": "Learner can greet someone naturally in the morning, daytime, and evening.", "acceptableResponses": ["ohayou gozaimasu", "konnichiwa", "konbanwa"] },
        { "id": "n5-lesson-69-closing-greetings", "title": "Goodbye and good night", "mode": "repeat", "demoPhrase": "oyasuminasai, sayounara, mata ne", "replyPrompt": "Say the closing phrases once.", "targetPattern": "conversation closing", "learnerOutcome": "Learner can end simple conversations naturally.", "acceptableResponses": ["oyasuminasai", "sayounara", "mata ne"] },
        { "id": "n5-lesson-70-polite-words", "title": "Polite words", "mode": "repeat", "demoPhrase": "arigatou gozaimasu, sumimasen, onegaishimasu", "replyPrompt": "Say the polite expressions once.", "targetPattern": "thanks and politeness", "learnerOutcome": "Learner gains the core polite expressions used constantly in beginner life Japanese.", "acceptableResponses": ["arigatou gozaimasu", "sumimasen", "onegaishimasu"] }
      ]
    },
    {
      "id": "n5-module-14-survival-phrases",
      "title": "Survival Phrases",
      "objective": "Teach practical safety and communication phrases that help a beginner keep moving in real situations.",
      "checkpointLabel": "Survival phrase check",
      "rewardBadge": "Survival Speaker",
      "rewardXp": 15,
      "coverage": ["I do not understand", "Repeat please", "Help language", "Comfort phrases"],
      "missionTitle": "Mission 14: Stay functional when things get hard",
      "storyHook": "The best beginner phrase is often the one that helps you keep the conversation alive when you feel lost.",
      "resourceLinks": {
        "examSectionIds": ["vocabulary", "speaking"],
        "vocabularyCategoryIds": ["basic-expressions", "question-words", "travel-words"]
      },
      "lessons": [
        { "id": "n5-lesson-71-dont-understand", "title": "I do not understand", "mode": "repeat", "demoPhrase": "wakarimasen", "replyPrompt": "Say wakarimasen once clearly.", "targetPattern": "confusion recovery", "learnerOutcome": "Learner can safely admit they do not understand and keep the interaction polite.", "acceptableResponses": ["wakarimasen", "わかりません"] },
        { "id": "n5-lesson-72-repeat-slowly", "title": "Repeat and slowly please", "mode": "repeat", "demoPhrase": "mou ichido onegaishimasu / yukkuri onegaishimasu", "replyPrompt": "Say both support requests once.", "targetPattern": "support requests", "learnerOutcome": "Learner can ask for repetition and slower speech politely.", "acceptableResponses": ["mou ichido onegaishimasu", "yukkuri onegaishimasu"] },
        { "id": "n5-lesson-73-help-and-english", "title": "Help and English support", "mode": "repeat", "demoPhrase": "eigo wa wakarimasu ka / tasukete kudasai", "replyPrompt": "Say the two support phrases once.", "targetPattern": "help requests", "learnerOutcome": "Learner can ask for English support or help in simple urgent situations.", "acceptableResponses": ["eigo wa wakarimasu ka", "tasukete kudasai"] },
        { "id": "n5-lesson-74-its-okay", "title": "It is okay", "mode": "repeat", "demoPhrase": "daijoubu desu", "replyPrompt": "Say daijoubu desu once with a calm tone.", "targetPattern": "comfort phrase", "learnerOutcome": "Learner can use a common calming phrase in many everyday situations.", "acceptableResponses": ["daijoubu desu", "だいじょうぶです"] }
      ]
    },
    {
      "id": "n5-module-15-first-sentence-pattern",
      "title": "First Sentence Pattern",
      "objective": "Teach A は B です as the first reliable sentence frame for identity, objects, and places.",
      "checkpointLabel": "First sentence pattern check",
      "rewardBadge": "Sentence Starter",
      "rewardXp": 15,
      "coverage": ["A は B です", "Identity", "Objects", "Places"],
      "missionTitle": "Mission 15: Build your first full Japanese sentence",
      "storyHook": "Now the learner moves beyond single words into complete beginner-safe meaning.",
      "resourceLinks": {
        "examSectionIds": ["particles", "speaking"],
        "vocabularyCategoryIds": ["people", "places", "everyday-objects", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-75-i-am", "title": "I am ___", "mode": "speaking", "demoPhrase": "watashi wa Rahul desu", "replyPrompt": "Say 'I am Rahul' once in Japanese.", "targetPattern": "self introduction", "learnerOutcome": "Learner can introduce themselves with the first core sentence frame.", "acceptableResponses": ["watashi wa rahul desu", "わたしは ラフルです"] },
        { "id": "n5-lesson-76-i-am-a-student", "title": "I am a student", "mode": "speaking", "demoPhrase": "watashi wa gakusei desu", "replyPrompt": "Say 'I am a student' once.", "targetPattern": "identity pattern", "learnerOutcome": "Learner can swap the B slot inside the same sentence frame.", "acceptableResponses": ["watashi wa gakusei desu", "わたしは がくせいです"] },
        { "id": "n5-lesson-77-this-is-a-book", "title": "This is a book", "mode": "speaking", "demoPhrase": "kore wa hon desu", "replyPrompt": "Say 'This is a book' once.", "targetPattern": "object identification", "learnerOutcome": "Learner uses the frame for objects, not only people.", "acceptableResponses": ["kore wa hon desu", "これは ほんです"] },
        { "id": "n5-lesson-78-this-is-a-station", "title": "This is a station", "mode": "speaking", "demoPhrase": "koko wa eki desu", "replyPrompt": "Say 'This place is a station' once.", "targetPattern": "place identification", "learnerOutcome": "Learner can use the same frame to identify places.", "acceptableResponses": ["koko wa eki desu", "ここは えきです"] }
      ]
    },
    {
      "id": "n5-module-16-questions",
      "title": "Questions",
      "objective": "Turn the first sentence pattern into simple yes-no questions and natural answers.",
      "checkpointLabel": "Question pattern check",
      "rewardBadge": "Question Starter",
      "rewardXp": 15,
      "coverage": ["A は B ですか", "Yes answers", "No answers"],
      "missionTitle": "Mission 16: Ask your first simple questions",
      "storyHook": "The learner now crosses from statements into live interaction.",
      "resourceLinks": {
        "examSectionIds": ["particles", "speaking"],
        "vocabularyCategoryIds": ["people", "places", "basic-expressions", "question-words"]
      },
      "lessons": [
        { "id": "n5-lesson-79-are-you-a-student", "title": "Are you a student?", "mode": "speaking", "demoPhrase": "anata wa gakusei desu ka", "replyPrompt": "Ask 'Are you a student?' once.", "targetPattern": "yes-no question", "learnerOutcome": "Learner can add か to form a clear question.", "acceptableResponses": ["anata wa gakusei desu ka", "あなたは がくせいですか"] },
        { "id": "n5-lesson-80-is-this-a-book", "title": "Is this a book?", "mode": "speaking", "demoPhrase": "kore wa hon desu ka", "replyPrompt": "Ask 'Is this a book?' once.", "targetPattern": "object question", "learnerOutcome": "Learner uses the question pattern for object confirmation.", "acceptableResponses": ["kore wa hon desu ka", "これは ほんですか"] },
        { "id": "n5-lesson-81-yes-no-answers", "title": "Yes and no answers", "mode": "repeat", "demoPhrase": "hai, sou desu / iie, chigaimasu", "replyPrompt": "Say the yes and no answers once.", "targetPattern": "question answers", "learnerOutcome": "Learner can answer yes-no questions politely and clearly.", "acceptableResponses": ["hai sou desu", "iie chigaimasu"] }
      ]
    },
    {
      "id": "n5-module-17-particles",
      "title": "Particles",
      "objective": "Teach the core N5 particles through short spoken lines instead of abstract grammar-only explanation.",
      "checkpointLabel": "Particles check",
      "rewardBadge": "Particle Master",
      "rewardXp": 20,
      "coverage": ["は", "が", "を", "に", "へ", "で", "と", "も", "の", "から / まで", "か / ね / よ"],
      "missionTitle": "Mission 17: Make sentences connect correctly",
      "storyHook": "Particles are the tiny connectors that make Japanese sentences feel real and understandable.",
      "resourceLinks": {
        "examSectionIds": ["particles", "grammar"],
        "vocabularyCategoryIds": ["basic-expressions", "basic-verbs", "people", "places", "direction-words"]
      },
      "lessons": [
        { "id": "n5-lesson-82-topic-object", "title": "Topic and object particles", "mode": "speaking", "demoPhrase": "watashi wa / mizu o nomimasu", "replyPrompt": "Say the topic example and the object example once.", "targetPattern": "wa and o", "learnerOutcome": "Learner can hear what は and を do inside simple lines.", "acceptableResponses": ["watashi wa", "mizu o nomimasu"] },
        { "id": "n5-lesson-83-direction-place", "title": "Direction and place particles", "mode": "speaking", "demoPhrase": "gakkou ni ikimasu / resutoran de tabemasu", "replyPrompt": "Say the destination and place examples once.", "targetPattern": "ni and de", "learnerOutcome": "Learner can distinguish destination from action location.", "acceptableResponses": ["gakkou ni ikimasu", "resutoran de tabemasu"] },
        { "id": "n5-lesson-84-with-too-possessive", "title": "And, with, also, and possession", "mode": "repeat", "demoPhrase": "pan to mizu / watashi mo gakusei desu / watashi no hon", "replyPrompt": "Say the three particle examples once.", "targetPattern": "to mo no", "learnerOutcome": "Learner gains three high-frequency connectors for basic description.", "acceptableResponses": ["pan to mizu", "watashi mo gakusei desu", "watashi no hon"] },
        { "id": "n5-lesson-85-other-core-particles", "title": "Other core particles", "mode": "repeat", "demoPhrase": "indo kara kimashita / eki made ikimasu / kore wa hon desu ka", "replyPrompt": "Say the examples once and notice kara, made, and ka.", "targetPattern": "remaining N5 particles", "learnerOutcome": "Learner hears the remaining core particles inside useful spoken lines.", "acceptableResponses": ["indo kara kimashita", "eki made ikimasu", "kore wa hon desu ka"] }
      ]
    },
    {
      "id": "n5-module-18-verb-basics",
      "title": "Verb Basics",
      "objective": "Introduce the most useful N5 verbs in polite present form so the learner can speak about actions immediately.",
      "checkpointLabel": "Verb basics check",
      "rewardBadge": "Verb Starter",
      "rewardXp": 15,
      "coverage": ["Core action verbs", "Polite present", "High-frequency action lines"],
      "missionTitle": "Mission 18: Start speaking with verbs",
      "storyHook": "Now the learner can finally say what they do, not just what things are.",
      "resourceLinks": {
        "examSectionIds": ["verbs-adjectives", "speaking"],
        "vocabularyCategoryIds": ["basic-verbs", "food", "drinks", "places"]
      },
      "lessons": [
        { "id": "n5-lesson-86-eat-and-drink", "title": "Eat and drink verbs", "mode": "speaking", "demoPhrase": "tabemasu / nomimasu", "replyPrompt": "Say tabemasu and nomimasu once.", "targetPattern": "eat drink verbs", "learnerOutcome": "Learner can use the first two survival verbs aloud.", "acceptableResponses": ["tabemasu", "nomimasu"] },
        { "id": "n5-lesson-87-go-and-come", "title": "Go and come verbs", "mode": "speaking", "demoPhrase": "ikimasu / kimasu", "replyPrompt": "Say ikimasu and kimasu once.", "targetPattern": "movement verbs", "learnerOutcome": "Learner can speak about going and coming in basic N5 situations.", "acceptableResponses": ["ikimasu", "kimasu"] },
        { "id": "n5-lesson-88-see-listen-read-write", "title": "See, listen, read, and write", "mode": "repeat", "demoPhrase": "mimasu / kikimasu / yomimasu / kakimasu", "replyPrompt": "Say the four verbs once.", "targetPattern": "study and media verbs", "learnerOutcome": "Learner gains a broader action set for classroom and daily life contexts.", "acceptableResponses": ["mimasu", "kikimasu", "yomimasu", "kakimasu"] },
        { "id": "n5-lesson-89-buy-study-work-rest", "title": "Buy, study, work, and rest", "mode": "repeat", "demoPhrase": "kaimasu / benkyou shimasu / hatarakimasu / yasumimasu", "replyPrompt": "Say the four verbs once.", "targetPattern": "daily action verbs", "learnerOutcome": "Learner adds practical daily routine verbs to spoken Japanese.", "acceptableResponses": ["kaimasu", "benkyou shimasu", "hatarakimasu", "yasumimasu"] }
      ]
    },
    {
      "id": "n5-module-19-verb-forms",
      "title": "Verb Forms",
      "objective": "Move from basic verb recognition into negative, past, dictionary, nai, ta, and te forms.",
      "checkpointLabel": "Verb forms check",
      "rewardBadge": "Verb Form Builder",
      "rewardXp": 20,
      "coverage": ["Polite negative", "Polite past", "Dictionary form", "Nai form", "Ta form", "Te form"],
      "missionTitle": "Mission 19: Bend verbs without breaking confidence",
      "storyHook": "This is where beginner Japanese starts feeling flexible instead of fixed.",
      "resourceLinks": {
        "examSectionIds": ["verbs-adjectives", "grammar"],
        "vocabularyCategoryIds": ["basic-verbs", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-90-polite-negative", "title": "Polite negative", "mode": "repeat", "demoPhrase": "tabemasen", "replyPrompt": "Say tabemasen once.", "targetPattern": "polite negative", "learnerOutcome": "Learner can change a polite present verb into the polite negative form.", "acceptableResponses": ["tabemasen", "たべません"] },
        { "id": "n5-lesson-91-polite-past", "title": "Polite past", "mode": "repeat", "demoPhrase": "ikimashita", "replyPrompt": "Say ikimashita once.", "targetPattern": "polite past", "learnerOutcome": "Learner can form a simple polite past sentence.", "acceptableResponses": ["ikimashita", "いきました"] },
        { "id": "n5-lesson-92-dictionary-and-nai", "title": "Dictionary and nai forms", "mode": "repeat", "demoPhrase": "taberu / tabenai", "replyPrompt": "Say taberu and tabenai once.", "targetPattern": "dictionary and nai forms", "learnerOutcome": "Learner recognizes the plain form and negative plain form for a simple verb.", "acceptableResponses": ["taberu", "tabenai"] },
        { "id": "n5-lesson-93-ta-and-te", "title": "Ta and te forms", "mode": "repeat", "demoPhrase": "tabeta / tabete", "replyPrompt": "Say tabeta and tabete once.", "targetPattern": "ta and te forms", "learnerOutcome": "Learner gains the first spoken feel for ta and te forms in Japanese.", "acceptableResponses": ["tabeta", "tabete"] }
      ]
    },
    {
      "id": "n5-module-20-adjectives",
      "title": "Adjectives",
      "objective": "Teach the core difference between i-adjectives and na-adjectives through spoken examples.",
      "checkpointLabel": "Adjective check",
      "rewardBadge": "Adjective Starter",
      "rewardXp": 15,
      "coverage": ["I-adjectives", "Na-adjectives", "Simple adjective conjugation"],
      "missionTitle": "Mission 20: Describe things clearly",
      "storyHook": "The learner is ready to say what is hot, cheap, quiet, beautiful, convenient, or delicious.",
      "resourceLinks": {
        "examSectionIds": ["verbs-adjectives", "speaking"],
        "vocabularyCategoryIds": ["basic-adjectives", "weather", "food", "places"]
      },
      "lessons": [
        { "id": "n5-lesson-94-i-adjectives", "title": "I-adjectives", "mode": "repeat", "demoPhrase": "oishii, atsui, samui, takai, yasui", "replyPrompt": "Say the five i-adjectives once.", "targetPattern": "i-adjectives", "learnerOutcome": "Learner can produce the most useful beginner i-adjectives in speech.", "acceptableResponses": ["oishii", "atsui", "samui", "takai", "yasui"] },
        { "id": "n5-lesson-95-na-adjectives", "title": "Na-adjectives", "mode": "repeat", "demoPhrase": "shizuka, kirei, benri, suki", "replyPrompt": "Say the na-adjectives once.", "targetPattern": "na-adjectives", "learnerOutcome": "Learner can hear the core beginner na-adjectives clearly.", "acceptableResponses": ["shizuka", "kirei", "benri", "suki"] },
        { "id": "n5-lesson-96-adjective-conjugation", "title": "Adjective conjugation", "mode": "speaking", "demoPhrase": "oishii desu / oishikunai desu / shizuka desu", "replyPrompt": "Say the adjective lines once.", "targetPattern": "adjective conjugation", "learnerOutcome": "Learner can make simple present and negative adjective statements.", "acceptableResponses": ["oishii desu", "oishikunai desu", "shizuka desu"] }
      ]
    },
    {
      "id": "n5-module-21-grammar-patterns",
      "title": "Grammar Sentence Patterns",
      "objective": "Teach the major N5 sentence patterns through short practical lines that stay voice-first.",
      "checkpointLabel": "Grammar pattern check",
      "rewardBadge": "Grammar Starter",
      "rewardXp": 25,
      "coverage": ["Requests", "Permission", "Desire", "Continuous action", "Comparison", "Reason", "Experience", "Plans"],
      "missionTitle": "Mission 21: Speak with real N5 grammar",
      "storyHook": "Now beginner Japanese starts sounding like real communication instead of isolated drills.",
      "resourceLinks": {
        "examSectionIds": ["grammar", "speaking"],
        "vocabularyCategoryIds": ["basic-verbs", "basic-adjectives", "basic-expressions", "question-words"]
      },
      "lessons": [
        { "id": "n5-lesson-97-te-kudasai", "title": "てください requests", "mode": "speaking", "demoPhrase": "mou ichido itte kudasai", "replyPrompt": "Say the request once politely.", "targetPattern": "request pattern", "learnerOutcome": "Learner can ask someone to do something politely.", "acceptableResponses": ["mou ichido itte kudasai"] },
        { "id": "n5-lesson-98-permission", "title": "てもいいです permission", "mode": "speaking", "demoPhrase": "koko ni suwatte mo ii desu ka", "replyPrompt": "Ask for permission once.", "targetPattern": "permission pattern", "learnerOutcome": "Learner can ask for permission using てもいいですか.", "acceptableResponses": ["koko ni suwatte mo ii desu ka"] },
        { "id": "n5-lesson-99-desire", "title": "たい and ほしい", "mode": "speaking", "demoPhrase": "nihon e ikitai desu / mizu ga hoshii desu", "replyPrompt": "Say the two desire lines once.", "targetPattern": "want to do versus want a thing", "learnerOutcome": "Learner can express desire for an action and desire for an object.", "acceptableResponses": ["nihon e ikitai desu", "mizu ga hoshii desu"] },
        { "id": "n5-lesson-100-te-imasu", "title": "ています", "mode": "speaking", "demoPhrase": "ima benkyou shite imasu", "replyPrompt": "Say the continuous action sentence once.", "targetPattern": "continuous action", "learnerOutcome": "Learner can describe an action happening now.", "acceptableResponses": ["ima benkyou shite imasu"] },
        { "id": "n5-lesson-101-reasons", "title": "から for reasons", "mode": "speaking", "demoPhrase": "atsui desu kara mizu o nomimasu", "replyPrompt": "Say the reason sentence once.", "targetPattern": "reason pattern", "learnerOutcome": "Learner can connect a reason and action into one spoken line.", "acceptableResponses": ["atsui desu kara mizu o nomimasu"] },
        { "id": "n5-lesson-102-comparison", "title": "Comparisons", "mode": "speaking", "demoPhrase": "densha no hou ga basu yori hayai desu", "replyPrompt": "Say the comparison sentence once.", "targetPattern": "comparative pattern", "learnerOutcome": "Learner can compare two things in a simple spoken sentence.", "acceptableResponses": ["densha no hou ga basu yori hayai desu"] },
        { "id": "n5-lesson-103-experience-and-plans", "title": "Experience and plans", "mode": "speaking", "demoPhrase": "nihon e itta koto ga arimasu / ashita benkyou suru tsumori desu", "replyPrompt": "Say both lines once.", "targetPattern": "experience and intention", "learnerOutcome": "Learner can speak about past experience and future intention at a beginner level.", "acceptableResponses": ["nihon e itta koto ga arimasu", "ashita benkyou suru tsumori desu"] }
      ]
    },
    {
      "id": "n5-module-22-counter-suffixes",
      "title": "Counter Suffixes",
      "objective": "Teach the most useful N5 counters for things, people, books, machines, age, and small animals.",
      "checkpointLabel": "Counter check",
      "rewardBadge": "Counter Starter",
      "rewardXp": 15,
      "coverage": ["General items", "People", "Long objects", "Flat objects", "Books", "Machines", "Age", "Animals"],
      "missionTitle": "Mission 22: Count the right way",
      "storyHook": "Japanese counting changes shape depending on what is being counted, so this mission makes the patterns feel practical.",
      "resourceLinks": {
        "examSectionIds": ["counters", "numbers"],
        "vocabularyCategoryIds": ["numbers", "people", "everyday-objects", "money"]
      },
      "lessons": [
        { "id": "n5-lesson-104-general-items", "title": "General item counter つ", "mode": "repeat", "demoPhrase": "hitotsu, futatsu, mittsu", "replyPrompt": "Say the first three general item counters once.", "targetPattern": "general item counters", "learnerOutcome": "Learner can count basic things with the general つ counter.", "acceptableResponses": ["hitotsu", "futatsu", "mittsu"] },
        { "id": "n5-lesson-105-people-counter", "title": "People counter 人", "mode": "repeat", "demoPhrase": "hitori, futari, sannin", "replyPrompt": "Say one person, two people, and three people once.", "targetPattern": "people counters", "learnerOutcome": "Learner masters the irregular first two people counters.", "acceptableResponses": ["hitori", "futari", "sannin"] },
        { "id": "n5-lesson-106-object-counters", "title": "Books, flat objects, and machines", "mode": "repeat", "demoPhrase": "issatsu, ichimai, ichidai", "replyPrompt": "Say the three counters once.", "targetPattern": "object counters", "learnerOutcome": "Learner recognizes that different object types take different counters.", "acceptableResponses": ["issatsu", "ichimai", "ichidai"] },
        { "id": "n5-lesson-107-age-and-animals", "title": "Age and small animals", "mode": "repeat", "demoPhrase": "issai, nisai, ippiki, nihiki", "replyPrompt": "Say the age and animal counters once.", "targetPattern": "age and animal counters", "learnerOutcome": "Learner adds two more practical counter families used in daily life.", "acceptableResponses": ["issai", "nisai", "ippiki", "nihiki"] }
      ]
    },
    {
      "id": "n5-module-23-kanji-foundation",
      "title": "Kanji Foundation",
      "objective": "Introduce the essential N5 kanji in meaning-based categories after kana is already stable.",
      "checkpointLabel": "Kanji foundation check",
      "rewardBadge": "Kanji Starter",
      "rewardXp": 25,
      "coverage": ["Numbers", "Time and nature", "Directions", "People", "Actions", "Objects and environment"],
      "missionTitle": "Mission 23: Read the first real meaning-based symbols",
      "storyHook": "Kanji feels intimidating until it is grouped into useful meaning families that the learner can speak and notice.",
      "resourceLinks": {
        "examSectionIds": ["kanji", "reading"],
        "kanjiGroupIds": ["kanji-numbers-money", "kanji-time-nature", "kanji-directions-places", "kanji-people-relations", "kanji-actions", "kanji-objects-environment"],
        "vocabularyCategoryIds": ["numbers", "money", "time-expressions", "places", "people", "basic-verbs"]
      },
      "lessons": [
        { "id": "n5-lesson-108-kanji-numbers", "title": "Numbers and money kanji", "mode": "repeat", "demoPhrase": "一, 二, 三, 円", "replyPrompt": "Read the four kanji once.", "targetPattern": "numbers and money kanji", "learnerOutcome": "Learner recognizes the first practical kanji family used in prices and counting.", "acceptableResponses": ["ichi", "ni", "san", "en"] },
        { "id": "n5-lesson-109-kanji-time", "title": "Time, dates, and nature kanji", "mode": "repeat", "demoPhrase": "日, 月, 火, 水", "replyPrompt": "Read the four kanji once.", "targetPattern": "time and nature kanji", "learnerOutcome": "Learner begins to recognize day, month, and weekday-related kanji.", "acceptableResponses": ["nichi", "getsu", "ka", "sui"] },
        { "id": "n5-lesson-110-kanji-directions", "title": "Directions and location kanji", "mode": "repeat", "demoPhrase": "上, 下, 左, 右", "replyPrompt": "Read the direction kanji once.", "targetPattern": "direction kanji", "learnerOutcome": "Learner recognizes the core location kanji found in signs and directions.", "acceptableResponses": ["ue", "shita", "hidari", "migi"] },
        { "id": "n5-lesson-111-kanji-people", "title": "People and relationship kanji", "mode": "repeat", "demoPhrase": "人, 子, 父, 母, 友", "replyPrompt": "Read the people kanji once.", "targetPattern": "people kanji", "learnerOutcome": "Learner reads the highest-value identity and family kanji aloud.", "acceptableResponses": ["hito", "ko", "chichi", "haha", "tomo"] },
        { "id": "n5-lesson-112-kanji-actions", "title": "Action kanji", "mode": "repeat", "demoPhrase": "行, 来, 食, 飲, 見", "replyPrompt": "Read the action kanji once.", "targetPattern": "action kanji", "learnerOutcome": "Learner recognizes the kanji behind the most common N5 actions.", "acceptableResponses": ["kou", "rai", "shoku", "in", "ken"] },
        { "id": "n5-lesson-113-kanji-objects", "title": "Environment and object kanji", "mode": "repeat", "demoPhrase": "山, 川, 本, 車, 語", "replyPrompt": "Read the environment and object kanji once.", "targetPattern": "object and environment kanji", "learnerOutcome": "Learner finishes the first useful kanji families needed for N5 reading.", "acceptableResponses": ["yama", "kawa", "hon", "kuruma", "go"] }
      ]
    },
    {
      "id": "n5-module-24-self-introduction",
      "title": "Self Introduction",
      "objective": "Build a real beginner self-introduction that combines name, nationality, and polite opening phrases.",
      "checkpointLabel": "Self introduction check",
      "rewardBadge": "First Conversation Badge",
      "rewardXp": 20,
      "coverage": ["Nice to meet you", "Name", "Nationality", "Job or role", "Closing politeness"],
      "missionTitle": "Mission 24: Introduce yourself in Japanese",
      "storyHook": "The learner finally starts sounding like a real person in Japanese, not only a student doing drills.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "vocabulary"],
        "vocabularyCategoryIds": ["people", "countries", "jobs", "languages", "basic-expressions", "greetings"]
      },
      "lessons": [
        { "id": "n5-lesson-114-hajimemashite", "title": "Nice to meet you", "mode": "repeat", "demoPhrase": "hajimemashite", "replyPrompt": "Say hajimemashite once politely.", "targetPattern": "opening introduction", "learnerOutcome": "Learner opens a first meeting naturally.", "acceptableResponses": ["hajimemashite", "はじめまして"] },
        { "id": "n5-lesson-115-name-nationality", "title": "Name and nationality", "mode": "speaking", "demoPhrase": "watashi wa Rahul desu. Indo kara kimashita.", "replyPrompt": "Say the name and nationality introduction once.", "targetPattern": "identity introduction", "learnerOutcome": "Learner gives a short introduction with name and origin.", "acceptableResponses": ["watashi wa rahul desu", "indo kara kimashita"] },
        { "id": "n5-lesson-116-role-and-close", "title": "Role and closing", "mode": "speaking", "demoPhrase": "enjinia desu. yoroshiku onegaishimasu.", "replyPrompt": "Say the role and closing line once.", "targetPattern": "role and polite close", "learnerOutcome": "Learner can finish a self-introduction politely.", "acceptableResponses": ["enjinia desu", "yoroshiku onegaishimasu"] }
      ]
    },
    {
      "id": "n5-module-25-cafe-and-restaurant",
      "title": "Cafe and Restaurant",
      "objective": "Teach the lines needed to order food, ask prices, and react politely in a cafe or restaurant.",
      "checkpointLabel": "Cafe check",
      "rewardBadge": "Food Mission Badge",
      "rewardXp": 20,
      "coverage": ["Excuse me", "Water please", "Order food", "How much is this", "It is delicious"],
      "missionTitle": "Mission 25: Order food with confidence",
      "storyHook": "One of the first places a learner wants to survive in Japanese is a cafe or restaurant.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "vocabulary"],
        "vocabularyCategoryIds": ["food", "drinks", "money", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-117-excuse-me-cafe", "title": "Get the staff's attention", "mode": "repeat", "demoPhrase": "sumimasen", "replyPrompt": "Say sumimasen once politely.", "targetPattern": "cafe opening", "learnerOutcome": "Learner can get attention politely before ordering.", "acceptableResponses": ["sumimasen", "すみません"] },
        { "id": "n5-lesson-118-water-and-food", "title": "Ask for water and food", "mode": "speaking", "demoPhrase": "mizu o kudasai. raamen o kudasai.", "replyPrompt": "Say the water and ramen requests once.", "targetPattern": "request food politely", "learnerOutcome": "Learner can order simple items in a cafe or restaurant.", "acceptableResponses": ["mizu o kudasai", "raamen o kudasai"] },
        { "id": "n5-lesson-119-price-and-reaction", "title": "Ask the price and react", "mode": "speaking", "demoPhrase": "kore wa ikura desu ka. oishii desu.", "replyPrompt": "Say the price question and reaction once.", "targetPattern": "price and opinion", "learnerOutcome": "Learner can ask for a price and react politely to food.", "acceptableResponses": ["kore wa ikura desu ka", "oishii desu"] }
      ]
    },
    {
      "id": "n5-module-26-directions",
      "title": "Directions",
      "objective": "Teach how to ask where a place is and understand basic direction words used in reply.",
      "checkpointLabel": "Direction check",
      "rewardBadge": "Direction Master",
      "rewardXp": 20,
      "coverage": ["Excuse me", "Where is the station", "Straight", "Right", "Thank you"],
      "missionTitle": "Mission 26: Ask where the station is",
      "storyHook": "Directions are a classic confidence-builder because the language is short, practical, and highly reusable.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "vocabulary"],
        "vocabularyCategoryIds": ["direction-words", "places", "travel-words"]
      },
      "lessons": [
        { "id": "n5-lesson-120-ask-station", "title": "Ask where the station is", "mode": "speaking", "demoPhrase": "eki wa doko desu ka", "replyPrompt": "Ask where the station is once.", "targetPattern": "location question", "learnerOutcome": "Learner can ask for the station using one compact survival line.", "acceptableResponses": ["eki wa doko desu ka", "えきは どこですか"] },
        { "id": "n5-lesson-121-basic-direction-words", "title": "Basic direction words", "mode": "repeat", "demoPhrase": "massugu desu. migi desu.", "replyPrompt": "Say 'straight' and 'right' once.", "targetPattern": "direction words", "learnerOutcome": "Learner understands the first core direction replies.", "acceptableResponses": ["massugu desu", "migi desu"] },
        { "id": "n5-lesson-122-direction-dialogue", "title": "Direction mini-dialogue", "mode": "roleplay", "demoPhrase": "sumimasen. eki wa doko desu ka. arigatou gozaimasu.", "replyPrompt": "Say the mini direction dialogue once.", "targetPattern": "direction roleplay", "learnerOutcome": "Learner can complete a short directions exchange from start to finish.", "acceptableResponses": ["sumimasen", "eki wa doko desu ka", "arigatou gozaimasu"] }
      ]
    },
    {
      "id": "n5-module-27-shopping",
      "title": "Shopping",
      "objective": "Teach the lines needed to ask a price, choose an item, and confirm payment in a store.",
      "checkpointLabel": "Shopping check",
      "rewardBadge": "Shopping Samurai",
      "rewardXp": 20,
      "coverage": ["How much is this", "I will take this", "Card okay", "Shop conversation"],
      "missionTitle": "Mission 27: Buy something in Japanese",
      "storyHook": "Shopping Japanese is one of the first places where numbers, politeness, and object words all come together.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "numbers", "vocabulary"],
        "vocabularyCategoryIds": ["shopping-words", "money", "everyday-objects", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-123-shopping-price", "title": "Ask the price", "mode": "speaking", "demoPhrase": "kore wa ikura desu ka", "replyPrompt": "Ask the price once in Japanese.", "targetPattern": "shopping question", "learnerOutcome": "Learner can ask for a price naturally in a store.", "acceptableResponses": ["kore wa ikura desu ka"] },
        { "id": "n5-lesson-124-shopping-buy", "title": "I will take this", "mode": "speaking", "demoPhrase": "kore o kudasai", "replyPrompt": "Say 'I will take this' once.", "targetPattern": "purchase line", "learnerOutcome": "Learner can choose an item politely and directly.", "acceptableResponses": ["kore o kudasai", "これをください"] },
        { "id": "n5-lesson-125-shopping-payment", "title": "Ask about card payment", "mode": "speaking", "demoPhrase": "kaado wa daijoubu desu ka", "replyPrompt": "Ask if card is okay once.", "targetPattern": "payment question", "learnerOutcome": "Learner can ask about payment in a simple practical line.", "acceptableResponses": ["kaado wa daijoubu desu ka"] }
      ]
    },
    {
      "id": "n5-module-28-daily-routine",
      "title": "Daily Routine",
      "objective": "Let the learner talk about waking up, eating breakfast, studying, and simple schedule habits.",
      "checkpointLabel": "Daily routine check",
      "rewardBadge": "Routine Builder",
      "rewardXp": 20,
      "coverage": ["Wake up time", "Breakfast", "Study", "Daily action flow"],
      "missionTitle": "Mission 28: Talk about your day",
      "storyHook": "Daily routine Japanese is where beginner grammar starts sounding like real life.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "numbers", "grammar"],
        "vocabularyCategoryIds": ["time-expressions", "house-words", "basic-verbs"]
      },
      "lessons": [
        { "id": "n5-lesson-126-wake-up-time", "title": "Wake up time", "mode": "speaking", "demoPhrase": "roku ji ni okimasu", "replyPrompt": "Say 'I wake up at 6' once.", "targetPattern": "daily time sentence", "learnerOutcome": "Learner can talk about waking up at a specific time.", "acceptableResponses": ["roku ji ni okimasu", "ろくじに おきます"] },
        { "id": "n5-lesson-127-breakfast", "title": "Breakfast", "mode": "speaking", "demoPhrase": "asagohan o tabemasu", "replyPrompt": "Say 'I eat breakfast' once.", "targetPattern": "routine action", "learnerOutcome": "Learner can describe a basic eating habit.", "acceptableResponses": ["asagohan o tabemasu"] },
        { "id": "n5-lesson-128-study-japanese", "title": "Study Japanese", "mode": "speaking", "demoPhrase": "nihongo o benkyou shimasu", "replyPrompt": "Say 'I study Japanese' once.", "targetPattern": "routine study sentence", "learnerOutcome": "Learner can speak about studying as part of a routine.", "acceptableResponses": ["nihongo o benkyou shimasu"] }
      ]
    },
    {
      "id": "n5-module-29-listening-practice",
      "title": "Listening Practice",
      "objective": "Train the learner to hear sounds, kana, words, numbers, and short lines without relying only on reading.",
      "checkpointLabel": "Listening mission check",
      "rewardBadge": "Listening Ladder",
      "rewardXp": 20,
      "coverage": ["Vowels", "Kana", "Words", "Numbers", "Mini conversations"],
      "missionTitle": "Mission 29: Understand what you hear",
      "storyHook": "A real beginner cannot only read; they must start reacting to spoken Japanese.",
      "resourceLinks": {
        "examSectionIds": ["listening", "sounds-romaji", "hiragana", "katakana", "numbers"],
        "vocabularyCategoryIds": ["greetings", "numbers", "question-words", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-129-hear-vowels", "title": "Hear a vowel and select it", "mode": "listening", "demoPhrase": "a, i, u, e, o", "replyPrompt": "Repeat the vowel line once after hearing it.", "targetPattern": "vowel listening", "learnerOutcome": "Learner begins reacting to heard vowels instead of only reading them.", "acceptableResponses": ["a i u e o", "aiueo"] },
        { "id": "n5-lesson-130-hear-kana", "title": "Hear kana and identify it", "mode": "listening", "demoPhrase": "さ, ね, コ, ジ", "replyPrompt": "Repeat the heard kana once.", "targetPattern": "kana listening", "learnerOutcome": "Learner can react to heard kana sounds and symbols with more confidence.", "acceptableResponses": ["sa", "ne", "ko", "ji"] },
        { "id": "n5-lesson-131-hear-words", "title": "Hear a word and choose the meaning", "mode": "listening", "demoPhrase": "mizu, eki, sensei", "replyPrompt": "Repeat the words once after hearing them.", "targetPattern": "word listening", "learnerOutcome": "Learner links heard words to useful N5 meanings quickly.", "acceptableResponses": ["mizu", "eki", "sensei"] },
        { "id": "n5-lesson-132-hear-mini-conversation", "title": "Hear a mini conversation", "mode": "listening", "demoPhrase": "ohayou gozaimasu. ohayou gozaimasu.", "replyPrompt": "Repeat the mini greeting exchange once.", "targetPattern": "mini conversation listening", "learnerOutcome": "Learner begins following a tiny live exchange from sound alone.", "acceptableResponses": ["ohayou gozaimasu"] }
      ]
    },
    {
      "id": "n5-module-30-speaking-practice",
      "title": "Speaking Practice",
      "objective": "Turn the learner into an active speaker through repetition, reading, answering, and short roleplay.",
      "checkpointLabel": "Speaking mission check",
      "rewardBadge": "Voice Builder",
      "rewardXp": 20,
      "coverage": ["Repeat sounds", "Read words", "Answer questions", "Roleplay"],
      "missionTitle": "Mission 30: Speak Japanese out loud",
      "storyHook": "This module is where the course fully becomes voice-first instead of text-first.",
      "resourceLinks": {
        "examSectionIds": ["speaking", "vocabulary", "numbers"],
        "vocabularyCategoryIds": ["greetings", "basic-expressions", "direction-words", "food", "people"]
      },
      "lessons": [
        { "id": "n5-lesson-133-repeat-sounds", "title": "Repeat vowels and kana sounds", "mode": "repeat", "demoPhrase": "a, i, u, e, o / ka, ki, ku, ke, ko", "replyPrompt": "Repeat the sounds once.", "targetPattern": "sound repetition", "learnerOutcome": "Learner can warm up the voice with clean beginner sound work.", "acceptableResponses": ["a i u e o", "ka ki ku ke ko"] },
        { "id": "n5-lesson-134-read-words", "title": "Read words aloud", "mode": "speaking", "demoPhrase": "sushi, mizu, nihon, hoteru", "replyPrompt": "Read the four words aloud once.", "targetPattern": "word reading aloud", "learnerOutcome": "Learner turns reading into active speech quickly.", "acceptableResponses": ["sushi", "mizu", "nihon", "hoteru"] },
        { "id": "n5-lesson-135-answer-ai-questions", "title": "Answer AI questions", "mode": "speaking", "demoPhrase": "anata wa gakusei desu ka", "replyPrompt": "Answer the question once in Japanese.", "targetPattern": "short spoken answer", "learnerOutcome": "Learner begins answering instead of only repeating.", "acceptableResponses": ["hai sou desu", "iie chigaimasu"] },
        { "id": "n5-lesson-136-short-roleplay", "title": "Short roleplay", "mode": "roleplay", "demoPhrase": "mizu o kudasai", "replyPrompt": "Use the food request once in a short roleplay.", "targetPattern": "roleplay response", "learnerOutcome": "Learner uses a practical line in a real spoken mini-scene.", "acceptableResponses": ["mizu o kudasai"] }
      ]
    },
    {
      "id": "n5-module-31-reading-practice",
      "title": "Reading Practice",
      "objective": "Guide the learner from single kana into words, sentences, mixed-script items, and tiny paragraphs.",
      "checkpointLabel": "Reading mission check",
      "rewardBadge": "Reading Ladder",
      "rewardXp": 20,
      "coverage": ["Single kana", "Words", "Katakana", "Kanji words", "Sentences", "Tiny paragraphs"],
      "missionTitle": "Mission 31: Read what Japan puts in front of you",
      "storyHook": "Reading becomes exciting once the learner can climb from tiny symbols to meaningful lines.",
      "resourceLinks": {
        "examSectionIds": ["reading", "hiragana", "katakana", "kanji"],
        "kanjiGroupIds": ["kanji-numbers-money", "kanji-directions-places", "kanji-people-relations"],
        "vocabularyCategoryIds": ["greetings", "transportation", "school-words", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-137-single-kana", "title": "Single kana reading", "mode": "speaking", "demoPhrase": "あ, い, う, え, お", "replyPrompt": "Read the single kana once.", "targetPattern": "single kana reading", "learnerOutcome": "Learner reads simple kana with direct visual confidence.", "acceptableResponses": ["あいうえお", "a i u e o"] },
        { "id": "n5-lesson-138-word-reading", "title": "Hiragana word reading", "mode": "speaking", "demoPhrase": "ねこ, いぬ, すし", "replyPrompt": "Read the hiragana words once.", "targetPattern": "hiragana word reading", "learnerOutcome": "Learner can read simple hiragana words aloud.", "acceptableResponses": ["ねこ", "いぬ", "すし"] },
        { "id": "n5-lesson-139-katakana-word-reading", "title": "Katakana word reading", "mode": "speaking", "demoPhrase": "ホテル, コーヒー, インド", "replyPrompt": "Read the katakana words once.", "targetPattern": "katakana word reading", "learnerOutcome": "Learner can read common katakana words used in daily life.", "acceptableResponses": ["ホテル", "コーヒー", "インド"] },
        { "id": "n5-lesson-140-kanji-word-reading", "title": "Kanji word reading", "mode": "speaking", "demoPhrase": "日本, 学生, 先生, 駅", "replyPrompt": "Read the kanji words once.", "targetPattern": "kanji word reading", "learnerOutcome": "Learner reads the most useful beginner kanji compounds aloud.", "acceptableResponses": ["にほん", "がくせい", "せんせい", "えき"] },
        { "id": "n5-lesson-141-short-sentence-reading", "title": "Short sentence reading", "mode": "speaking", "demoPhrase": "これは ほんです。わたしは がくせいです。", "replyPrompt": "Read the two short sentences once.", "targetPattern": "sentence reading", "learnerOutcome": "Learner can read short complete N5-level lines with calm pacing.", "acceptableResponses": ["これは ほんです", "わたしは がくせいです"] },
        { "id": "n5-lesson-142-tiny-paragraph-reading", "title": "Tiny paragraph reading", "mode": "speaking", "demoPhrase": "わたしは ラフルです。インドからきました。にほんごをべんきょうしています。", "replyPrompt": "Read the tiny paragraph once.", "targetPattern": "paragraph reading", "learnerOutcome": "Learner crosses into short multi-sentence reading with spoken confidence.", "acceptableResponses": ["わたしは ラフルです", "インドからきました", "にほんごをべんきょうしています"] }
      ]
    },
    {
      "id": "n5-module-32-final-exam",
      "title": "Final N5 Certificate Exam",
      "objective": "Review the full course and run the integrated final exam that proves beginner speaking, reading, listening, and grammar readiness.",
      "checkpointLabel": "N5 certificate gate",
      "rewardBadge": "N5 Champion",
      "rewardXp": 100,
      "coverage": ["Sounds", "Kana", "Numbers", "Vocabulary", "Particles", "Verb forms", "Adjectives", "Grammar", "Counters", "Kanji", "Listening", "Reading", "Speaking"],
      "missionTitle": "Final Mission: Clear the N5 challenge",
      "storyHook": "Everything now comes together in one calm but real beginner-level Japanese challenge.",
      "resourceLinks": {
        "examSectionIds": ["sounds-romaji", "hiragana", "katakana", "special-kana", "numbers", "vocabulary", "particles", "verbs-adjectives", "grammar", "counters", "kanji", "listening", "reading", "speaking"],
        "kanjiGroupIds": ["kanji-numbers-money", "kanji-time-nature", "kanji-directions-places", "kanji-people-relations", "kanji-actions", "kanji-objects-environment"],
        "vocabularyCategoryIds": ["greetings", "classroom-japanese", "time-expressions", "weekdays", "months-dates", "numbers", "money", "family", "people", "jobs", "countries", "languages", "food", "drinks", "places", "buildings", "transportation", "everyday-objects", "clothing", "weather", "nature", "body-parts", "colors", "basic-verbs", "basic-adjectives", "shopping-words", "direction-words", "school-words", "house-words", "travel-words", "question-words", "common-adverbs", "basic-expressions"]
      },
      "lessons": [
        { "id": "n5-lesson-143-final-sound-check", "title": "Sound and kana review", "mode": "checkpoint", "demoPhrase": "a, i, u, e, o / hiragana / katakana", "replyPrompt": "Review the sound and kana systems once.", "targetPattern": "sound review", "learnerOutcome": "Learner proves they can still control the sound and script foundations.", "acceptableResponses": ["aiueo", "hiragana", "katakana"] },
        { "id": "n5-lesson-144-final-vocab-grammar", "title": "Vocabulary and grammar review", "mode": "checkpoint", "demoPhrase": "mizu o kudasai / watashi wa gakusei desu / nihon e ikitai desu", "replyPrompt": "Say the vocabulary and grammar lines once.", "targetPattern": "review lines", "learnerOutcome": "Learner proves core N5 vocabulary and grammar are usable in speech.", "acceptableResponses": ["mizu o kudasai", "watashi wa gakusei desu", "nihon e ikitai desu"] },
        { "id": "n5-lesson-145-final-reading-listening", "title": "Reading and listening review", "mode": "checkpoint", "demoPhrase": "日本 / こんばんは / さんびゃくえん", "replyPrompt": "Read or respond to the review prompts once.", "targetPattern": "reading listening review", "learnerOutcome": "Learner can handle mixed reading and listening prompts calmly.", "acceptableResponses": ["にほん", "こんばんは", "さんびゃくえん"] },
        { "id": "n5-lesson-146-final-speaking-roleplay", "title": "Final speaking roleplay", "mode": "roleplay", "demoPhrase": "hajimemashite. watashi wa Rahul desu. mizu o kudasai. eki wa doko desu ka.", "replyPrompt": "Complete the final speaking roleplay once.", "targetPattern": "integrated final speaking", "learnerOutcome": "Learner completes a true integrated N5 speaking loop across self-introduction, request, and direction help.", "acceptableResponses": ["hajimemashite", "watashi wa rahul desu", "mizu o kudasai", "eki wa doko desu ka"] }
      ]
    }
  ]
  $json$::jsonb;
begin
  for module_row in
    select value from jsonb_array_elements(modules)
  loop
    insert into public.curriculum_modules (
      id,
      language_slug,
      level_id,
      title,
      objective,
      checkpoint_label,
      support_language_hint,
      completion_state,
      reward_badge,
      reward_xp,
      coverage,
      mission_title,
      story_hook,
      progress_defaults,
      resource_links,
      sort_order
    )
    values (
      module_row->>'id',
      'japanese',
      'jp-n5',
      module_row->>'title',
      module_row->>'objective',
      module_row->>'checkpointLabel',
      support_hint,
      'not_started',
      module_row->>'rewardBadge',
      coalesce((module_row->>'rewardXp')::integer, 10),
      coalesce(module_row->'coverage', '[]'::jsonb),
      module_row->>'missionTitle',
      module_row->>'storyHook',
      jsonb_build_object(
        'state', 'not_started',
        'completedLessons', 0,
        'totalLessons', jsonb_array_length(module_row->'lessons')
      ),
      coalesce(module_row->'resourceLinks', '{}'::jsonb),
      module_sort
    )
    on conflict (id) do update set
      title = excluded.title,
      objective = excluded.objective,
      checkpoint_label = excluded.checkpoint_label,
      support_language_hint = excluded.support_language_hint,
      completion_state = excluded.completion_state,
      reward_badge = excluded.reward_badge,
      reward_xp = excluded.reward_xp,
      coverage = excluded.coverage,
      mission_title = excluded.mission_title,
      story_hook = excluded.story_hook,
      progress_defaults = excluded.progress_defaults,
      resource_links = excluded.resource_links,
      sort_order = excluded.sort_order;

    lesson_sort := 0;
    for lesson_row in
      select value from jsonb_array_elements(module_row->'lessons')
    loop
      insert into public.curriculum_lessons (
        id,
        language_slug,
        level_id,
        module_id,
        title,
        duration_minutes,
        mode,
        demo_phrase,
        reply_prompt,
        target_pattern,
        learner_outcome,
        acceptable_responses,
        turns,
        feedback,
        sort_order
      )
      values (
        lesson_row->>'id',
        'japanese',
        'jp-n5',
        module_row->>'id',
        lesson_row->>'title',
        18,
        lesson_row->>'mode',
        lesson_row->>'demoPhrase',
        lesson_row->>'replyPrompt',
        lesson_row->>'targetPattern',
        lesson_row->>'learnerOutcome',
        coalesce(lesson_row->'acceptableResponses', jsonb_build_array(lesson_row->>'demoPhrase')),
        jsonb_build_array(
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-warm-up',
            'label', 'Warm-up',
            'type', 'warm_up',
            'prompt', 'Start with a short confidence reset and remind the learner what they are about to say.',
            'supportNote', 'Keep the explanation calm, brief, and confidence-building.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-model',
            'label', 'AI models the phrase',
            'type', 'ai_model',
            'prompt', 'Model ' || (lesson_row->>'demoPhrase') || ' clearly and keep the learner focused on practical spoken use.',
            'supportNote', 'The AI says it naturally first, then once more slowly.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-repeat',
            'label', 'Learner repeats',
            'type', 'learner_repeat',
            'prompt', 'Learner answers by voice. The goal is speaking frequently, not reading long explanations.',
            'supportNote', 'Capture pronunciation, timing, and confidence on the first attempt.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-feedback',
            'label', 'Instant feedback',
            'type', 'feedback',
            'prompt', 'Give one short correction in plain English, then return to speaking.',
            'supportNote', 'Keep corrections warm, practical, and short so the learner stays in motion.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-retry',
            'label', 'Retry',
            'type', 'retry',
            'prompt', 'Ask for one cleaner retry only when needed so the lesson keeps momentum.',
            'supportNote', 'Prioritize clarity and confidence over perfection.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-guided',
            'label', 'Guided prompt-response',
            'type', 'guided_prompt',
            'prompt', 'Ask the learner to use ' || (lesson_row->>'demoPhrase') || ' once more inside one small beginner-safe response.',
            'supportNote', 'Move from mimicry into real communication quickly.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-checkpoint',
            'label', 'Module checkpoint',
            'type', 'checkpoint',
            'prompt', 'Confirm the learner can complete ' || (lesson_row->>'title') || ' before moving on.',
            'supportNote', 'Use a short spoken check before advancing progress.'
          ),
          jsonb_build_object(
            'id', (lesson_row->>'id') || '-summary',
            'label', 'Lesson summary',
            'type', 'summary',
            'prompt', 'End with a short spoken recap, what improved, and what to remember next.',
            'supportNote', 'Keep the closeout concise so the lesson still feels live.'
          )
        ),
        feedback,
        lesson_sort
      )
      on conflict (id) do update set
        title = excluded.title,
        duration_minutes = excluded.duration_minutes,
        mode = excluded.mode,
        demo_phrase = excluded.demo_phrase,
        reply_prompt = excluded.reply_prompt,
        target_pattern = excluded.target_pattern,
        learner_outcome = excluded.learner_outcome,
        acceptable_responses = excluded.acceptable_responses,
        turns = excluded.turns,
        feedback = excluded.feedback,
        sort_order = excluded.sort_order;

      lesson_sort := lesson_sort + 1;
    end loop;

    module_sort := module_sort + 1;
  end loop;
end $$;

commit;
