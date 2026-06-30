import { type StoredPracticeItemProgress } from "@/lib/course-progress";
import { type PracticeCard } from "@/lib/module-practice";

export type PracticeQuizQuestion = {
  answer: string;
  options: string[];
  prompt: string;
};

export type PracticeQuizCheckpoint = {
  chunkEnd: number;
  chunkIndex: number;
  id: string;
  passScore: number;
  questions: PracticeQuizQuestion[];
  title: string;
};

const CHECKPOINT_SIZE = 10;
export const CHECKPOINT_QUESTION_COUNT = 5;
export const CHECKPOINT_PASS_SCORE = 4;

function chunkItems(items: PracticeCard[], chunkIndex: number) {
  const start = chunkIndex * CHECKPOINT_SIZE;
  return items.slice(start, start + CHECKPOINT_SIZE);
}

function checkpointId(chunkIndex: number) {
  return `quiz:checkpoint:${chunkIndex + 1}`;
}

function rotate<T>(items: T[], start: number, count: number) {
  if (items.length <= count) {
    return items;
  }

  return Array.from({ length: count }, (_, index) => items[(start + index) % items.length]);
}

function buildMeaningQuestion(items: PracticeCard[]) {
  const promptItem = items[0];
  const options = rotate(items, 0, 4).map((item) => item.english);
  return {
    answer: promptItem.english,
    options,
    prompt: `What does ${promptItem.japanese} mean?`,
  } satisfies PracticeQuizQuestion;
}

function buildReadingQuestion(items: PracticeCard[]) {
  const promptItem = items[Math.min(3, items.length - 1)];
  const options = rotate(items, 2, 4).map((item) => item.reading);
  return {
    answer: promptItem.reading,
    options,
    prompt: `Which reading matches ${promptItem.japanese}?`,
  } satisfies PracticeQuizQuestion;
}

function buildJapaneseQuestion(items: PracticeCard[]) {
  const promptItem = items[Math.min(6, items.length - 1)];
  const options = rotate(items, 4, 4).map((item) => item.japanese);
  return {
    answer: promptItem.japanese,
    options,
    prompt: `Which word means “${promptItem.english}”?`,
  } satisfies PracticeQuizQuestion;
}

function buildEnglishFromReadingQuestion(items: PracticeCard[]) {
  const promptItem = items[Math.min(8, items.length - 1)];
  const options = rotate(items, 1, 4).map((item) => item.english);
  return {
    answer: promptItem.english,
    options,
    prompt: `What does ${promptItem.reading} mean?`,
  } satisfies PracticeQuizQuestion;
}

function buildReadingFromEnglishQuestion(items: PracticeCard[]) {
  const promptItem = items[Math.min(9, items.length - 1)];
  const options = rotate(items, 5, 4).map((item) => item.reading);
  return {
    answer: promptItem.reading,
    options,
    prompt: `Which reading matches “${promptItem.english}”?`,
  } satisfies PracticeQuizQuestion;
}

export function getPendingCheckpointQuiz(
  items: PracticeCard[],
  progress: Record<string, StoredPracticeItemProgress>,
) {
  const doneCount = items.filter((item) => progress[item.id]?.done).length;
  const completedChunkCount = Math.floor(doneCount / CHECKPOINT_SIZE);

  for (let chunkIndex = 0; chunkIndex < completedChunkCount; chunkIndex += 1) {
    const id = checkpointId(chunkIndex);
    if (progress[id]?.done) {
      continue;
    }

    const chunk = chunkItems(items, chunkIndex);
    if (chunk.length < 4) {
      return null;
    }

    return {
      chunkEnd: (chunkIndex + 1) * CHECKPOINT_SIZE,
      chunkIndex,
      id,
      passScore: CHECKPOINT_PASS_SCORE,
      questions: [
        buildMeaningQuestion(chunk),
        buildReadingQuestion(chunk),
        buildJapaneseQuestion(chunk),
        buildEnglishFromReadingQuestion(chunk),
        buildReadingFromEnglishQuestion(chunk),
      ],
      title: `Checkpoint ${chunkIndex + 1}`,
    } satisfies PracticeQuizCheckpoint;
  }

  return null;
}
