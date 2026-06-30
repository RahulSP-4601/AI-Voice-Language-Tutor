"use client";

import { useState } from "react";
import {
  CHECKPOINT_QUESTION_COUNT,
  type PracticeQuizCheckpoint,
} from "@/lib/practice-checkpoint-quiz";

type AnswerState = {
  correct: boolean;
  value: string;
};

function getOptionClass(option: string, selected?: AnswerState) {
  if (!selected) {
    return "border-white/10 bg-white/[0.03] text-stone-200 hover:bg-white/[0.06]";
  }

  if (selected.value === option) {
    return selected.correct
      ? "border-emerald-300/30 bg-emerald-400/15 text-emerald-50"
      : "border-rose-300/30 bg-rose-400/15 text-rose-50";
  }

  return "border-white/10 bg-white/[0.03] text-stone-500";
}

function buildAnswerState(answer: string, value: string) {
  return {
    correct: value === answer,
    value,
  } satisfies AnswerState;
}

function QuestionBlock(props: {
  index: number;
  onPick: (value: string) => void;
  question: PracticeQuizCheckpoint["questions"][number];
  selected?: AnswerState;
}) {
  return (
    <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
      <p className="text-xs uppercase tracking-[0.18em] text-stone-400">
        Question {props.index + 1}
      </p>
      <p className="mt-3 text-base text-stone-100">{props.question.prompt}</p>
      <div className="mt-4 grid gap-2 sm:grid-cols-2">
        {props.question.options.map((option) => (
          <button
            key={option}
            type="button"
            onClick={() => props.onPick(option)}
            disabled={props.selected?.correct}
            className={`rounded-2xl border px-4 py-3 text-left text-sm transition ${getOptionClass(option, props.selected)}`}
          >
            {option}
          </button>
        ))}
      </div>
      {props.selected ? (
        <p
          className={`mt-3 text-sm ${
            props.selected.correct ? "text-emerald-200" : "text-rose-200"
          }`}
        >
          {props.selected.correct
            ? "Correct answer."
            : "Wrong answer. Try again."}
        </p>
      ) : null}
    </div>
  );
}

function CheckpointHeader(props: { checkpoint: PracticeQuizCheckpoint }) {
  return (
    <div>
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        {props.checkpoint.title}
      </p>
      <h3 className="mt-3 text-2xl font-semibold text-white">
        Quick test after {props.checkpoint.chunkEnd} words
      </h3>
      <p className="mt-3 text-sm leading-7 text-stone-200">
        Answer these {CHECKPOINT_QUESTION_COUNT} MCQs. All {props.checkpoint.passScore} must be right to unlock the next group.
      </p>
    </div>
  );
}

function ActionButton(props: {
  disabled?: boolean;
  onClick: () => void;
  tone: "primary" | "secondary";
  label: string;
}) {
  return (
    <button
      type="button"
      disabled={props.disabled}
      onClick={props.onClick}
      className={`rounded-full border px-5 py-3 text-sm font-medium transition ${
        props.disabled
          ? "cursor-not-allowed border-white/10 bg-white/[0.04] text-stone-400"
          : props.tone === "primary"
            ? "border-emerald-300/25 bg-emerald-400/18 text-emerald-100 hover:bg-emerald-400/24"
            : "border-white/10 bg-white/[0.03] text-stone-200 hover:bg-white/[0.06]"
      }`}
    >
      {props.label}
    </button>
  );
}

function CheckpointActions(props: {
  allCorrect: boolean;
  onReset: () => void;
  onSubmit: () => void;
}) {
  return (
    <div className="flex flex-wrap gap-3">
      <ActionButton label="Retake quiz" onClick={props.onReset} tone="secondary" />
      <ActionButton
        disabled={!props.allCorrect}
        label="Unlock next group"
        onClick={props.onSubmit}
        tone="primary"
      />
    </div>
  );
}

function QuizQuestionList(props: {
  answers: Array<AnswerState | undefined>;
  checkpoint: PracticeQuizCheckpoint;
  onPick: (index: number, value: string) => void;
}) {
  return (
    <div className="space-y-3">
      {props.checkpoint.questions.map((question, index) => (
        <QuestionBlock
          key={question.prompt}
          index={index}
          onPick={(value) => props.onPick(index, value)}
          question={question}
          selected={props.answers[index]}
        />
      ))}
    </div>
  );
}

export function PracticeCheckpointCard(props: {
  checkpoint: PracticeQuizCheckpoint;
  onSubmit: (score: number) => void;
}) {
  const [answers, setAnswers] = useState<Array<AnswerState | undefined>>(() =>
    props.checkpoint.questions.map(() => undefined),
  );

  function updateAnswer(index: number, value: string) {
    setAnswers((current) =>
      current.map((item, itemIndex) =>
        itemIndex === index
          ? buildAnswerState(props.checkpoint.questions[index]?.answer ?? "", value)
          : item,
      ),
    );
  }

  function resetQuiz() {
    setAnswers(props.checkpoint.questions.map(() => undefined));
  }

  function submitQuiz() {
    const correct = answers.filter((item) => item?.correct).length;
    props.onSubmit(correct);
  }

  const allCorrect = answers.every((item) => item?.correct);

  return (
    <div className="space-y-4 rounded-[1.6rem] border border-emerald-400/12 bg-[linear-gradient(135deg,rgba(16,185,129,0.08),rgba(255,255,255,0.03))] p-6">
      <CheckpointHeader checkpoint={props.checkpoint} />
      <QuizQuestionList
        answers={answers}
        checkpoint={props.checkpoint}
        onPick={updateAnswer}
      />
      <CheckpointActions
        allCorrect={allCorrect}
        onReset={resetQuiz}
        onSubmit={submitQuiz}
      />
    </div>
  );
}
