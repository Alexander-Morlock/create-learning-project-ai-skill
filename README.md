## This is an AI skill for creating a personalized self-learning project in technical or non-technical subjects.
### Clone, run, enjoy :)

To start, open the project in VS Code Copilot Chat and type `/create-course` — it launches the course creation interview with no extra prompt needed.

The skill uses a shared learning workflow and adapts practice, evidence, feedback, and assessment to the subject. Its discipline profiles cover technical work, humanities, and visual or UX design, while allowing other subjects to use methods suited to their own practice.

### Updating learning rules in an existing course

New learning projects include `update-learning-rules.ps1` in their root. Run it from the project to download the latest shared rules from the repository linked in the skill's `SKILL.md`. The script verifies the Git blob hash and stages the source in `.learning-rules\incoming\`; it does not change `AGENTS.md`.

Then ask Copilot to compare the staged source with the `LEARNING-RULES` block in `AGENTS.md`, translate changes into the course language, and show a diff. The updater checks the block's SHA-256 marker first and stops if the local text has changed since it was last approved. Apply the diff only after review, then update the source version and checksum; keep learner-specific profile and course constraints outside the managed block.

Projects created before the updater was added need a one-time bootstrap. From the existing course project root, download the updater only if the destination file does not already exist:

```powershell
if (Test-Path .\update-learning-rules.ps1) { throw 'Updater already exists; inspect it instead of replacing it.' }
Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/Alexander-Morlock/create-learning-project-ai-skill/main/.github/skills/create-learning-project/assets/update-learning-rules.ps1' -OutFile .\update-learning-rules.ps1
```

Inspect the downloaded script, run it, and ask Copilot to propose adding the managed block and moving only shared mentoring, roadmap/progress, and safe-file-handling rules into it. Preserve all learner-specific content and approve the diff before applying it. After bootstrap, future source downloads use `.\update-learning-rules.ps1`.
