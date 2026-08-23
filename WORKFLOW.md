# WORKFLOW.md

How we operate on this repo, session to session. Pair this with `CLAUDE.md` (site structure and styling conventions) — this file is about process, that one is about the codebase itself.

## Git Rhythm

- Start every session with `git pull`.
- Non-trivial work happens on a branch: `git checkout -b <descriptive-name>`.
- Verify the change locally (see Local Preview below) before merging.
- Commit with a descriptive message: `git add -A`, then `git commit`.
- Merge back to main: `git checkout main`, `git merge <branch>`, `git push`.
- Small single-file fixes (typo, dead link, one-line CSS tweak) can go straight to `main` — no branch needed.

## Local Preview

Every page links `style.css` with an absolute path (`/style.css`), so opening a file directly via `file://` renders it unstyled — the stylesheet won't resolve. Always preview through a local server from the repo root:

- Windows: `py -m http.server 5500`
- Mac: `python3 -m http.server 5500`

Then browse `http://localhost:5500/`.

## Adding a Project Page

1. Create `projects/<slug>.html`, following the conventions in `CLAUDE.md`.
2. Copy the header / nav / active-nav `<script>` / footer block from `projects/microsoft-pim.html`.
3. Include Open Graph meta tags, matching the format in `projects/secure-score.html`.
4. Standard section structure:
   - **The Problem**
   - **What I Built**
   - **How It Works**
   - An `.impact-box` for outcomes
   - A link to the script, if the project has one
5. Add a hub entry to `projects.html`, **at the top of the list**, matching the existing `<li>` entry format (comment + `<strong>` title + one-line description + `View Project →` link).
6. Ship the new page and the hub entry in the **same commit**.

## Adding a Script

1. Save the `.ps1` file to `scripts/`.
2. Add a section to `scripts.html` with:
   - An `<h2>` with an anchor `id`
   - A one-sentence description
   - A **short excerpt only** — 10–15 lines in a `<pre>` block. Match the BitLocker entries for length/style. **Never paste the full script.**
   - A download link to the full `.ps1` file
   - A link back to the project page
3. The project page links to the script section via `/scripts.html#<anchor>`.

## Sanitization Before Publishing Any Script

Before a script excerpt or download goes live, strip:

- Tenant IDs
- Client IDs
- Certificate thumbprints
- Group object GUIDs
- UNC paths
- Server names
- Internal domain names
- Distribution group names
- Email addresses
- Any other employer-identifying strings

Replace each with an empty string plus an inline comment hint (e.g. `$TenantId = ""  # your tenant ID`) rather than a fake placeholder value.

Check **hardcoded strings inside email bodies and report text**, not just the config block at the top — notification templates and report headers are easy to miss and often carry real names/domains.

Add a requirements block listing the Graph/Exchange permissions the script needs to run.

## Employer Anonymity

- Project pages never name the current employer.
- Describe roles generically (e.g. "relationship managers", "client-facing staff") rather than by industry, where naming the industry would identify the organization.
- The resume names employers. The site does not.

## Session Handoff Log

Compact, append-only record of what happened each session, so the next session can pick up cold. Never delete or edit a prior entry — only append a new one at the bottom, even if it corrects an earlier one. Keep each field to a line or two.

Template:
```
### <YYYY-MM-DD>
- **Goal**:
- **Current status**:
- **Files touched**:
- **Next 3 actions**:
- **Blockers**:
- **Validation done**:
```

### 2026-08-23
- **Goal**: Add a Session Handoff Log section to WORKFLOW.md so future sessions have a running handoff record.
- **Current status**: Done — section added with template and this entry.
- **Files touched**: WORKFLOW.md
- **Next 3 actions**: 1) Append a new entry at the end of each future session. 2) Revisit formatting if entries start running long. 3) No open follow-up from this task.
- **Blockers**: None.
- **Validation done**: Read the file back to confirm the new section matches existing heading/list style; no other files touched.

### 2026-08-23
- **Goal**: Make updating the Session Handoff Log a standing habit for every session on this project, not a one-off.
- **Current status**: Standing rule adopted going forward; this entry is the first application of it.
- **Files touched**: WORKFLOW.md
- **Next 3 actions**: 1) Append a new entry like this one at the end of every future session automatically. 2) Keep entries concise/scannable per the user's format. 3) No other open follow-up from this exchange.
- **Blockers**: None.
- **Validation done**: Confirmed only a new entry was appended — prior entries untouched.

### 2026-08-23
- **Goal**: Rename the SC-401 labs section from the generic "SC-401 Labs"/"Labs" title to the actual certification name, "SC-401: Microsoft Information Protection Administrator".
- **Current status**: Done. Updated the `labs.html` hub `<li>` link text and `SC-401labs.html`'s `<h1>`/subtitle `<p>`. Committed directly to `main` (single-line-scale fix, no branch).
- **Files touched**: labs.html, SC-401labs.html
- **Next 3 actions**: 1) No open follow-up from this task. 2) Note: `applied-skills-pages` branch (23 new AppliedSkills pages + appliedskills.html hub) is still unmerged — decide when to merge/push it. 3) Consider whether other lab hub entries (DLP, Misc, FirewallSetup) should also be renamed to their certification/series names for consistency.
- **Blockers**: None.
- **Validation done**: Reviewed the diff for both files before committing — only the intended text changed.
