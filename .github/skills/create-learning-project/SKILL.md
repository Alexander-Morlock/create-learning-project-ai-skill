---
name: create-learning-project
description: "Create a personalized, topic-agnostic learning project through an interactive learner interview. Use when the user wants to build a course, study plan, roadmap, or mentor project tailored to a subject, goals, and current level."
argument-hint: "Optionally name the subject you want to learn"
user-invocable: true
---

# Create a Personalized Learning Project

Run this workflow when the user wants to create a reusable learning project tailored to them. Ask questions interactively; do not make the user fill out a long form in one turn.

## 1. Establish the course language first

The language question must be the first interview question, before asking about the subject or learner profile.

- Use the system or host locale only if it is explicitly available and reliable. Do not infer it from the user's message, name, repository, or file paths.
- If a reliable locale is available, ask in that language and offer it as the default while allowing the user to choose another.
- If no reliable locale is available, ask the first question in English.
- Make the question easy to answer with a language name. If supported, offer likely options and include the detected language as the recommended default.
- The language the user selects is authoritative. Use it for the interview from that point onward and for all generated Markdown content, including `AGENTS.md`, `ROADMAP.md`, `PROGRESS.md`, lessons, summaries, and any other course documentation.
- Keep code, identifiers, commands, and established technical terms in their conventional form when needed; explain technical terms in the selected learning language.

Ask only one question at a time. Use the available question/choice tool when possible; otherwise ask in chat and wait for the answer.

## 2. Interview for the minimum useful course profile

After language is chosen, gather the information needed to make a specific and realistic course. Ask one question per turn, adapt follow-ups to prior answers, and accept "I don't know" as an answer.

Required information:

1. Subject or skill to learn.
2. Immediately after the subject is known, identify the smallest relevant set of foundational technologies, platforms, or concepts that the subject depends on, then ask the learner to self-assess their level in each. Keep this as one focused question, listing only the essentials and allowing a brief level per item (for example: none, basic, confident, or unsure). Adapt the set to the subject and goal; do not assume every learner needs the same prerequisites, and do not ask about a broad ecosystem inventory.
3. Why the learner wants to learn it and what they want to be able to do.
4. Current level beyond the prerequisite self-assessment: relevant prior experience, topics already understood, and important gaps. Avoid asking them to repeat information they just gave; do not assume knowledge that was not stated.
5. Target level or concrete outcome.
6. Any existing syllabus, roadmap, resources, or topics that must be included or excluded.

For technical subjects, foundational technologies may include the language, runtime, framework, platform, or build/tooling layer needed to understand the target subject. For other subjects, ask about prerequisite concepts or tools only when they materially affect the course. If a key dependency is unfamiliar, account for it in the roadmap at the minimum useful depth before the dependent material; do not expand the course into a full survey or prerequisite course unless the learner wants that.

Ask about schedule, preferred practice format, tools/environment, and accessibility or other constraints only when they materially affect the plan. Use sensible defaults rather than extending the interview unnecessarily.

## 3. Propose and confirm the course design

Create a concise proposal in the selected language with:

- learner profile, goal, current level across the relevant foundational technologies/concepts, and assumptions;
- ordered roadmap of topics and subtopics, with clear prerequisites;
- the learning and practice format;
- the project location and initial files/folders to be created.

Keep the roadmap aligned to the learner's goals and level. Include a concise foundations block before dependent topics when the interview reveals a material gap. Split broad subjects into teachable subtopics, avoid needless breadth, and do not schedule advanced topics before their prerequisites. If the user's goals or answers conflict, clarify before proposing.

Ask the user to confirm or revise the proposal before creating course files. Do not write files until the user approves the proposed scope and roadmap.

## 4. Create the course without overwriting existing work

Use the current workspace unless the user specifies another location. Inspect existing files and folders before writing.

Create or update the following course files in the selected learning language:

- `AGENTS.md`: learner profile, mentor role, language, tutoring approach, progress rules, and course-specific constraints.
- `ROADMAP.md`: ordered topics and their subtopics, using exact titles consistently.
- `PROGRESS.md`: initial learner context and explicit status of completed, in-progress, and next items.
- `src/NN - Topic/NN - Subtopic/lesson.md`: instructions and one appropriate exercise for the first subtopic only.

For programming courses, create runnable code exercise files in the topic folder only when they improve the exercise; keep the lesson instructions in `lesson.md`. For non-programming subjects, choose a practical exercise appropriate to that subject. Do not put a complete solution in the initial exercise.

Use two-digit, one-based numbering for topic folders in roadmap order, and restart subtopic numbering at `01` inside each topic. Use exact roadmap titles for folder names, replacing only characters forbidden by the operating system; do not change the titles in the roadmap itself.

Create only the top-level folder and subtopic folder for the first not-yet-completed subtopic, plus its `lesson.md`. Do not create folders for later topics or subtopics in advance.

Never overwrite existing user content. If a target file or folder already contains material, reuse it when compatible. If its content conflicts with the proposed course or cannot safely be merged, stop and ask before changing it. Do not delete or rename existing files without explicit approval.

Initialize `PROGRESS.md` to reflect what the learner explicitly said was already completed. Do not mark a subject or subtopic completed merely because the learner has prior experience; clarify whether completion status matters if needed. The next learning item must be the first incomplete subtopic in roadmap order.

## 5. Preserve the learning lifecycle in generated `AGENTS.md`

The generated project instructions must establish these rules in the selected language:

- Each learning chat focuses on one current subtopic and follows the roadmap in order.
- At the start of a chat, inspect `PROGRESS.md` and `ROADMAP.md` to determine the next incomplete subtopic. Clarify contradictory or ambiguous progress instead of skipping ahead.
- Explain from simple concepts to precise details, give a small example, then one main exercise. Do not reveal the full solution before the learner attempts it or directly asks for it.
- Review learner answers and code constructively, explaining why corrections matter and relating the material to real practice and interviews when relevant.
- Track the current lesson in `lesson.md`. Do not create `summary.md` before the learner finishes the subtopic.
- When learning and practice are complete, ask the learner to explicitly choose whether to mark the subtopic complete. Only after clear consent, create `summary.md` and update `PROGRESS.md`. Without consent, do neither.
- At subtopic completion, record precise definitions, rules, a small example, practical conclusions, and corrections made during the lesson in `summary.md`.
- A topic is complete only after all its subtopics are complete.
- Do not create future subtopic folders ahead of time. Reuse existing materials and preserve unrelated work.
- Ask clarifying questions when the subject, level, environment, or expected behavior materially changes the correct explanation.

Adapt examples, exercise style, evaluation criteria, and interview framing to the subject. Do not copy programming-specific rules into unrelated subjects unless they apply.

## 6. Verify and report

After approval and file creation:

- Check that the generated file contents are in the chosen language.
- Check numbering, roadmap order, initial progress, and that only the first subtopic folder was created.
- Check that the lesson includes one clear exercise and no complete solution.
- Report the created files with links, summarize the learner profile and first subtopic, and state any assumptions. Do not claim validation that was not performed.

## Completion summaries

Create `summary.md` only after the learner has completed the subtopic and explicitly agreed to mark it complete. Use the format in [summary.template.md](./assets/summary.template.md).

Use the following templates as structural guidance, adapting their placeholders and content to the course rather than copying placeholder text literally:

- [AGENTS.template.md](./assets/AGENTS.template.md)
- [ROADMAP.template.md](./assets/ROADMAP.template.md)
- [PROGRESS.template.md](./assets/PROGRESS.template.md)
- [lesson.template.md](./assets/lesson.template.md)
