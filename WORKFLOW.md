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
