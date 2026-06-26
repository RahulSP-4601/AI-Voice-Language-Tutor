import { type ExamSection } from "@/lib/course-types";

function section(
  id: string,
  title: string,
  coverage: string[],
  questionTypes: string[],
  passSignal: string,
): ExamSection {
  return { coverage, id, passSignal, questionTypes, title };
}

export const japaneseExamDataset = [
  section(
    "sounds-romaji",
    "Section 1: Romaji and Japanese Sounds",
    ["Romaji bridge", "Vowels", "Sound rows", "Long sounds", "Small pause sounds"],
    ["Repeat the sound", "Select the matching sound", "Short spoken correction"],
    "Learner can hear and repeat the key sound system with stable timing.",
  ),
  section(
    "hiragana",
    "Section 2: Hiragana",
    ["46 basic hiragana", "Reading practice", "Writing awareness"],
    ["Read the row aloud", "Read a word", "Identify the character"],
    "Learner can read the full basic hiragana set with confidence.",
  ),
  section(
    "katakana",
    "Section 3: Katakana",
    ["46 basic katakana", "Loanword reading", "Travel and cafe words"],
    ["Read the word aloud", "Match the word to meaning", "Select the heard script"],
    "Learner can read core katakana words with practical confidence.",
  ),
  section(
    "special-kana",
    "Section 4: Kana Special Sounds",
    ["Dakuon", "Handakuon", "Yoon", "Sokuon", "Choun"],
    ["Repeat the contrast pair", "Spot the sound difference", "Read the special-sound word"],
    "Learner can handle the special kana timing and sound shifts.",
  ),
  section(
    "numbers",
    "Section 5: Numbers",
    ["0 to 100", "100 to 10,000", "Money", "Time", "Age", "Dates"],
    ["Count aloud", "Answer the price", "Say the time", "Answer the age question"],
    "Learner answers practical number prompts accurately and naturally.",
  ),
  section(
    "vocabulary",
    "Section 6: Vocabulary",
    ["Core N5 categories", "Daily-use words", "Phrase-level vocabulary"],
    ["Choose the meaning", "Say the target word", "Complete the phrase"],
    "Learner can use essential words inside simple real-life phrases.",
  ),
  section(
    "particles",
    "Section 7: Particles",
    ["は", "が", "を", "に", "で", "と", "の", "も"],
    ["Complete the sentence", "Say the line aloud", "Choose the best particle"],
    "Learner uses the most important particles in practical lines.",
  ),
  section(
    "verbs-adjectives",
    "Section 8: Verb and Adjective Conjugation",
    ["ます", "ません", "ました", "ませんでした", "Dictionary form", "Nai form", "Ta form", "Te form", "い-adjectives", "な-adjectives"],
    ["Change the form", "Repeat the line", "Answer in the target form"],
    "Learner recognizes and produces the main N5 beginner forms.",
  ),
  section(
    "grammar",
    "Section 9: Grammar Patterns",
    ["てください", "てもいいです", "ています", "たいです", "がほしいです", "ながら", "つもりです", "から", "とおもいます"],
    ["Use the pattern in a sentence", "Respond to the prompt", "Choose the best completion"],
    "Learner can respond with several core N5 sentence patterns.",
  ),
  section(
    "counters",
    "Section 10: Counters",
    ["General items", "People", "Books", "Machines", "Times", "Floors", "Age", "Animals"],
    ["Count the objects", "Answer how many people", "Say the correct counter aloud"],
    "Learner uses the most common counters with clear structure.",
  ),
  section(
    "kanji",
    "Section 11: Kanji",
    ["103 essential kanji", "Numbers", "Time", "People", "Actions", "Objects"],
    ["Read the kanji word", "Match kanji to meaning", "Choose the correct reading"],
    "Learner recognizes the essential N5 kanji set in useful words.",
  ),
  section(
    "listening",
    "Section 12: Listening",
    ["Words", "Numbers", "Sentences", "Mini conversations"],
    ["Listen and choose", "Repeat what you heard", "Answer the simple follow-up"],
    "Learner can catch basic spoken Japanese without relying on heavy text support.",
  ),
  section(
    "reading",
    "Section 13: Reading",
    ["Hiragana words", "Katakana words", "Kanji words", "Short sentences", "Tiny paragraphs"],
    ["Read aloud", "Choose the meaning", "Answer a tiny reading question"],
    "Learner reads short N5-level Japanese with calm and usable comprehension.",
  ),
  section(
    "speaking",
    "Section 14: Speaking",
    ["Self introduction", "Ordering food", "Asking directions", "Shopping", "Daily routine"],
    ["Guided roleplay", "Prompt response", "Integrated conversation task"],
    "Learner completes the final N5 speaking loop across real-life scenarios.",
  ),
] as const;
