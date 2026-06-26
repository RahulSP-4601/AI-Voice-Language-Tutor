import { type VoiceLessonSeed } from "@/lib/course-types";

type JapaneseSeedInput = {
  acceptableResponses: string[];
  checkpoint: string;
  checkpointLabel: string;
  coverage?: string[];
  demoPhrase: string;
  guidedPrompt: string;
  id: string;
  mode: VoiceLessonSeed["mode"];
  missionTitle?: string;
  modelPrompt: string;
  objective: string;
  outcome: string;
  pattern: string;
  replyPrompt: string;
  rewardBadge?: string;
  rewardXp?: number;
  storyHook?: string;
  supportHint?: string;
  supportNote?: string;
  title: string;
};

const DEFAULT_SUPPORT_HINT =
  "Use short native-language rescue notes only when they help the learner return to speaking faster.";
const DEFAULT_SUPPORT_NOTE =
  "Keep corrections warm, practical, and short so the learner stays in motion.";

export function createJapaneseSeed(input: JapaneseSeedInput): VoiceLessonSeed {
  return {
    acceptableResponses: input.acceptableResponses,
    checkpoint: input.checkpoint,
    checkpointLabel: input.checkpointLabel,
    coverage: input.coverage ?? [input.pattern, input.replyPrompt, input.checkpointLabel],
    demoPhrase: input.demoPhrase,
    guidedPrompt: input.guidedPrompt,
    id: input.id,
    mode: input.mode,
    missionTitle: input.missionTitle ?? input.title,
    modelPrompt: input.modelPrompt,
    objective: input.objective,
    outcome: input.outcome,
    pattern: input.pattern,
    replyPrompt: input.replyPrompt,
    rewardBadge: input.rewardBadge ?? `${input.title} Badge`,
    rewardXp: input.rewardXp ?? 10,
    state: "not_started",
    storyHook: input.storyHook ?? input.objective,
    supportHint: input.supportHint ?? DEFAULT_SUPPORT_HINT,
    supportNote: input.supportNote ?? DEFAULT_SUPPORT_NOTE,
    title: input.title,
  };
}
