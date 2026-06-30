"use client";

import { type StoredPracticeItemProgress } from "@/lib/course-progress";
import { PRACTICE_PASS_SCORE, type PracticeCard } from "@/lib/module-practice";

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

function statusLabel(slug: string, progress?: StoredPracticeItemProgress) {
  if (progress?.done) return "Green and saved";
  if ((progress?.lastScore ?? 0) >= PRACTICE_PASS_SCORE) {
    return "Pass ready";
  }
  if (typeof progress?.lastScore === "number") return `${progress.lastScore}/100`;
  return "Ready to practice";
}

function formatMetric(slug: string, value?: number | null) {
  void slug;
  return typeof value === "number" ? `${value}/100` : "Pending";
}

function recordLabel(slug: string, isEvaluating: boolean, isRecording: boolean) {
  void slug;
  if (isEvaluating) return "Scoring...";
  if (isRecording) return "Stop recording";
  return "Record my answer";
}

function CarouselHeader(props: {
  currentIndex: number;
  doneCount: number;
  progress?: StoredPracticeItemProgress;
  slug: string;
  totalCount: number;
}) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-3">
      <div>
        <p className="text-xs uppercase tracking-[0.22em] text-stone-400">
          {`Card ${props.currentIndex + 1} of ${props.totalCount}`}
        </p>
        <p className="mt-2 text-sm text-stone-300">
          {`${props.doneCount}/${props.totalCount} green and saved`}
        </p>
      </div>
      <span className="rounded-full border border-white/10 bg-black/20 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-stone-200">
        {statusLabel(props.slug, props.progress)}
      </span>
    </div>
  );
}

function WordCopy(props: { item: PracticeCard; slug: string }) {
  return (
    <>
      <p className="mt-5 text-[2.35rem] font-semibold tracking-[-0.04em] text-white">
        {props.item.japanese}
      </p>
      <p className="mt-3 text-sm uppercase tracking-[0.18em] text-amber-100">
        {props.item.reading}
      </p>
      <p className="mt-2 text-sm text-stone-300">
        Say it like: 
        <span className="text-white">{props.item.phoneticHint}</span>
      </p>
      <p className="mt-4 text-xl text-stone-100">{props.item.english}</p>
      <p className="mt-4 text-sm leading-7 text-stone-400">{props.item.example}</p>
    </>
  );
}

function ScorePanel(props: { progress?: StoredPracticeItemProgress; slug: string }) {
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
        value={formatMetric(props.slug, props.progress?.pronunciationScore)}
      />
      <Metric
        label="Accuracy"
        value={formatMetric(props.slug, props.progress?.accuracyScore)}
      />
      <Metric
        label="Fluency"
        value={formatMetric(props.slug, props.progress?.fluencyScore)}
      />
    </div>
  );
}

function TranscriptPanel(props: {
  error?: string;
  progress?: StoredPracticeItemProgress;
  slug: string;
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
          "Hear how it sounds, record yourself, and aim for a clean exact match."
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
  slug: string;
  supported: boolean;
}) {
  return (
    <div className="mt-5 flex flex-wrap gap-3">
      <ActionButton
        label="How does it sound?"
        onClick={props.onPlay}
      />
      <ActionButton
        disabled={!props.supported || props.isEvaluating}
        label={recordLabel(props.slug, props.isEvaluating, props.isRecording)}
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
  slug: string;
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

type PracticeCarouselCardProps = {
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
  slug: string;
  supported: boolean;
  totalCount: number;
};

function PracticeCarouselBody(props: PracticeCarouselCardProps) {
  return (
    <>
      <CarouselHeader
        currentIndex={props.currentIndex}
        doneCount={props.doneCount}
        progress={props.current}
        slug={props.slug}
        totalCount={props.totalCount}
      />
      <WordCopy item={props.item} slug={props.slug} />
      <ScorePanel progress={props.current} slug={props.slug} />
      <TranscriptPanel error={props.error} progress={props.current} slug={props.slug} />
      <PracticeActions
        canMarkDone={props.canMarkDone}
        canMoveNext={props.canGoNext}
        done={Boolean(props.current?.done)}
        isEvaluating={props.isEvaluating}
        isRecording={props.isRecording}
        onMarkDone={props.onMarkDone}
        onPlay={props.onPlay}
        onRecord={props.onRecord}
        slug={props.slug}
        supported={props.supported}
      />
      <NavigationBar
        canGoNext={props.canGoNext}
        canGoPrev={props.canGoPrev}
        onNext={props.onNext}
        onPrev={props.onPrev}
        slug={props.slug}
      />
    </>
  );
}

export function PracticeCarouselCard(props: PracticeCarouselCardProps) {
  return <PracticeCarouselBody {...props} />;
}
