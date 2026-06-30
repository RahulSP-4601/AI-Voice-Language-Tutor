"use client";

import { useState } from "react";
import { PracticeCarouselCard } from "@/components/practice-carousel-card";
import { useAudioRecorder } from "@/components/use-audio-recorder";
import { usePracticeEvaluation } from "@/components/use-practice-evaluation";
import {
  type CourseModule,
  type CourseSlug,
} from "@/lib/course-definitions";
import { type StoredPracticeItemProgress } from "@/lib/course-progress";
import {
  PRACTICE_PASS_SCORE,
  scorePracticeTranscript,
  type ModulePracticeDeck,
  type PracticeCard,
} from "@/lib/module-practice";
import { playTutorAudioSequence } from "@/lib/tutor-audio";

function SectionShell(props: { children: React.ReactNode; title: string }) {
  return (
    <section className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        {props.title}
      </p>
      <div className="mt-4">{props.children}</div>
    </section>
  );
}

function SectionIntro(props: { moduleTitle: string; slug: CourseSlug }) {
  return (
    <div className="rounded-[1.6rem] border border-white/10 bg-[linear-gradient(135deg,rgba(16,185,129,0.08),rgba(255,255,255,0.03))] p-6">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Live practice bank
      </p>
      <h3 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
        {`Practice ${props.moduleTitle} one word at a time`}
      </h3>
      <p className="mt-4 max-w-4xl text-base leading-8 text-stone-200">
        Hear the Japanese, hear the English meaning, say it back, check the score, and move on only when you feel the word is truly locked in.
      </p>
    </div>
  );
}

function EmptyState(props: { message: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-white/10 bg-white/[0.02] px-4 py-6 text-sm leading-7 text-stone-400">
      {props.message}
    </div>
  );
}

function isPassScore(score?: number | null) {
  return typeof score === "number" && score >= PRACTICE_PASS_SCORE;
}

function speakPrompt(item: PracticeCard, slug: CourseSlug) {
  void playTutorAudioSequence([
    {
      fallbackText: item.reading,
      slug,
      text: item.japanese,
    },
    {
      slug: "english",
      text: `In English, this means ${item.english}.`,
    },
  ]);
}

function firstPendingItemId(
  items: PracticeCard[],
  progress: Record<string, StoredPracticeItemProgress>,
) {
  return items.find((item) => !progress[item.id]?.done)?.id ?? items[0]?.id ?? "";
}

function usePracticeSelection(
  items: PracticeCard[],
  progress: Record<string, StoredPracticeItemProgress>,
) {
  const [manualSelectedId, setSelectedId] = useState("");
  const selectedId = items.some((item) => item.id === manualSelectedId)
    ? manualSelectedId
    : firstPendingItemId(items, progress);
  const selected = items.find((item) => item.id === selectedId) ?? items[0] ?? null;
  const selectedIndex = selected ? items.findIndex((item) => item.id === selected.id) : -1;

  return { selected, selectedIndex, setSelectedId };
}

function createStoredProgress(
  item: PracticeCard,
  transcript: string,
  slug: CourseSlug,
  metrics: {
    accuracyScore: number;
    coachingFeedback: string;
    fluencyScore: number;
    pronunciationScore: number;
  },
  current?: StoredPracticeItemProgress,
) {
  return {
    accuracyScore: metrics.accuracyScore,
    coachingFeedback: metrics.coachingFeedback,
    done: current?.done ?? false,
    fluencyScore: metrics.fluencyScore,
    lastScore: Math.max(
      scorePracticeTranscript(item, transcript, slug),
      Math.round(
        (metrics.pronunciationScore + metrics.accuracyScore + metrics.fluencyScore) / 3,
      ),
    ),
    lastTranscript: transcript,
    practicedAt: new Date().toISOString(),
    pronunciationScore: metrics.pronunciationScore,
  } satisfies StoredPracticeItemProgress;
}

function markDone(current?: StoredPracticeItemProgress) {
  return {
    accuracyScore: current?.accuracyScore ?? 100,
    coachingFeedback: current?.coachingFeedback ?? "",
    done: true,
    fluencyScore: current?.fluencyScore ?? 100,
    lastScore: current?.lastScore ?? 100,
    lastTranscript: current?.lastTranscript ?? "",
    practicedAt: new Date().toISOString(),
    pronunciationScore: current?.pronunciationScore ?? 100,
  } satisfies StoredPracticeItemProgress;
}

function buildCarouselState(input: {
  items: PracticeCard[];
  progress: Record<string, StoredPracticeItemProgress>;
  recordingItemId: string;
  recorder: ReturnType<typeof useAudioRecorder>;
  selected: PracticeCard;
  selectedIndex: number;
}) {
  const current = input.progress[input.selected.id];
  const doneCount = input.items.filter((item) => input.progress[item.id]?.done).length;
  return {
    canGoNext:
      input.selectedIndex < input.items.length - 1 &&
      (isPassScore(current?.lastScore) ||
        Boolean(current?.done) ||
        input.selectedIndex < doneCount),
    canGoPrev: input.selectedIndex > 0,
    canMarkDone: isPassScore(current?.lastScore) || Boolean(current?.done),
    current,
    doneCount,
    isRecording:
      input.recorder.isRecording && input.recordingItemId === input.selected.id,
  };
}

function buildCardProps(input: {
  evaluation: ReturnType<typeof usePracticeEvaluation>;
  items: PracticeCard[];
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  recorder: ReturnType<typeof useAudioRecorder>;
  recordingItemId: string;
  selected: PracticeCard;
  selectedIndex: number;
  setRecordingItemId: (value: string) => void;
  setSelectedId: (value: string) => void;
  slug: CourseSlug;
}) {
  return {
    ...buildCarouselState(input),
    currentIndex: input.selectedIndex,
    error: input.evaluation.error,
    isEvaluating: input.evaluation.isEvaluating,
    item: input.selected,
    onMarkDone: () =>
      input.onSave(input.selected.id, markDone(input.progress[input.selected.id])),
    onNext: () =>
      input.setSelectedId(
        input.items[input.selectedIndex + 1]?.id ?? input.selected.id,
      ),
    onPlay: () => speakPrompt(input.selected, input.slug),
    onPrev: () =>
      input.setSelectedId(
        input.items[input.selectedIndex - 1]?.id ?? input.selected.id,
      ),
    onRecord: () =>
      handleRecord({
        evaluation: input.evaluation,
        item: input.selected,
        onSave: input.onSave,
        progress: input.progress[input.selected.id],
        recorder: input.recorder,
        setRecordingItemId: input.setRecordingItemId,
        slug: input.slug,
      }),
    slug: input.slug,
    supported: input.recorder.supported,
    totalCount: input.items.length,
  };
}

function PracticeCarousel(props: {
  items: PracticeCard[];
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  slug: CourseSlug;
  title: string;
}) {
  const { selected, selectedIndex, setSelectedId } = usePracticeSelection(
    props.items,
    props.progress,
  );
  const recorder = useAudioRecorder();
  const evaluation = usePracticeEvaluation();
  const [recordingItemId, setRecordingItemId] = useState("");

  if (!selected) {
    return (
      <SectionShell title={props.title}>
        <EmptyState message="No linked practice cards are ready for this module yet." />
      </SectionShell>
    );
  }

  return (
    <SectionShell title={props.title}>
      <PracticeCarouselCard
        {...buildCardProps({
          evaluation,
          items: props.items,
          onSave: props.onSave,
          progress: props.progress,
          recorder,
          recordingItemId,
          selected,
          selectedIndex,
          setRecordingItemId,
          setSelectedId,
          slug: props.slug,
        })}
      />
    </SectionShell>
  );
}

async function handleRecord(input: {
  evaluation: ReturnType<typeof usePracticeEvaluation>;
  item: PracticeCard;
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress?: StoredPracticeItemProgress;
  recorder: ReturnType<typeof useAudioRecorder>;
  setRecordingItemId: (value: string) => void;
  slug: CourseSlug;
}) {
  if (!input.recorder.isRecording) {
    input.setRecordingItemId(input.item.id);
    await input.recorder.startRecording();
    return;
  }

  const audioBlob = await input.recorder.stopRecording();
  input.setRecordingItemId("");
  const result = await input.evaluation.evaluate({
    audioBlob,
    item: input.item,
    slug: input.slug,
  });
  if (!result?.transcript) return;

  input.onSave(
    input.item.id,
    createStoredProgress(
      input.item,
      result.transcript,
      input.slug,
      result,
      input.progress,
    ),
  );
}

export function CourseStudyBank(props: {
  module: CourseModule;
  onPracticeItemChange: (itemId: string, value: StoredPracticeItemProgress) => void;
  practiceDeck: ModulePracticeDeck;
  practiceItems: Record<string, StoredPracticeItemProgress>;
  slug: CourseSlug;
}) {
  return (
    <section className="space-y-4">
      <SectionIntro moduleTitle={props.module.title} slug={props.slug} />
      <PracticeCarousel
        items={props.practiceDeck.words}
        onSave={props.onPracticeItemChange}
        progress={props.practiceItems}
        slug={props.slug}
        title="Words To Say"
      />
      {props.practiceDeck.kanji.length > 0 ? (
        <PracticeCarousel
          items={props.practiceDeck.kanji}
          onSave={props.onPracticeItemChange}
          progress={props.practiceItems}
          slug={props.slug}
          title="Kanji To Notice"
        />
      ) : null}
    </section>
  );
}
