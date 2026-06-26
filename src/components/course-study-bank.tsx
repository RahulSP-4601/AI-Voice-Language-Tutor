"use client";

import {
  type CourseModule,
  type ExamQuestion,
  type ExamSection,
  type KanjiGroup,
  type LanguageCourseResources,
  type VocabularyCategory,
} from "@/lib/course-definitions";

function SectionCard(props: {
  children: React.ReactNode;
  title: string;
}) {
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

function VocabCategoryCard(props: { category: VocabularyCategory }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-sm font-semibold text-white">{props.category.title}</p>
      <div className="mt-3 space-y-2">
        {props.category.entries.slice(0, 4).map((entry) => (
          <div key={`${props.category.id}-${entry.japanese}`} className="text-sm leading-6 text-stone-300">
            <span className="font-medium text-white">{entry.japanese}</span>
            <span className="mx-2 text-stone-500">·</span>
            <span>{entry.english}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function KanjiGroupCard(props: { group: KanjiGroup }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-sm font-semibold text-white">{props.group.title}</p>
      <div className="mt-3 flex flex-wrap gap-2">
        {props.group.entries.slice(0, 8).map((entry) => (
          <span
            key={`${props.group.id}-${entry.japanese}`}
            className="rounded-full border border-white/10 bg-black/20 px-3 py-2 text-xs text-stone-200"
          >
            {entry.japanese} · {entry.meaning}
          </span>
        ))}
      </div>
    </div>
  );
}

function ExamSectionCard(props: { section: ExamSection }) {
  return (
    <div className="rounded-2xl border border-white/8 bg-white/[0.03] p-4">
      <p className="text-sm font-semibold text-white">{props.section.title}</p>
      <p className="mt-2 text-sm leading-6 text-stone-300">
        {props.section.passSignal}
      </p>
      <div className="mt-3 flex flex-wrap gap-2">
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
      <div className="flex flex-wrap items-center gap-2">
        <StatPill label={props.question.questionType} />
        <StatPill label={props.question.skillFocus} />
      </div>
      <p className="mt-4 text-base font-medium leading-7 text-white">
        {props.question.prompt}
      </p>
      <QuestionChoices choices={props.question.choices} />
      <QuestionAnswer
        answer={props.question.correctAnswer}
        explanation={props.question.explanation}
      />
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

function QuestionAnswer(props: { answer: string; explanation: string }) {
  return (
    <div className="mt-4 rounded-2xl border border-emerald-400/10 bg-emerald-500/[0.05] p-4">
      <p className="text-xs uppercase tracking-[0.24em] text-emerald-100">
        Expected answer
      </p>
      <p className="mt-2 text-sm font-medium text-white">{props.answer}</p>
      <p className="mt-3 text-sm leading-6 text-stone-300">
        {props.explanation}
      </p>
    </div>
  );
}

function selectVocabulary(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.vocabularyCategoryIds;
  const matches = ids?.length
    ? resources.vocabularyCategories.filter((category) => ids.includes(category.id))
    : resources.vocabularyCategories.slice(0, 3);
  return matches.slice(0, 4);
}

function selectKanji(resources: LanguageCourseResources, module: CourseModule) {
  const ids = module.resourceLinks?.kanjiGroupIds;
  const matches = ids?.length
    ? resources.kanjiGroups.filter((group) => ids.includes(group.id))
    : resources.kanjiGroups.slice(0, 2);
  return matches.slice(0, 2);
}

function selectExamSections(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.examSectionIds;
  const matches = ids?.length
    ? resources.examSections.filter((section) => ids.includes(section.id))
    : resources.examSections.slice(0, 3);
  return matches.slice(0, 3);
}

function selectExamQuestions(
  resources: LanguageCourseResources,
  module: CourseModule,
) {
  const ids = module.resourceLinks?.examSectionIds;
  const matches = ids?.length
    ? resources.examQuestions.filter((question) => ids.includes(question.sectionId))
    : resources.examQuestions.slice(0, 4);
  return matches.slice(0, 4);
}

function countVocabularyEntries(resources: LanguageCourseResources) {
  return resources.vocabularyCategories.reduce(
    (total, category) => total + category.entries.length,
    0,
  );
}

function countKanjiEntries(resources: LanguageCourseResources) {
  return resources.kanjiGroups.reduce(
    (total, group) => total + group.entries.length,
    0,
  );
}

function countExamQuestions(resources: LanguageCourseResources) {
  return resources.examQuestions.length;
}

function StudyBankIntro(props: {
  examCount: number;
  questionCount: number;
  kanjiCount: number;
  resources: LanguageCourseResources;
  vocabCount: number;
}) {
  return (
    <div className="rounded-[1.5rem] border border-white/10 bg-black/20 p-5">
      <p className="text-xs uppercase tracking-[0.32em] text-emerald-100">
        N5 Study Bank
      </p>
      <p className="mt-3 text-sm leading-7 text-stone-200">
        This course now includes a structured vocabulary bank, the essential
        kanji bank, and the final exam coverage needed for a full JLPT N5
        journey.
      </p>
      <div className="mt-4 flex flex-wrap gap-3">
        <StatPill
          label={`${props.resources.vocabularyCategories.length} vocab categories`}
        />
        <StatPill label={`${props.vocabCount} vocabulary entries`} />
        <StatPill label={`${props.kanjiCount} kanji entries`} />
        <StatPill label={`${props.examCount} exam sections`} />
        <StatPill label={`${props.questionCount} exam questions`} />
      </div>
    </div>
  );
}

function StudyBankGrid(props: {
  exam: ExamSection[];
  kanji: KanjiGroup[];
  vocab: VocabularyCategory[];
}) {
  return (
    <div className="grid gap-4 xl:grid-cols-3">
      <SectionCard title="Vocabulary Bank">
        <div className="space-y-3">
          {props.vocab.map((category) => (
            <VocabCategoryCard key={category.id} category={category} />
          ))}
        </div>
      </SectionCard>
      <SectionCard title="Kanji Bank">
        <div className="space-y-3">
          {props.kanji.map((group) => (
            <KanjiGroupCard key={group.id} group={group} />
          ))}
        </div>
      </SectionCard>
      <SectionCard title="Exam Coverage">
        <div className="space-y-3">
          {props.exam.map((section) => (
            <ExamSectionCard key={section.id} section={section} />
          ))}
        </div>
      </SectionCard>
    </div>
  );
}

function QuestionBankSection(props: { questions: ExamQuestion[] }) {
  return (
    <SectionCard title="Module Question Bank">
      <div className="grid gap-4 xl:grid-cols-2">
        {props.questions.map((question) => (
          <QuestionCard key={question.id} question={question} />
        ))}
      </div>
    </SectionCard>
  );
}

export function CourseStudyBank(props: {
  module: CourseModule;
  resources?: LanguageCourseResources;
}) {
  if (!props.resources) {
    return null;
  }

  const vocab = selectVocabulary(props.resources, props.module);
  const kanji = selectKanji(props.resources, props.module);
  const exam = selectExamSections(props.resources, props.module);
  const questions = selectExamQuestions(props.resources, props.module);
  const vocabCount = countVocabularyEntries(props.resources);
  const kanjiCount = countKanjiEntries(props.resources);
  const questionCount = countExamQuestions(props.resources);

  return (
    <section className="space-y-4">
      <StudyBankIntro
        resources={props.resources}
        vocabCount={vocabCount}
        kanjiCount={kanjiCount}
        examCount={props.resources.examSections.length}
        questionCount={questionCount}
      />
      <StudyBankGrid vocab={vocab} kanji={kanji} exam={exam} />
      <QuestionBankSection questions={questions} />
    </section>
  );
}
