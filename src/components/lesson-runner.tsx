"use client";

import { type Dispatch, type SetStateAction, useEffect, useState } from "react";
import {
  type CompletionState,
  type CourseLesson,
  type CourseSlug,
  type LessonEvaluation,
} from "@/lib/course-definitions";
import { useAudioRecorder } from "@/components/use-audio-recorder";
import { useLessonEvaluation } from "@/components/use-lesson-evaluation";
import { useLessonSpeech } from "@/components/use-lesson-speech";

type LessonRunnerProps = {
  currentTurn: number;
  lastTranscript: string;
  lesson: CourseLesson;
  moduleId: string;
  moduleState: CompletionState;
  onComplete: () => void;
  onStart: () => void;
  onTurnChange: (turn: number) => void;
  onTranscriptChange: (value: string) => void;
  progressSummary: {
    checkpoint: string;
    completedCount: number;
    learningGoal: string;
    stateLabel: string;
    totalCount: number;
  };
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
  isEvaluating: boolean;
  isRecording: boolean;
  lesson: CourseLesson;
  moduleState: CompletionState;
  onRecord: () => void;
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
          label={getRecordLabel(props.isEvaluating, props.isRecording)}
          muted={props.isEvaluating || props.moduleState === "not_started"}
          onClick={props.onRecord}
        />
      </div>
      <TranscriptPanel transcript={props.transcript} />
    </div>
  );
}

function getRecordLabel(isEvaluating: boolean, isRecording: boolean) {
  if (isEvaluating) return "Scoring...";
  if (isRecording) return "Finish recording";
  return "Record my answer";
}

function TranscriptPanel(props: { transcript: string }) {
  return (
    <div className="mt-5 rounded-2xl bg-white/[0.04] px-4 py-3">
      <p className="text-xs uppercase tracking-[0.2em] text-stone-400">
        Last transcript
      </p>
      <p className="mt-2 text-sm leading-6 text-white">
        {props.transcript ||
          "No voice capture yet. You can still continue manually after practicing aloud."}
      </p>
    </div>
  );
}

function FeedbackCard(props: {
  evaluation: LessonEvaluation | null;
  evaluationError: string;
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
        {props.evaluationError
          ? props.evaluationError
          : props.evaluation
            ? props.evaluation.coachingFeedback
            : hasTranscript
          ? matched
            ? "Nice. Your answer is close to the lesson goal. Keep the same rhythm and move forward."
            : lessonHint(props.lesson)
          : "Practice the phrase aloud first. If browser voice capture is unavailable, continue after you speak on your own once or twice."}
      </p>
      <div className="mt-5 space-y-3">
        <MetaRow
          label="Pronunciation"
          value={formatScore(props.evaluation?.pronunciationScore)}
        />
        <MetaRow
          label="Accuracy"
          value={formatScore(props.evaluation?.accuracyScore)}
        />
        <MetaRow
          label="Fluency"
          value={formatScore(props.evaluation?.fluencyScore)}
        />
        <MetaRow
          label="Deepgram confidence"
          value={formatConfidence(props.evaluation?.deepgramConfidence)}
        />
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

function TrustedProcessCard(props: { progressSummary: LessonRunnerProps["progressSummary"] }) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Trusted process
      </p>
      <div className="mt-4 grid gap-3">
        <MetaRow label="Current status" value={props.progressSummary.stateLabel} />
        <MetaRow
          label="Course progress"
          value={`${props.progressSummary.completedCount}/${props.progressSummary.totalCount} modules completed`}
        />
        <MetaRow label="Checkpoint" value={props.progressSummary.checkpoint} />
        <MetaRow label="Learning goal" value={props.progressSummary.learningGoal} />
      </div>
    </div>
  );
}

function lessonHint(lesson: CourseLesson) {
  return `${lesson.feedback.correctionStyle} Target something close to “${lesson.demoPhrase}” and try once more.`;
}

function formatScore(value: number | undefined) {
  return typeof value === "number" ? `${value}/100` : "Pending";
}

function formatConfidence(value: number | undefined) {
  return typeof value === "number" ? `${Math.round(value * 100)}%` : "Pending";
}

export function LessonRunner(props: LessonRunnerProps) {
  const runner = useLessonRunnerState(props);
  return <LessonRunnerBody {...props} {...runner} />;
}

function useLessonRunnerState(props: LessonRunnerProps) {
  const [currentTurn, setCurrentTurn] = useState(props.currentTurn);
  const [transcript, setTranscript] = useState(props.lastTranscript);
  const recorder = useAudioRecorder();
  const evaluation = useLessonEvaluation();
  const { isListening, playPhrase, startListening, supported } = useLessonSpeech(
    props.slug,
    setTranscript,
  );

  useTurnSync(currentTurn, props.onTurnChange);
  useTranscriptSync(transcript, props.onTranscriptChange);
  const turnHandlers = createTurnHandlers({
    currentTurn,
    lesson: props.lesson,
    onComplete: props.onComplete,
    onStart: props.onStart,
    setCurrentTurn,
  });

  const handleRecord = createRecordHandler({
    evaluation,
    lesson: props.lesson,
    moduleId: props.moduleId,
    recorder,
    setTranscript,
    slug: props.slug,
  });

  return {
    advanceTurn: turnHandlers.advanceTurn,
    currentTurn,
    evaluation: evaluation.evaluation,
    evaluationError: evaluation.error,
    isListening,
    isEvaluating: evaluation.isEvaluating,
    isRecording: recorder.isRecording,
    playTutorLine: () => playPhrase(props.lesson.demoPhrase),
    recordAnswer: handleRecord,
    startLesson: turnHandlers.startLesson,
    startListening,
    supported,
    transcript,
  };
}

function createTurnHandlers(input: {
  currentTurn: number;
  lesson: CourseLesson;
  onComplete: () => void;
  onStart: () => void;
  setCurrentTurn: Dispatch<SetStateAction<number>>;
}) {
  return {
    advanceTurn() {
      if (input.currentTurn >= input.lesson.turns.length - 1) {
        input.onComplete();
        return;
      }

      input.setCurrentTurn((value) => value + 1);
    },
    startLesson() {
      input.onStart();
      input.setCurrentTurn(0);
    },
  };
}

function useTurnSync(
  currentTurn: number,
  onTurnChange: LessonRunnerProps["onTurnChange"],
) {
  useEffect(() => onTurnChange(currentTurn), [currentTurn, onTurnChange]);
}

function useTranscriptSync(
  transcript: string,
  onTranscriptChange: LessonRunnerProps["onTranscriptChange"],
) {
  useEffect(() => onTranscriptChange(transcript), [onTranscriptChange, transcript]);
}

function createRecordHandler(input: {
  evaluation: ReturnType<typeof useLessonEvaluation>;
  lesson: CourseLesson;
  moduleId: string;
  recorder: ReturnType<typeof useAudioRecorder>;
  setTranscript: Dispatch<SetStateAction<string>>;
  slug: CourseSlug;
}) {
  return async function handleRecord() {
    if (!input.recorder.isRecording) {
      await input.recorder.startRecording();
      return;
    }

    const audioBlob = await input.recorder.stopRecording();
    const result = await input.evaluation.evaluate({
      audioBlob,
      lesson: input.lesson,
      moduleId: input.moduleId,
      slug: input.slug,
    });

    if (result?.transcript) {
      input.setTranscript(result.transcript);
    }
  };
}

function LessonRunnerBody(
  props: LessonRunnerProps & {
    advanceTurn: () => void;
    currentTurn: number;
    evaluation: LessonEvaluation | null;
    evaluationError: string;
    isListening: boolean;
    isEvaluating: boolean;
    isRecording: boolean;
    playTutorLine: () => void;
    recordAnswer: () => Promise<void>;
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
        isEvaluating={props.isEvaluating}
        isRecording={props.isRecording}
        supported={props.supported}
        onAdvance={props.advanceTurn}
        onPlay={props.playTutorLine}
        onStart={props.startLesson}
        onListen={props.recordAnswer}
      />
      <LessonRunnerContent {...props} />
    </div>
  );
}

function LessonRunnerContent(
  props: Pick<
    Parameters<typeof LessonRunnerBody>[0],
    | "currentTurn"
    | "evaluation"
    | "evaluationError"
    | "isEvaluating"
    | "isRecording"
    | "lesson"
    | "moduleState"
    | "playTutorLine"
    | "progressSummary"
    | "recordAnswer"
    | "transcript"
  >,
) {
  return (
    <div className="grid gap-4 xl:grid-cols-[minmax(0,1.05fr)_minmax(360px,0.95fr)]">
      <StepCard currentIndex={props.currentTurn} lesson={props.lesson} />
      <TrustedProcessCard progressSummary={props.progressSummary} />
      <PracticeCard
        lesson={props.lesson}
        moduleState={props.moduleState}
        isEvaluating={props.isEvaluating}
        isRecording={props.isRecording}
        onRecord={props.recordAnswer}
        onPlay={props.playTutorLine}
        transcript={props.transcript}
      />
      <FeedbackCard
        lesson={props.lesson}
        transcript={props.transcript}
        evaluation={props.evaluation}
        evaluationError={props.evaluationError}
      />
    </div>
  );
}

function LessonRunnerActions(props: {
  isListening: boolean;
  isEvaluating: boolean;
  isRecording: boolean;
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
          label={
            props.isEvaluating
              ? "Scoring..."
              : props.isRecording
                ? "Finish recording"
                : props.isListening
                  ? "Listening..."
                  : "Record my answer"
          }
          muted={props.isEvaluating}
          onClick={props.onListen}
        />
      ) : null}
    </div>
  );
}
