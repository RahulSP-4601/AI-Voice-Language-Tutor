"use client";

import { type StoredPracticeItemProgress } from "@/lib/course-progress";
import { type PracticeCard } from "@/lib/module-practice";

function Metric(props: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-black/20 px-4 py-3">
      <p className="text-xs uppercase tracking-[0.18em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-2 text-sm leading-6 text-white">{props.value}</p>
    </div>
  );
}

function ActionButton(props: {
  disabled?: boolean;
  label: string;
  muted?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      disabled={props.disabled}
      onClick={props.onClick}
      className={`rounded-full border px-4 py-2 text-sm font-medium transition ${
        props.muted
          ? "cursor-not-allowed border-white/10 bg-white/[0.04] text-stone-400"
          : "border-amber-300/20 bg-amber-300/12 text-amber-100 hover:bg-amber-300/18"
      }`}
    >
      {props.label}
    </button>
  );
}

function statusLabel(progress?: StoredPracticeItemProgress) {
  if (progress?.done) return "Green and saved";
  if (progress?.lastScore === 100) return "Perfect match ready";
  if (typeof progress?.lastScore === "number") return `${progress.lastScore}/100 match`;
  return "Ready to practice";
}

function formatMetric(value?: number | null) {
  return typeof value === "number" ? `${value}/100` : "Pending";
}

function recordLabel(isEvaluating: boolean, isRecording: boolean) {
  if (isEvaluating) return "Scoring...";
  if (isRecording) return "Stop recording";
  return "Record my answer";
}

function CarouselHeader(props: {
  currentIndex: number;
  doneCount: number;
  progress?: StoredPracticeItemProgress;
  totalCount: number;
}) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-3">
      <div>
        <p className="text-xs uppercase tracking-[0.22em] text-stone-400">
          Card {props.currentIndex + 1} of {props.totalCount}
        </p>
        <p className="mt-2 text-sm text-stone-300">
          {props.doneCount}/{props.totalCount} green and saved
        </p>
      </div>
      <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-stone-200">
        {statusLabel(props.progress)}
      </span>
    </div>
  );
}

function WordCopy(props: { item: PracticeCard }) {
  return (
    <>
      <p className="mt-5 text-[2.35rem] font-semibold tracking-[-0.04em] text-white">
        {props.item.japanese}
      </p>
      <p className="mt-3 text-sm uppercase tracking-[0.18em] text-amber-100">
        {props.item.reading}
      </p>
      <p className="mt-2 text-sm text-stone-300">
        Say it like: <span className="text-white">{props.item.phoneticHint}</span>
      </p>
      <p className="mt-4 text-xl text-stone-100">{props.item.english}</p>
      <p className="mt-4 text-sm leading-7 text-stone-400">{props.item.example}</p>
    </>
  );
}

function ScorePanel(props: { progress?: StoredPracticeItemProgress }) {
  return (
    <div className="mt-5 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
      <Metric
        label="Match"
        value={
          typeof props.progress?.lastScore === "number"
            ? `${props.progress.lastScore}/100`
            : "Pending"
        }
      />
      <Metric
        label="Pronunciation"
        value={formatMetric(props.progress?.pronunciationScore)}
      />
      <Metric label="Accuracy" value={formatMetric(props.progress?.accuracyScore)} />
      <Metric label="Fluency" value={formatMetric(props.progress?.fluencyScore)} />
    </div>
  );
}

function TranscriptPanel(props: {
  error?: string;
  progress?: StoredPracticeItemProgress;
}) {
  return (
    <div className="mt-5 grid gap-3 lg:grid-cols-[1.1fr_0.9fr]">
      <Metric
        label="Last answer"
        value={props.progress?.lastTranscript || "No spoken answer yet"}
      />
      <Metric
        label="Coaching"
        value={
          props.error ||
          props.progress?.coachingFeedback ||
          "Play the tutor line, record yourself, and aim for a clean exact match."
        }
      />
    </div>
  );
}

function PracticeActions(props: {
  canMarkDone: boolean;
  canMoveNext: boolean;
  done: boolean;
  isEvaluating: boolean;
  isRecording: boolean;
  onMarkDone: () => void;
  onPlay: () => void;
  onRecord: () => void;
  supported: boolean;
}) {
  return (
    <div className="mt-5 flex flex-wrap gap-3">
      <ActionButton label="Play tutor line" onClick={props.onPlay} />
      <ActionButton
        disabled={!props.supported || props.isEvaluating}
        label={recordLabel(props.isEvaluating, props.isRecording)}
        muted={!props.supported || props.isEvaluating}
        onClick={props.onRecord}
      />
      <ActionButton
        disabled={!props.canMarkDone}
        label={props.done ? "Marked green" : "Mark green"}
        muted={!props.canMarkDone}
        onClick={props.onMarkDone}
      />
      <span className="self-center text-sm text-stone-400">
        {props.canMoveNext
          ? "You can move to the next card."
          : "Get a perfect match first, then mark this one green."}
      </span>
    </div>
  );
}

function NavigationBar(props: {
  canGoNext: boolean;
  canGoPrev: boolean;
  onNext: () => void;
  onPrev: () => void;
}) {
  return (
    <div className="mt-5 flex flex-wrap gap-3">
      <ActionButton
        disabled={!props.canGoPrev}
        label="Previous"
        muted={!props.canGoPrev}
        onClick={props.onPrev}
      />
      <ActionButton
        disabled={!props.canGoNext}
        label="Next"
        muted={!props.canGoNext}
        onClick={props.onNext}
      />
    </div>
  );
}

export function PracticeCarouselCard(props: {
  canGoNext: boolean;
  canGoPrev: boolean;
  canMarkDone: boolean;
  current?: StoredPracticeItemProgress;
  currentIndex: number;
  doneCount: number;
  error?: string;
  isEvaluating: boolean;
  isRecording: boolean;
  item: PracticeCard;
  onMarkDone: () => void;
  onNext: () => void;
  onPlay: () => void;
  onPrev: () => void;
  onRecord: () => void;
  supported: boolean;
  totalCount: number;
}) {
  return (
    <>
      <CarouselHeader
        currentIndex={props.currentIndex}
        doneCount={props.doneCount}
        progress={props.current}
        totalCount={props.totalCount}
      />
      <WordCopy item={props.item} />
      <ScorePanel progress={props.current} />
      <TranscriptPanel error={props.error} progress={props.current} />
      <PracticeActions
        canMarkDone={props.canMarkDone}
        canMoveNext={props.canGoNext}
        done={Boolean(props.current?.done)}
        isEvaluating={props.isEvaluating}
        isRecording={props.isRecording}
        onMarkDone={props.onMarkDone}
        onPlay={props.onPlay}
        onRecord={props.onRecord}
        supported={props.supported}
      />
      <NavigationBar
        canGoNext={props.canGoNext}
        canGoPrev={props.canGoPrev}
        onNext={props.onNext}
        onPrev={props.onPrev}
      />
    </>
  );
}
