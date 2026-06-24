"use client";

import { useEffect, useState } from "react";
import {
  type CompletionState,
  type CourseLesson,
  type CourseSlug,
} from "@/lib/course-definitions";
import { useLessonSpeech } from "@/components/use-lesson-speech";

type LessonRunnerProps = {
  currentTurn: number;
  lastTranscript: string;
  lesson: CourseLesson;
  moduleState: CompletionState;
  onComplete: () => void;
  onStart: () => void;
  onTurnChange: (turn: number) => void;
  onTranscriptChange: (value: string) => void;
  slug: CourseSlug;
};

function normalizeText(value: string) {
  return value.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, "").trim();
}

function matchesResponse(
  transcript: string,
  acceptableResponses: string[],
) {
  const normalized = normalizeText(transcript);
  return acceptableResponses.some((value) => {
    const target = normalizeText(value);
    return normalized.includes(target) || target.includes(normalized);
  });
}

function LessonActionButton(props: {
  label: string;
  muted?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={props.onClick}
      className={`rounded-full border px-4 py-2 text-sm font-medium transition ${
        props.muted
          ? "border-white/10 bg-white/[0.04] text-stone-200 hover:bg-white/[0.08]"
          : "border-amber-300/20 bg-amber-300/12 text-amber-100 hover:bg-amber-300/18"
      }`}
    >
      {props.label}
    </button>
  );
}

function StepCard(props: {
  currentIndex: number;
  lesson: CourseLesson;
}) {
  const step = props.lesson.turns[props.currentIndex];

  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Step {props.currentIndex + 1} of {props.lesson.turns.length}
      </p>
      <h3 className="mt-4 text-2xl font-semibold text-white">{step.label}</h3>
      <p className="mt-4 text-base leading-8 text-stone-200">{step.prompt}</p>
      <p className="mt-3 text-sm leading-6 text-stone-400">
        {step.supportNote}
      </p>
    </div>
  );
}

function PracticeCard(props: {
  isListening: boolean;
  lesson: CourseLesson;
  moduleState: CompletionState;
  onListen: () => void;
  onPlay: () => void;
  transcript: string;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        Practice
      </p>
      <p className="mt-4 text-sm uppercase tracking-[0.2em] text-stone-400">
        Tutor phrase
      </p>
      <p className="mt-2 text-2xl font-semibold text-white">
        {props.lesson.demoPhrase}
      </p>
      <p className="mt-5 text-sm uppercase tracking-[0.2em] text-stone-400">
        Your goal
      </p>
      <p className="mt-2 text-base leading-7 text-stone-200">
        {props.lesson.replyPrompt}
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <LessonActionButton label="Play tutor line" onClick={props.onPlay} />
        <LessonActionButton
          label={props.isListening ? "Listening..." : "Record my answer"}
          muted={!props.isListening && props.moduleState === "not_started"}
          onClick={props.onListen}
        />
      </div>
      <div className="mt-5 rounded-2xl bg-white/[0.04] px-4 py-3">
        <p className="text-xs uppercase tracking-[0.2em] text-stone-400">
          Last transcript
        </p>
        <p className="mt-2 text-sm leading-6 text-white">
          {props.transcript || "No voice capture yet. You can still continue manually after practicing aloud."}
        </p>
      </div>
    </div>
  );
}

function FeedbackCard(props: {
  lesson: CourseLesson;
  transcript: string;
}) {
  const matched = matchesResponse(
    props.transcript,
    props.lesson.acceptableResponses,
  );
  const hasTranscript = props.transcript.trim().length > 0;

  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Coaching feedback
      </p>
      <p className="mt-4 text-sm leading-7 text-stone-200">
        {hasTranscript
          ? matched
            ? "Nice. Your answer is close to the lesson goal. Keep the same rhythm and move forward."
            : lessonHint(props.lesson)
          : "Practice the phrase aloud first. If browser voice capture is unavailable, continue after you speak on your own once or twice."}
      </p>
      <div className="mt-5 space-y-3">
        <MetaRow label="Focus" value={props.lesson.feedback.focus} />
        <MetaRow label="Retry cue" value={props.lesson.feedback.retryCue} />
      </div>
    </div>
  );
}

function MetaRow(props: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-white/[0.04] px-4 py-3">
      <p className="text-xs uppercase tracking-[0.2em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-2 text-sm leading-6 text-white">{props.value}</p>
    </div>
  );
}

function lessonHint(lesson: CourseLesson) {
  return `${lesson.feedback.correctionStyle} Target something close to “${lesson.demoPhrase}” and try once more.`;
}

export function LessonRunner(props: LessonRunnerProps) {
  const runner = useLessonRunnerState(props);
  return <LessonRunnerBody {...props} {...runner} />;
}

function useLessonRunnerState(props: LessonRunnerProps) {
  const [currentTurn, setCurrentTurn] = useState(props.currentTurn);
  const [transcript, setTranscript] = useState(props.lastTranscript);
  const { isListening, playPhrase, startListening, supported } = useLessonSpeech(
    props.slug,
    setTranscript,
  );

  useEffect(() => props.onTurnChange(currentTurn), [currentTurn, props]);
  useEffect(() => props.onTranscriptChange(transcript), [props, transcript]);

  function startLesson() {
    props.onStart();
    setCurrentTurn(0);
  }

  function advanceTurn() {
    if (currentTurn >= props.lesson.turns.length - 1) {
      props.onComplete();
      return;
    }

    setCurrentTurn((value) => value + 1);
  }

  return {
    advanceTurn,
    currentTurn,
    isListening,
    playTutorLine: () => playPhrase(props.lesson.demoPhrase),
    startLesson,
    startListening,
    supported,
    transcript,
  };
}

function LessonRunnerBody(
  props: LessonRunnerProps & {
    advanceTurn: () => void;
    currentTurn: number;
    isListening: boolean;
    playTutorLine: () => void;
    startLesson: () => void;
    startListening: () => void;
    supported: boolean;
    transcript: string;
  },
) {
  return (
    <div className="space-y-4">
      <LessonRunnerActions
        moduleState={props.moduleState}
        isListening={props.isListening}
        supported={props.supported}
        onAdvance={props.advanceTurn}
        onPlay={props.playTutorLine}
        onStart={props.startLesson}
        onListen={props.startListening}
      />
      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_minmax(320px,0.72fr)]">
        <StepCard currentIndex={props.currentTurn} lesson={props.lesson} />
        <div className="space-y-4">
          <PracticeCard
            lesson={props.lesson}
            moduleState={props.moduleState}
            isListening={props.isListening}
            onListen={props.supported ? props.startListening : props.playTutorLine}
            onPlay={props.playTutorLine}
            transcript={props.transcript}
          />
          <FeedbackCard lesson={props.lesson} transcript={props.transcript} />
        </div>
      </div>
    </div>
  );
}

function LessonRunnerActions(props: {
  isListening: boolean;
  moduleState: CompletionState;
  onAdvance: () => void;
  onListen: () => void;
  onPlay: () => void;
  onStart: () => void;
  supported: boolean;
}) {
  return (
    <div className="flex flex-wrap gap-3">
      {props.moduleState === "not_started" ? (
        <LessonActionButton label="Start lesson" onClick={props.onStart} />
      ) : null}
      <LessonActionButton label="Next step" onClick={props.onAdvance} />
      <LessonActionButton label="Play tutor line" muted onClick={props.onPlay} />
      {props.supported ? (
        <LessonActionButton
          label={props.isListening ? "Listening..." : "Record my answer"}
          muted={props.isListening}
          onClick={props.onListen}
        />
      ) : null}
    </div>
  );
}
