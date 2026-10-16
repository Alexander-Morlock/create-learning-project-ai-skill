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
- Whichever language the user selects is authoritative for the entire learning workflow; this rule applies equally to every supported language, not specifically to Russian or any other language. From then on, use the selected language consistently in every user-facing surface: interactive dialog questions and descriptions, answer choices and suggestions, back options, chat messages, clarifications, proposals, confirmations, teaching, summaries, and all generated Markdown content, including `AGENTS.md`, `roadmap.md`, `progress.md`, lessons, and other course documentation.
- Treat the selected language as the explicit priority even if the interface, tool, or surrounding environment is in another language. Do not mix in untranslated words or phrases from another language in authored user-facing text. Translate generic labels and instructions into the selected language; retain only proper names, code, identifiers, commands, filenames, and established technical terms when needed, and explain technical terms in the selected language. If a dialog tool has fixed interface labels that cannot be localized, keep all question text and authored choices in the selected language.

Immediately after the learner selects the language, ask whether they want an automatically maintained abbreviation glossary. This must be the second interview question, asked in the selected language, with clear Yes/No choices and the selectable Back option last. If they decline, proceed directly to the subject question and do not create or maintain a glossary. If they agree, record that choice and include the glossary in the course proposal and project setup.

Ask only one question at a time. Use the available question/choice tool when possible; otherwise ask in chat and wait for the answer.

Whenever practical, give the learner concrete, relevant answer suggestions instead of presenting only an empty free-text field and a `<<< <translated "Back">` choice. Generate the suggestions from the question and what is already known about the learner; for open-ended questions, offer a few useful examples, common categories, or natural answer starters. For example, a question about required or unwanted topics can offer choices such as "No restrictions", "I have topics to include", "I have topics to avoid", and "Both". Do not invent choices that assume facts about the learner, and do not add an abstract catch-all choice such as "Other". Keep free-text entry available so the learner can give an answer that does not match the suggestions.

For a Yes/No question, ask one clear, positive question that can be answered directly with Yes or No. Make sure both choices unambiguously refer to that question. Do not phrase the question or its supporting prompt as an either/or choice (for example, "Do you want A or B?") and then offer Yes/No; ask whether the learner wants A, then let No mean they do not want A. If helpful, describe the Yes outcome in a separate neutral sentence without introducing a competing choice. For example, ask "Would you like practical assignments throughout the course?" with "Yes" and "No" choices; do not follow it with "Include assignments or limit the course to explanations and examples."

In every interview dialog after the first language question, include a visible, selectable `<<< <translated "Back">` option in that same dialog, as the final choice. When using a form tool, configure its string field with an enum/suggestion list containing the concrete answer suggestions followed by this option last; even an open-ended question should have useful suggestions when feasible, rather than only the back option. For questions where no meaningful suggestions can be generated, the list may contain only the back option, and the field must still accept free-text answers. Do not substitute a written instruction, separate message, or hidden behavior for this selectable option. Do not offer it in the first language dialog, because there is no earlier step to return to. When the user selects the back option, show the immediately preceding question again with its current answer preserved for revision. Apply any revised answer as authoritative. Keep later answers that remain consistent, but revisit and update or clarify any later answers affected by the change before continuing.

## 2. Interview for the minimum useful course profile

After language is chosen, gather the information needed to make a specific and realistic course. Ask one question per turn, adapt follow-ups to prior answers, and accept "I don't know" as an answer.

Required information:

1. Subject or skill to learn.
2. Immediately after the subject is known, identify the smallest relevant set of foundational technologies, platforms, or concepts that the subject depends on, then ask the learner to self-assess their level in each. Keep this as one focused question, listing only the essentials and allowing a brief level per item (for example: none, basic, confident, or unsure). Adapt the set to the subject and goal; do not assume every learner needs the same prerequisites, and do not ask about a broad ecosystem inventory.
3. Why the learner wants to learn it and what they want to be able to do.
4. Current level beyond the prerequisite self-assessment: relevant prior experience, topics already understood, and important gaps. Avoid asking them to repeat information they just gave; do not assume knowledge that was not stated.
5. Target level or concrete outcome.
6. Any existing syllabus, roadmap, resources, or topics that must be included or excluded.
7. Whether the learner wants practical assignments throughout the course. Ask only whether they want practical assignments in the course; do not frame this as whether to create an assignment file for the first lesson or imply that practical assignments are limited to the first lesson. If yes, ask in a separate turn for the exact assignment filename, including its extension (for example, `exercise.js` or `practice.py`). For programming subjects, use an extension associated with the language or technology so the editor can syntax-highlight the learner's solution. Do not ask for a filename if the learner declines practical assignments.

For technical subjects, foundational technologies may include the language, runtime, framework, platform, or build/tooling layer needed to understand the target subject. For other subjects, ask about prerequisite concepts or tools only when they materially affect the course. If a key dependency is unfamiliar, account for it in the roadmap at the minimum useful depth before the dependent material; do not expand the course into a full survey or prerequisite course unless the learner wants that.

Ask about schedule, preferred practice format, tools/environment, and accessibility or other constraints only when they materially affect the plan. Use sensible defaults rather than extending the interview unnecessarily.

Practical assignments are opt-in for the course. If the learner declines them, do not add exercises to the roadmap or create assignment files; teach and check understanding through explanations and examples in the learning chat. If the learner opts in, decide with them whether each subtopic needs an assignment. Create the requested file only for the current subtopic. Make assignments concrete and grounded in a plausible situation relevant to the subject or the learner's goal; avoid abstract, context-free drills. Require the learner to apply material already taught, and do not make successful completion depend on untaught concepts or techniques. If that subtopic does not need an assignment by mutual agreement, leave the file otherwise empty and add only a brief comment in the selected language stating that no practical assignment is needed for this subtopic. Do not put theory in any assignment file.

## 3. Propose and confirm the course design

Create a concise proposal in the selected language with:

- learner profile, goal, current level across the relevant foundational technologies/concepts, and assumptions;
- ordered roadmap of topics and subtopics, with clear prerequisites;
- the learning format, including a mentor who teaches from the perspective of an experienced senior practitioner in the subject, and whether practical assignments are included; when included, show the requested assignment filename and extension;
- when assignments are included, whether the first subtopic will have an assignment or has been agreed not to need one;
- whether the learner opted into the automatically maintained abbreviation glossary and, if so, that `thesaurus.md` will be created at the project root;
- the project location and initial files/folders to be created.

Keep the roadmap aligned to the learner's goals and level. Include a concise foundations block before dependent topics when the interview reveals a material gap. Split broad subjects into teachable subtopics, avoid needless breadth, and do not schedule advanced topics before their prerequisites. If the user's goals or answers conflict, clarify before proposing.

Ask the user to confirm or revise the proposal before creating course files. Do not write files until the user approves the proposed scope and roadmap.

## 4. Create the course without overwriting existing work

Use the current workspace unless the user specifies another location. Inspect existing files and folders before writing.

Treat the selected project location as the project root. Before creating or modifying any course file, resolve its full path and verify that it remains inside that root; also ensure that existing symlinks or junctions cannot redirect the write outside it. Apply this check to generated topic and subtopic directory names as well as filenames.

Create or update the following course files in the selected learning language:

- `AGENTS.md`: learner profile, mentor role, language, tutoring approach, progress rules, and course-specific constraints.
- `roadmap.md`: ordered topics and their subtopics, using exact titles consistently.
- `progress.md`: initial learner context and explicit status of completed, in-progress, and next items.
- If practical assignments were accepted, create `src/NN - Topic/NN - Subtopic/<learner-requested-filename>` for the first subtopic only. Decide with the learner whether that subtopic needs an assignment.
- If the learner opted into the abbreviation glossary, create `thesaurus.md` at the project root, alongside `roadmap.md`. Start with a localized title equivalent to “Abbreviation Glossary”; add letter headings and entries as abbreviations are encountered in learning content.

Treat the requested assignment filename as one filename component, never as a path. Reject it and ask the learner for a safe replacement if it contains `/` or `\`, is `.` or `..`, is absolute, includes a drive or network path, or is invalid/reserved on the current operating system. Do not silently strip path components or change the requested name. Convert roadmap titles into single safe directory components without allowing separators, `.` or `..` components, or absolute paths; preserve the exact titles in `roadmap.md`.

The assignment file replaces `lesson.md`; do not create `lesson.md`. Follow the assignment-writing and scaffold rules in the generated `AGENTS.md`. The file must contain only the concrete task and a clearly marked empty area for the learner's solution, or only the agreed no-assignment comment. Do not put lesson explanations or theory in it.

If practical assignments were declined for the whole course, do not create assignment files or `lesson.md`; deliver explanations and examples in the learning chat. Create only the project files and directories needed by the agreed course design.

Use two-digit, one-based numbering for topic folders in roadmap order, and restart subtopic numbering at `01` inside each topic. Use exact roadmap titles for folder names, replacing only characters forbidden by the operating system; do not change the titles in the roadmap itself.

When assignments are enabled, create only the topic and subtopic folders for the first not-yet-completed subtopic, plus its requested assignment file. Do not create folders for later topics or subtopics in advance. When assignments are disabled, do not create empty topic or subtopic folders just to reserve space.

Never overwrite existing user content. If a target file or folder already contains material, reuse it when compatible. If its content conflicts with the proposed course or cannot safely be merged, stop and ask before changing it. Do not delete or rename existing files without explicit approval.

Initialize `progress.md` to reflect what the learner explicitly said was already completed. Do not mark a subject or subtopic completed merely because the learner has prior experience; clarify whether completion status matters if needed. The next learning item must be the first incomplete subtopic in roadmap order.

When the abbreviation glossary is enabled, follow the glossary-maintenance rules in the generated `AGENTS.md` for the initial lesson and throughout the course. Do not create or update `thesaurus.md` when the learner declined it.

## 5. Verify and report

After approval and file creation:

Verify the generated files against the approved proposal, the creation and safety requirements above, and the appropriate templates below. In the final response, link the created files, summarize the course and first subtopic, mention assumptions, and immediately start teaching it in the selected language. Follow the first-lesson and practice guidance in `AGENTS.template.md`; do not claim checks that were not performed.

Use the following templates as structural guidance, adapting their placeholders and content to the course rather than copying placeholder text literally:

- [AGENTS.template.md](./assets/AGENTS.template.md)
- [roadmap.template.md](./assets/roadmap.template.md)
- [progress.template.md](./assets/progress.template.md)
- [practice.template.md](./assets/practice.template.md)
- [thesaurus.template.md](./assets/thesaurus.template.md)
