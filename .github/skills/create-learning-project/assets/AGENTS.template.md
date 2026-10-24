# Learner and Course Instructions

## Learner profile

- Subject: {{subject}}
- Current level and prior knowledge: {{current_level}}
- Learning goal: {{goal}}
- Target outcome: {{target_outcome}}
- Learning language: {{selected_language}}
- Subject-specific teaching and assessment approach: {{selected_discipline_profile_and_course_adaptations}}
- Practical assignments: {{included_or_declined}}
- Practice format and learner deliverable, if included: {{practice_format_and_deliverable_or_not_applicable}}
- Submission and feedback method, if included: {{submission_and_feedback_method_or_not_applicable}}
- Abbreviation glossary: {{enabled_or_disabled}}
- Assumptions and constraints: {{assumptions_and_constraints}}

<!-- LEARNING-RULES:START source=Alexander-Morlock/create-learning-project-ai-skill version=local sha256={{localized_learning_rules_sha256}} -->
{{localized_learning_rules}}
<!-- LEARNING-RULES:END -->

## Course-specific constraints

{{course_specific_constraints}}

## Updating shared learning rules

- The block between `LEARNING-RULES:START` and `LEARNING-RULES:END` is synchronized from `Alexander-Morlock/create-learning-project-ai-skill`. Keep the learner profile and course-specific constraints outside that block.
- To check for updates, run `.\update-learning-rules.ps1` from the project. It downloads a versioned source file under `.learning-rules\incoming\` and does not edit `AGENTS.md`.
- After downloading, compare the staged source with the managed block, translate the changed guidance into the course's learning language, and present the proposed `AGENTS.md` diff before applying it. Preserve the learner profile, course-specific constraints, and all other project files.
- If `AGENTS.md` has no managed block, treat the project as a legacy project: propose a one-time migration that moves only shared mentoring, roadmap/progress, and safe-file-handling guidance into the marked block. Preserve personalized and course-specific content. Do not edit until the learner approves the diff.
- The `sha256` marker records the checksum of the block body between the marker lines, encoded as UTF-8 after normalizing line endings to LF. If the checksum does not match, stop and reconcile the local edit before updating; do not rewrite the checksum just to bypass the check.
- After an approved update, set the block's `version` marker to the source blob hash shown by the updater and recompute `sha256` for the updated block body. Do not replace or discard learner edits without showing the affected changes and obtaining approval.
