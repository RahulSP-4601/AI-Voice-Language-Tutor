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
export const CHECKPOINT_PASS_SCORE = 5;

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

function buildMeaningQuestion(
  items: PracticeCard[],
  promptIndex: number,
  optionStart: number,
) {
  const promptItem = items[promptIndex];
  const options = rotate(items, optionStart, 4).map((item) => item.english);
  return {
    answer: promptItem.english,
    options,
    prompt: `What does ${promptItem.japanese} mean?`,
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
        buildMeaningQuestion(chunk, 0, 0),
        buildMeaningQuestion(chunk, 2, 1),
        buildMeaningQuestion(chunk, 4, 2),
        buildMeaningQuestion(chunk, 6, 3),
        buildMeaningQuestion(chunk, 8, 4),
      ],
      title: `Checkpoint ${chunkIndex + 1}`,
    } satisfies PracticeQuizCheckpoint;
  }

  return null;
}
