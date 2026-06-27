"use client";

import { useEffect, useState } from "react";
import { useLessonSpeech } from "@/components/use-lesson-speech";
import {
  type CourseModule,
  type CourseSlug,
  type LanguageCourseResources,
} from "@/lib/course-definitions";
import { type StoredPracticeItemProgress } from "@/lib/course-progress";
import {
  buildPracticeCards,
  scorePracticeTranscript,
  type PracticeCard,
} from "@/lib/module-practice";

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

function EmptyState(props: { message: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-white/10 bg-white/[0.02] px-4 py-6 text-sm leading-7 text-stone-400">
      {props.message}
    </div>
  );
}

function SectionIntro(props: { moduleTitle: string }) {
  return (
    <div className="rounded-[1.6rem] border border-white/10 bg-[linear-gradient(135deg,rgba(16,185,129,0.08),rgba(255,255,255,0.03))] p-6">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Live practice bank
      </p>
      <h3 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
        Practice real {props.moduleTitle} words until they feel natural
      </h3>
      <p className="mt-4 max-w-4xl text-base leading-8 text-stone-200">
        Hear the Japanese, hear the English meaning, say it back, and turn each
        card green only after you personally lock in a perfect spoken match.
      </p>
    </div>
  );
}

function CardStatus(props: { progress?: StoredPracticeItemProgress }) {
  if (props.progress?.done) {
    return <span className="text-emerald-200">Green and saved</span>;
  }

  if (typeof props.progress?.lastScore === "number") {
    return (
      <span className="text-amber-100">
        Score {props.progress.lastScore}/100
      </span>
    );
  }

  return <span className="text-stone-500">Ready to practice</span>;
}

function CardHeader(props: {
  done: boolean | undefined;
  progress?: StoredPracticeItemProgress;
  title: string;
}) {
  return (
    <div className="flex items-start justify-between gap-4">
      <p className="text-[11px] uppercase tracking-[0.22em] text-stone-400">
        {props.title}
      </p>
      <span
        className={`rounded-full border px-3 py-1 text-[11px] uppercase tracking-[0.18em] ${
          props.done
            ? "border-emerald-400/30 bg-emerald-500/[0.08] text-emerald-100"
            : "border-white/10 bg-black/20 text-stone-300"
        }`}
      >
        <CardStatus progress={props.progress} />
      </span>
    </div>
  );
}

function CardCopy(props: { item: PracticeCard }) {
  return (
    <>
      <p className="mt-4 text-3xl font-semibold text-white">
        {props.item.japanese}
      </p>
      <p className="mt-3 text-sm uppercase tracking-[0.18em] text-amber-100">
        {props.item.reading}
      </p>
      <p className="mt-3 text-base text-stone-100">{props.item.english}</p>
      <p className="mt-3 text-sm leading-6 text-stone-400">{props.item.example}</p>
    </>
  );
}

function CardMetrics(props: {
  done: boolean | undefined;
  progress?: StoredPracticeItemProgress;
}) {
  return (
    <div className="mt-5 grid gap-3 sm:grid-cols-3">
      <ScoreMetric
        label="Current score"
        value={
          typeof props.progress?.lastScore === "number"
            ? `${props.progress.lastScore}/100`
            : "Pending"
        }
      />
      <ScoreMetric
        label="Last answer"
        value={props.progress?.lastTranscript || "No spoken answer yet"}
      />
      <ScoreMetric
        label="Status"
        value={props.done ? "Green and saved" : "Get 100/100, then mark green"}
      />
    </div>
  );
}

function CardActions(props: {
  canMarkDone: boolean;
  done: boolean | undefined;
  isListening: boolean;
  onMarkDone: () => void;
  onPlay: () => void;
  onRecord: () => void;
  supported: boolean;
}) {
  return (
    <div className="mt-5 flex flex-wrap gap-3">
      <ActionButton label="Play tutor line" onClick={props.onPlay} />
      <ActionButton
        label={props.isListening ? "Listening..." : "Record my answer"}
        muted={!props.supported}
        onClick={props.onRecord}
      />
      <ActionButton
        label={props.done ? "Marked green" : "Mark green"}
        muted={!props.canMarkDone}
        onClick={props.onMarkDone}
      />
    </div>
  );
}

function PracticeItemCard(props: {
  isListening: boolean;
  item: PracticeCard;
  onMarkDone: () => void;
  onPlay: () => void;
  onRecord: () => void;
  progress?: StoredPracticeItemProgress;
  supported: boolean;
}) {
  const done = props.progress?.done;
  const canMarkDone = isPerfectScore(props.progress?.lastScore) || Boolean(done);
  return (
    <article
      className={`w-full rounded-2xl border p-4 text-left transition ${
        done
          ? "border-emerald-400/30 bg-emerald-500/[0.08]"
          : "border-white/8 bg-white/[0.03] hover:border-white/15 hover:bg-white/[0.05]"
      }`}
    >
      <CardHeader done={done} progress={props.progress} title={props.item.title} />
      <CardCopy item={props.item} />
      <CardMetrics done={done} progress={props.progress} />
      <CardActions
        canMarkDone={canMarkDone}
        done={done}
        isListening={props.isListening}
        onMarkDone={props.onMarkDone}
        onPlay={props.onPlay}
        onRecord={props.onRecord}
        supported={props.supported}
      />
    </article>
  );
}

function ActionButton(props: {
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

function ScoreMetric(props: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-black/20 px-4 py-3">
      <p className="text-xs uppercase tracking-[0.18em] text-stone-400">
        {props.label}
      </p>
      <p className="mt-2 text-sm leading-6 text-white">{props.value}</p>
    </div>
  );
}

function usePracticeSelection(items: PracticeCard[]) {
  const [selectedId, setSelectedId] = useState(items[0]?.id ?? "");
  const selected = items.find((item) => item.id === selectedId) ?? items[0] ?? null;

  return {
    selected,
    setSelectedId,
  };
}

function createProgress(
  score: number,
  transcript: string,
  current?: StoredPracticeItemProgress,
) {
  return {
    done: current?.done ?? false,
    lastScore: score,
    lastTranscript: transcript,
    practicedAt: new Date().toISOString(),
  } satisfies StoredPracticeItemProgress;
}

function isPerfectScore(score?: number | null) {
  return score === 100;
}

function markDone(current?: StoredPracticeItemProgress) {
  return {
    done: true,
    lastScore: current?.lastScore ?? 100,
    lastTranscript: current?.lastTranscript ?? "",
    practicedAt: new Date().toISOString(),
  } satisfies StoredPracticeItemProgress;
}

function speakPrompt(item: PracticeCard, slug: CourseSlug) {
  window.speechSynthesis.cancel();
  const japanese = new SpeechSynthesisUtterance(item.japanese);
  japanese.lang = slug === "japanese" ? "ja-JP" : "en-US";
  const english = new SpeechSynthesisUtterance(`In English, this means ${item.english}.`);
  english.lang = "en-US";
  japanese.onend = () => window.speechSynthesis.speak(english);
  window.speechSynthesis.speak(japanese);
}

function usePracticeScoring(props: {
  item: PracticeCard | null;
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  transcript: string;
}) {
  const { item, onSave, progress, transcript } = props;
  useEffect(() => {
    const spokenText = transcript.trim();
    if (!item || !spokenText) return;
    const score = scorePracticeTranscript(item, transcript);
    const current = progress[item.id];
    if (current?.lastTranscript === transcript && current.lastScore === score) return;
    onSave(item.id, createProgress(score, transcript, current));
  }, [item, onSave, progress, transcript]);
}

function PracticeEmpty(props: { title: string }) {
  return (
    <SectionShell title={props.title}>
      <EmptyState message="No linked practice cards are ready for this module yet." />
    </SectionShell>
  );
}

function PracticeGrid(props: {
  activeId: string;
  items: PracticeCard[];
  onMarkDone: (item: PracticeCard) => void;
  onPlay: (item: PracticeCard) => void;
  onRecord: (item: PracticeCard) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  speechSupported: boolean;
}) {
  return (
    <div className="grid gap-3 xl:grid-cols-2">
      {props.items.map((item) => (
        <PracticeItemCard
          key={item.id}
          item={item}
          isListening={item.id === props.activeId}
          onMarkDone={() => props.onMarkDone(item)}
          onPlay={() => props.onPlay(item)}
          onRecord={() => props.onRecord(item)}
          progress={props.progress[item.id]}
          supported={props.speechSupported}
        />
      ))}
    </div>
  );
}

function createPracticeActions(props: {
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  setRecordingItemId: (id: string) => void;
  setSelectedId: (id: string) => void;
  setTranscript: (value: string) => void;
  slug: CourseSlug;
  speech: ReturnType<typeof useLessonSpeech>;
}) {
  return {
    markItemDone(item: PracticeCard) {
      const current = props.progress[item.id];
      if (!isPerfectScore(current?.lastScore) && !current?.done) return;
      props.onSave(item.id, markDone(current));
    },
    playItem(item: PracticeCard) {
      props.setSelectedId(item.id);
      props.setRecordingItemId("");
      props.setTranscript("");
      speakPrompt(item, props.slug);
    },
    recordItem(item: PracticeCard) {
      props.setSelectedId(item.id);
      props.setRecordingItemId(item.id);
      props.setTranscript("");
      props.speech.startListening();
    },
  };
}

function PracticeSection(props: {
  items: PracticeCard[];
  onSave: (itemId: string, value: StoredPracticeItemProgress) => void;
  progress: Record<string, StoredPracticeItemProgress>;
  slug: CourseSlug;
  title: string;
}) {
  const { selected, setSelectedId } = usePracticeSelection(props.items);
  const [recordingItemId, setRecordingItemId] = useState("");
  const [transcript, setTranscript] = useState("");
  const speech = useLessonSpeech(props.slug, setTranscript);
  const recordingItem =
    props.items.find((item) => item.id === recordingItemId) ?? null;

  usePracticeScoring({
    item: recordingItem,
    onSave: props.onSave,
    progress: props.progress,
    transcript,
  });

  if (!selected) {
    return <PracticeEmpty title={props.title} />;
  }

  const actions = createPracticeActions({
    onSave: props.onSave,
    progress: props.progress,
    setRecordingItemId,
    setSelectedId,
    setTranscript,
    slug: props.slug,
    speech,
  });

  return (
    <SectionShell title={props.title}>
      <PracticeGrid
        activeId={speech.isListening ? selected.id : ""}
        items={props.items}
        onMarkDone={actions.markItemDone}
        onPlay={actions.playItem}
        onRecord={actions.recordItem}
        progress={props.progress}
        speechSupported={speech.supported}
      />
    </SectionShell>
  );
}

export function CourseStudyBank(props: {
  module: CourseModule;
  onPracticeItemChange: (itemId: string, value: StoredPracticeItemProgress) => void;
  practiceItems: Record<string, StoredPracticeItemProgress>;
  resources?: LanguageCourseResources;
  slug: CourseSlug;
}) {
  if (!props.resources) return null;

  const cards = buildPracticeCards(props.module, props.resources);
  const words = cards.filter((item) => item.kind === "word");
  const kanji = cards.filter((item) => item.kind === "kanji");

  return (
    <section className="space-y-4">
      <SectionIntro moduleTitle={props.module.title} />
      <PracticeSection
        items={words}
        onSave={props.onPracticeItemChange}
        progress={props.practiceItems}
        slug={props.slug}
        title="Words To Say"
      />
      <PracticeSection
        items={kanji}
        onSave={props.onPracticeItemChange}
        progress={props.practiceItems}
        slug={props.slug}
        title="Kanji To Notice"
      />
    </section>
  );
}
