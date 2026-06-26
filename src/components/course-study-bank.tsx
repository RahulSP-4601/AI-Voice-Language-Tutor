"use client";

import {
  type CourseModule,
  type ExamQuestion,
  type ExamSection,
  type KanjiEntry,
  type LanguageCourseResources,
  type VocabularyEntry,
} from "@/lib/course-definitions";

type ModuleWord = VocabularyEntry & { categoryTitle: string };
type ModuleKanji = KanjiEntry & { groupTitle: string };

function SectionShell(props: { children: React.ReactNode; title: string }) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-amber-100">
        {props.title}
      </p>
      <div className="mt-4">{props.children}</div>
    </div>
  );
}

function StatPill(props: { label: string }) {
  return (
    <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-2 text-xs uppercase tracking-[0.18em] text-stone-200">
      {props.label}
    </span>
  );
}

function StudyBankIntro(props: {
  module: CourseModule;
  resources: LanguageCourseResources;
  selectedQuestions: number;
  selectedSections: number;
  selectedWords: number;
}) {
  return (
    <div className="rounded-[1.6rem] border border-white/10 bg-[linear-gradient(135deg,rgba(16,185,129,0.08),rgba(255,255,255,0.03))] p-6">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        Mission Study Bank
      </p>
      <h3 className="mt-4 text-3xl font-semibold tracking-[-0.04em] text-white">
        Everything the learner needs for {props.module.title}
      </h3>
      <p className="mt-4 max-w-4xl text-base leading-8 text-stone-200">
        The selected Japanese mission now pulls its teaching words, useful
        kanji, and checkpoint prompts directly from the Supabase N5 course
        bank.
      </p>
      <div className="mt-5 flex flex-wrap gap-3">
        <StatPill label={`${props.selectedWords} mission words`} />
        <StatPill label={`${props.selectedSections} checkpoint formats`} />
        <StatPill label={`${props.selectedQuestions} guided prompts`} />
        <StatPill
          label={`${props.resources.vocabularyCategories.length} vocab categories in bank`}
        />
      </div>
    </div>
  );
}

function WordCard(props: { word: ModuleWord }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-[11px] uppercase tracking-[0.22em] text-stone-400">
        {props.word.categoryTitle}
      </p>
      <p className="mt-3 text-2xl font-semibold text-white">
        {props.word.japanese}
      </p>
      <p className="mt-2 text-sm uppercase tracking-[0.18em] text-amber-100">
        {props.word.romaji}
      </p>
      <p className="mt-3 text-base text-stone-100">{props.word.english}</p>
      <p className="mt-3 text-sm leading-6 text-stone-400">
        {props.word.example}
      </p>
    </div>
  );
}

function KanjiCard(props: { kanji: ModuleKanji }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-[11px] uppercase tracking-[0.22em] text-stone-400">
        {props.kanji.groupTitle}
      </p>
      <p className="mt-3 text-3xl font-semibold text-white">
        {props.kanji.japanese}
      </p>
      <p className="mt-2 text-sm uppercase tracking-[0.18em] text-sky-100">
        {props.kanji.reading}
      </p>
      <p className="mt-3 text-base text-stone-100">{props.kanji.meaning}</p>
      <p className="mt-3 text-sm leading-6 text-stone-400">
        {props.kanji.example}
      </p>
    </div>
  );
}

function ExamSectionCard(props: { section: ExamSection }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-base font-semibold text-white">{props.section.title}</p>
      <p className="mt-3 text-sm leading-6 text-stone-300">
        {props.section.passSignal}
      </p>
      <div className="mt-4 flex flex-wrap gap-2">
        {props.section.questionTypes.map((item) => (
          <StatPill key={`${props.section.id}-${item}`} label={item} />
        ))}
      </div>
    </div>
  );
}

function QuestionCard(props: { question: ExamQuestion }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-5">
      <div className="flex flex-wrap gap-2">
        <StatPill label={props.question.questionType} />
        <StatPill label={props.question.skillFocus} />
      </div>
      <p className="mt-4 text-lg font-medium leading-8 text-white">
        {props.question.prompt}
      </p>
      <QuestionChoices choices={props.question.choices} />
      <div className="mt-4 rounded-2xl border border-emerald-400/10 bg-emerald-500/[0.05] p-4">
        <p className="text-xs uppercase tracking-[0.24em] text-emerald-100">
          Expected answer
        </p>
        <p className="mt-2 text-sm font-medium text-white">
          {props.question.correctAnswer}
        </p>
        <p className="mt-3 text-sm leading-6 text-stone-300">
          {props.question.explanation}
        </p>
      </div>
    </div>
  );
}

function QuestionChoices(props: { choices: string[] }) {
  if (!props.choices.length) {
    return null;
  }

  return (
    <div className="mt-4 flex flex-wrap gap-2">
      {props.choices.map((choice) => (
        <span
          key={choice}
          className="rounded-full border border-white/10 bg-black/20 px-3 py-2 text-xs text-stone-300"
        >
          {choice}
        </span>
      ))}
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

function selectVocabularyCategories(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.vocabularyCategoryIds;
  if (!ids?.length) {
    return resources.vocabularyCategories.slice(0, 3);
  }

  return resources.vocabularyCategories.filter((category) => ids.includes(category.id));
}

function selectWords(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  return selectVocabularyCategories(resources, module)
    .flatMap((category) =>
      category.entries.slice(0, 3).map((entry) => ({
        ...entry,
        categoryTitle: category.title,
      })),
    )
    .slice(0, 9);
}

function selectKanjiGroups(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.kanjiGroupIds;
  if (!ids?.length) {
    return resources.kanjiGroups.slice(0, 2);
  }

  return resources.kanjiGroups.filter((group) => ids.includes(group.id));
}

function selectKanjiEntries(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  return selectKanjiGroups(resources, module)
    .flatMap((group) =>
      group.entries.slice(0, 4).map((entry) => ({
        ...entry,
        groupTitle: group.title,
      })),
    )
    .slice(0, 8);
}

function selectExamSections(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.examSectionIds;
  if (!ids?.length) {
    return resources.examSections.slice(0, 3);
  }

  return resources.examSections.filter((section) => ids.includes(section.id)).slice(0, 3);
}

function selectExamQuestions(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.examSectionIds;
  if (!ids?.length) {
    return resources.examQuestions.slice(0, 4);
  }

  return resources.examQuestions
    .filter((question) => ids.includes(question.sectionId))
    .slice(0, 4);
}

function WordsSection(props: { words: ModuleWord[] }) {
  return (
    <SectionShell title="Words To Say">
      <div className="grid gap-3 xl:grid-cols-2">
        {props.words.length ? (
          props.words.map((word) => <WordCard key={`${word.categoryTitle}-${word.japanese}`} word={word} />)
        ) : (
          <EmptyState message="No mission-linked vocabulary has been assigned yet." />
        )}
      </div>
    </SectionShell>
  );
}

function KanjiSection(props: { kanji: ModuleKanji[] }) {
  return (
    <SectionShell title="Kanji To Notice">
      <div className="grid gap-3 xl:grid-cols-2">
        {props.kanji.length ? (
          props.kanji.map((entry) => <KanjiCard key={`${entry.groupTitle}-${entry.japanese}`} kanji={entry} />)
        ) : (
          <EmptyState message="This mission does not need kanji focus yet, so the learner can stay with sound and vocabulary first." />
        )}
      </div>
    </SectionShell>
  );
}

function ExamSectionsPanel(props: { sections: ExamSection[] }) {
  return (
    <SectionShell title="Checkpoint Formats">
      <div className="space-y-3">
        {props.sections.length ? (
          props.sections.map((section) => (
            <ExamSectionCard key={section.id} section={section} />
          ))
        ) : (
          <EmptyState message="No checkpoint formats are linked to this mission yet." />
        )}
      </div>
    </SectionShell>
  );
}

function QuestionBankSection(props: { questions: ExamQuestion[] }) {
  return (
    <SectionShell title="Mission Question Bank">
      <div className="grid gap-4 xl:grid-cols-2">
        {props.questions.length ? (
          props.questions.map((question) => (
            <QuestionCard key={question.id} question={question} />
          ))
        ) : (
          <EmptyState message="No guided prompt cards are linked to this mission yet." />
        )}
      </div>
    </SectionShell>
  );
}

export function CourseStudyBank(props: {
  module: CourseModule;
  resources?: LanguageCourseResources;
}) {
  if (!props.resources) {
    return null;
  }

  const words = selectWords(props.resources, props.module);
  const kanji = selectKanjiEntries(props.resources, props.module);
  const sections = selectExamSections(props.resources, props.module);
  const questions = selectExamQuestions(props.resources, props.module);

  return (
    <section className="space-y-4">
      <StudyBankIntro
        module={props.module}
        resources={props.resources}
        selectedQuestions={questions.length}
        selectedSections={sections.length}
        selectedWords={words.length}
      />
      <div className="grid gap-4 xl:grid-cols-3">
        <div className="xl:col-span-2">
          <WordsSection words={words} />
        </div>
        <ExamSectionsPanel sections={sections} />
      </div>
      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <KanjiSection kanji={kanji} />
        <QuestionBankSection questions={questions} />
      </div>
    </section>
  );
}
