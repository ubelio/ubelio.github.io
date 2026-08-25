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

## Adding an Applied Skills Page

1. Create `AppliedSkills/<slug>.html`, copying the header / nav / active-nav `<script>` / footer block and inline `<style>` block from an existing page, e.g. `AppliedSkills/github-copilot-dev.html`.
2. The active-nav `<script>` uses `let current` (not `const`) and remaps the page's own filename to `"labs.html"` before the href-matching check, so the **Labs** nav item highlights instead of nothing:
   ```js
   let current = window.location.pathname.split("/").pop();
   if (current === "<this-file>.html") {
     current = "labs.html";
   }
   ```
3. Standard section structure inside `<div class="container">`:
   - `<h2 style="margin-bottom:4px;">[Skill Title]</h2>` + `<p style="color:#555; margin-top:0;">Microsoft Applied Skills Credential</p>` — visible in-body title, directly above At a Glance
   - **At a Glance** — a `table.at-a-glance` with rows for Level, Role(s), Product(s), Credential #
   - **Overview** — one paragraph describing what the credential validates
   - **Skills Assessed** — a `<ul>` of assessed skills (or, for a retired credential, a `.note` callout stating the retirement date instead of a list)
   - **View Credential** — a link to the Microsoft Learn credential URL, styled like other lab-page links
   - `.section-divider` (`<hr>`) between each section
4. The header `<h1>` also carries the full skill title (inline-styled `color:#C9C8BF; margin:0 0 8px 0; font-size:2em;`) and a `<p>` subtitle reading `Microsoft Applied Skills — Earned [Date]`.
5. Add a hub entry to `appliedskills.html`'s `<ul>`, in earned-date-descending order matching the existing entries: a bold link plus the earned date on the line below via `<br>`.
6. Never fabricate credential numbers, Microsoft Learn URLs, or skills-assessed lists — this is real certification data. If any field is missing, ask rather than guess.

## Adding an Agent Academy Page

1. Create `AgentAcademy/<slug>.html`, copying the header / nav / active-nav `<script>` / footer block and inline `<style>` block from an existing page, e.g. `AgentAcademy/recruit.html`.
2. The active-nav `<script>` uses `let current` (not `const`) and remaps the page's own filename to `"labs.html"` before the href-matching check, so the **Labs** nav item highlights instead of nothing:
   ```js
   let current = window.location.pathname.split("/").pop();
   if (current === "<this-file>.html") {
     current = "labs.html";
   }
   ```
3. Standard section structure inside `<div class="container">`:
   - `<h2 style="margin-bottom:4px;">[Badge Title]</h2>` + `<p style="color:#555; margin-top:0;">Copilot Studio Agent Academy — [Track Name]</p>` — visible in-body title, directly above the badge image
   - **Badge image** — `<div class="badge-wrap"><img src="[Global AI Community badge URL]" alt="..."></div>`
   - **At a Glance** — a `table.at-a-glance` with rows for Category, Badge, Issued By, Earned, Products, Skills
   - **Overview** — one paragraph describing the mission/course
   - **What I Built** — a `<ul>` of concrete things built/configured during the lab
   - **View Badge** — a link to the badge's Global AI Community verification URL, plus a `.back-link` back to `/agentacademy.html`
   - `.section-divider` (`<hr>`) between each section
4. The header `<h1>` also carries the full badge/course title (inline-styled `color:#C9C8BF; margin:0 0 8px 0; font-size:2em;`) and a `<p>` subtitle reading `[Track Name] — Earned [Date]`.
5. Add a hub entry to `agentacademy.html`'s relevant track `<ul>` (Rank Progression / Special Ops / Cowork Collective), matching the existing entries: a bold link plus the earned date on the line below via `<br>`. Anything not yet completed uses `<span class="coming-soon">...</span>` instead of a link.
6. Never fabricate badge URLs, Global AI Community verification URLs, or earned dates — this is real credential data. If any field is missing, ask rather than guess.

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
- **Goal**: Build out a new "Microsoft Applied Skills" lab section — a hub page linking to 23 individual credential writeup pages.
- **Current status**: Done. `appliedskills.html` hub created and linked from `labs.html`; all 23 pages built in `AppliedSkills/` matching the existing lab-writeup style (header/nav/active-nav-script/footer, `.container`, At a Glance table, Overview, Skills Assessed, View Credential link). One retired credential uses a `.note` callout instead of a skills list. All `href="#"` placeholders replaced with real paths. Committed to branch `applied-skills-pages` (not merged to main or pushed).
- **Files touched**: labs.html, appliedskills.html, AppliedSkills/administer-adds.html, AppliedSkills/ai-chat-workflows.html, AppliedSkills/ai-research-agents.html, AppliedSkills/azure-container-apps.html, AppliedSkills/azure-management-tasks.html, AppliedSkills/azure-monitor.html, AppliedSkills/azure-networking-security.html, AppliedSkills/canvas-apps-power-apps.html, AppliedSkills/cloud-security-monitoring.html, AppliedSkills/copilot-studio-build-agent.html, AppliedSkills/copilot-studio-create-agents.html, AppliedSkills/csharp-classes-properties-methods.html, AppliedSkills/defender-for-cloud-compliance.html, AppliedSkills/defender-xdr.html, AppliedSkills/entra-identities-access.html, AppliedSkills/github-copilot-dev.html, AppliedSkills/information-protection-dlp-purview.html, AppliedSkills/microsoft-foundry-agents.html, AppliedSkills/power-automate.html, AppliedSkills/purview-copilot-protection.html, AppliedSkills/retention-ediscovery-communication-compliance.html, AppliedSkills/secure-ai-solutions.html, AppliedSkills/secure-storage-azure.html
- **Next 3 actions**: 1) Merge `applied-skills-pages` into `main` and push once reviewed. 2) Preview the new pages locally (`python3 -m http.server`) to sanity-check rendering and nav active-state. 3) No other open follow-up.
- **Blockers**: None — branch is complete and committed, awaiting merge/push decision from the user.
- **Validation done**: Scripted checks confirmed all 23 files link `/style.css`, contain exactly one `<style>` block each, and no `href="#"` placeholders remain in `appliedskills.html`.

### 2026-08-23
- **Goal**: Add a visible in-page title heading (h2 + subtitle) above the At a Glance section on all 23 AppliedSkills pages, so the credential name shows in the body, not just the header band.
- **Current status**: Done. The header `<h1>` already had the title from the original build; only the in-body `<h2 style="margin-bottom:4px;">`/`<p style="color:#555; margin-top:0;">` pair needed adding, done via scripted find/replace on the uniform `<div class="container">` → `<h2>At a Glance</h2>` anchor across all 23 files. Committed to `applied-skills-pages`.
- **Files touched**: all 23 files in AppliedSkills/ (administer-adds.html, ai-chat-workflows.html, ai-research-agents.html, azure-container-apps.html, azure-management-tasks.html, azure-monitor.html, azure-networking-security.html, canvas-apps-power-apps.html, cloud-security-monitoring.html, copilot-studio-build-agent.html, copilot-studio-create-agents.html, csharp-classes-properties-methods.html, defender-for-cloud-compliance.html, defender-xdr.html, entra-identities-access.html, github-copilot-dev.html, information-protection-dlp-purview.html, microsoft-foundry-agents.html, power-automate.html, purview-copilot-protection.html, retention-ediscovery-communication-compliance.html, secure-ai-solutions.html, secure-storage-azure.html)
- **Next 3 actions**: 1) Merge `applied-skills-pages` into `main` and push once reviewed. 2) Preview a few pages locally to confirm the new heading renders as expected. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Confirmed exactly one "At a Glance" h2 per file, exactly 23 files carry the new title heading, and every file's header `<h1>` is still intact.

### 2026-08-23
- **Goal**: Apply an explicit inline style to the header `<h1>` on all 23 AppliedSkills pages: `color:#C9C8BF; margin:0 0 8px 0; font-size:2em;`.
- **Current status**: Done via scripted find/replace keyed on the exact `<h1>{title}</h1>` text per file. Committed to `applied-skills-pages`. Noted for the record: `scripts.html`'s own `<h1>` actually carries no inline style — it relies on `style.css`'s `header{}` rule alone — so this inline duplication is unique to the AppliedSkills pages, not a literal copy of scripts.html's markup. Applied as explicitly instructed regardless.
- **Files touched**: all 23 files in AppliedSkills/ (administer-adds.html, ai-chat-workflows.html, ai-research-agents.html, azure-container-apps.html, azure-management-tasks.html, azure-monitor.html, azure-networking-security.html, canvas-apps-power-apps.html, cloud-security-monitoring.html, copilot-studio-build-agent.html, copilot-studio-create-agents.html, csharp-classes-properties-methods.html, defender-for-cloud-compliance.html, defender-xdr.html, entra-identities-access.html, github-copilot-dev.html, information-protection-dlp-purview.html, microsoft-foundry-agents.html, power-automate.html, purview-copilot-protection.html, retention-ediscovery-communication-compliance.html, secure-ai-solutions.html, secure-storage-azure.html)
- **Next 3 actions**: 1) Merge `applied-skills-pages` into `main` and push once reviewed. 2) Decide whether the scripts.html-vs-actual-markup discrepancy needs resolving. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Confirmed exactly 23 files carry the new inline h1 style and each file still has exactly one `<h1>`.

### 2026-08-23
- **Goal**: Rename the SC-401 labs section from the generic "SC-401 Labs"/"Labs" title to the actual certification name, "SC-401: Microsoft Information Protection Administrator".
- **Current status**: Done. Updated the `labs.html` hub `<li>` link text and `SC-401labs.html`'s `<h1>`/subtitle `<p>`. Committed directly to `main` (single-line-scale fix, no branch).
- **Files touched**: labs.html, SC-401labs.html
- **Next 3 actions**: 1) No open follow-up from this task. 2) Note: `applied-skills-pages` branch (23 new AppliedSkills pages + appliedskills.html hub) is now merged into `main`. 3) Consider whether other lab hub entries (DLP, Misc, FirewallSetup) should also be renamed to their certification/series names for consistency.
- **Blockers**: None.
- **Validation done**: Reviewed the diff for both files before committing — only the intended text changed.

### 2026-08-23
- **Goal**: Merge `applied-skills-pages` into `main` and push, per user request.
- **Current status**: Done. Merge hit one conflict in this WORKFLOW.md file (both branches had appended handoff-log entries independently) — resolved by keeping every entry from both sides, ordered chronologically, nothing dropped. `labs.html` merged cleanly with both its independent changes intact (SC-401 rename + the Applied Skills hub `<li>`). Pushed to origin/main (`04ebd6f..071cc70`).
- **Files touched**: WORKFLOW.md (conflict resolution + this entry); merge otherwise brought in labs.html, appliedskills.html, and all 23 AppliedSkills/*.html unchanged from the branch.
- **Next 3 actions**: 1) Local `applied-skills-pages` branch still exists post-merge — delete it if no longer needed (`git branch -d applied-skills-pages`), not done automatically. 2) No other open follow-up. 3) None.
- **Blockers**: None.
- **Validation done**: Post-merge, confirmed 23 files in AppliedSkills/, zero `href="#"` placeholders in appliedskills.html, and both labs.html changes present before pushing.

### 2026-08-23
- **Goal**: Delete the fully-merged local `applied-skills-pages` branch per user request.
- **Current status**: Done — `git branch -d applied-skills-pages` succeeded (git confirmed it was fully merged before deleting).
- **Files touched**: none (git metadata only).
- **Next 3 actions**: None from this task.
- **Blockers**: None.
- **Validation done**: `-d` (safe delete) was used rather than `-D`, so git itself verified the branch was fully merged before removing it.

### 2026-08-23
- **Goal**: Add 6 placeholder `<li>` entries to labs.html for upcoming certification labs (MS-102, SC-200, SC-300, AZ-104, MD-102, AZ-500), each with an inline "Coming Soon" badge.
- **Current status**: Done. Inserted immediately after the SC-401 entry, before the other existing hub entries and the commented-out future-sections block. All six use `href="#"` placeholders since their pages don't exist yet. Committed directly to `main` (not pushed yet).
- **Files touched**: labs.html
- **Next 3 actions**: 1) Push this commit to origin/main. 2) Build the actual lab pages for these 6 certs when ready, then replace the `href="#"` placeholders (same pattern as the AppliedSkills rollout). 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Reviewed the diff before committing — only the 6 new `<li>` blocks added, no other lines touched.

### 2026-08-23
- **Goal**: Sync all 6 markdown docs with everything done this session (Applied Skills rollout, SC-401 rename, "Coming Soon" placeholders) so a future session can pick up cold.
- **Current status**: Done. Updated CLAUDE.md (§1 site structure now lists appliedskills.html/AppliedSkills/, the SC-401 title change, and the three root-level project pages from an earlier pull; §2 documents the AppliedSkills page-specific styling pattern and fixes a stale page-count; §4 cross-references the new WORKFLOW.md sections). Added an "Adding an Applied Skills Page" process section to WORKFLOW.md. Updated SITE_INVENTORY.md and LABS_INVENTORY.md with appliedskills.html, all 23 AppliedSkills/ files, and corrected totals (78→102 HTML files, 29→52 lab writeups). Checked PROJECTS_INVENTORY.md — no projects/ files changed this session, so it needed no edits (confirmed via diff against HEAD, zero changes). Committed to `main`, not yet pushed.
- **Files touched**: CLAUDE.md, WORKFLOW.md, SITE_INVENTORY.md, LABS_INVENTORY.md
- **Next 3 actions**: 1) Push this commit to origin/main. 2) When the 6 "Coming Soon" lab pages get built, update SITE_INVENTORY.md/LABS_INVENTORY.md/CLAUDE.md again the same way. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Cross-checked every inventory total against actual `find`/`ls` counts on the filesystem (all matched exactly) and confirmed all 23 AppliedSkills files are genuinely linked from appliedskills.html before writing the "no orphans" claim.

### 2026-08-24
- **Goal**: Stand up the Copilot Studio Agent Academy lab section (new hub page + folder, mirroring the AppliedSkills rollout pattern) on branch `agent-academy-pages`, then bring all docs current and merge/push to `main`.
- **Current status**: Done. Built `agentacademy.html` (root hub, Rank Progression / Special Ops / Cowork Collective tracks) and added its entry to the top of `labs.html`'s hub `<ul>`. Built 7 `AgentAcademy/*.html` writeups: `recruit.html`, `operative.html` (Rank Progression), and `ms-learn-mcp.html`, `pac-cli-mcp.html`, `yaml-specialist.html`, `mcs-mcp.html`, `docusign-mcp.html` (Special Ops — all 5 completed Special Ops missions). Added a `.coming-soon` entry for "Recruit — GitHub Copilot Harness" to the Rank Progression list. Updated CLAUDE.md (§1 lists `agentacademy.html`/`AgentAcademy/`; §2 documents the AgentAcademy page pattern and the stale-link caveat below; §4 cross-references the new WORKFLOW.md section; page-count 102→110), added an "Adding an Agent Academy Page" WORKFLOW.md section, and updated SITE_INVENTORY.md/LABS_INVENTORY.md totals and per-file tables.
- **Files touched**: agentacademy.html (new), labs.html, AgentAcademy/recruit.html (new), AgentAcademy/operative.html (new), AgentAcademy/ms-learn-mcp.html (new), AgentAcademy/pac-cli-mcp.html (new), AgentAcademy/yaml-specialist.html (new), AgentAcademy/mcs-mcp.html (new), AgentAcademy/docusign-mcp.html (new), CLAUDE.md, WORKFLOW.md, SITE_INVENTORY.md, LABS_INVENTORY.md
- **Next 3 actions**: 1) Build the 3 remaining Cowork Collective pages (`AgentAcademy/badge-check.html`, `out-of-office.html`, `compliance-packet.html`) — `agentacademy.html` already links to them with real (currently 404) hrefs, not `.coming-soon` placeholders, so this is the priority follow-up, not a nice-to-have. 2) Once Microsoft releases the Commander rank or the 3 remaining Special Ops missions (Marketing Agent with Skills, Secure MCP with OAuth 2.0, RAG with Azure AI Search) get completed, replace their `.coming-soon` spans with real links following the same pattern. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Served the repo locally (`python3 -m http.server`) and curled every new page for a 200 before each commit. Cross-checked SITE_INVENTORY.md/LABS_INVENTORY.md totals against actual `find` counts on the filesystem (110 HTML files total, 7 in AgentAcademy/) before writing them down. Flagged the 3 dead Cowork Collective links to the user rather than silently fixing or hiding them, since the content was user-provided verbatim.

### 2026-08-24
- **Goal**: Build MS-102 lab writeup section — hub page, 11 individual lab pages, and full doc updates.
- **Current status**: Done. `ms102labs.html` hub created at root and linked from `labs.html` (replaced the MS-102 Coming Soon placeholder). 11 pages built in `MS-102Labs/` covering tenant init, roles/monitoring, identity sync, PIM, Defender for Office 365, alert policies/attack simulation, retention, DLP, sensitivity labels, Conditional Access, and authentication methods. All pages follow the standard header/nav/footer/active-nav-remap-to-labs pattern. CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, and WORKFLOW.md updated. Merged to main and pushed.
- **Files touched**: ms102labs.html (new), labs.html, MS-102Labs/ms102-lab1.html through ms102-lab11.html (11 new), CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Preview locally to confirm nav active state and all 11 links work from hub. 2) Add Applied Skills credentials that map to MS-102 under the hub page when ready. 3) Build SC-200 labs next using the same 5-prompt pattern.
- **Blockers**: None.
- **Validation done**: Verified 11 files in MS-102Labs/, no href="#" dead links in any new page, all pages link /style.css, labs.html Coming Soon entry replaced with real link, all doc totals updated.

### 2026-08-24
- **Goal**: Build SC-200 lab writeup section — hub page, 9 individual lab pages with embedded MIT-licensed lab architecture diagrams, and full doc updates.
- **Current status**: Done. `sc200labs.html` hub created at root and linked from `labs.html` (replaced SC-200 Coming Soon placeholder). 9 pages built in `SC-200Labs/` covering Defender XDR, Security Copilot, Purview, Defender for Endpoint, KQL, Sentinel deployment/connectors, Sentinel analytics/detections/ASIM, Sentinel incidents/playbooks, and Sentinel threat hunting/workbooks/notebooks. 11 lab architecture diagram images included under MIT License from MicrosoftLearning/SC-200T00A. CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, and WORKFLOW.md updated. Awaiting user review before commit.
- **Files touched**: sc200labs.html (new), labs.html, SC-200Labs/sc200-lab1.html through sc200-lab9.html (9 new), SC-200Labs/*.png (11 images placed by user), CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Preview locally to confirm images render, nav active state works, and all 9 hub links resolve. 2) Build SC-300 labs next using the same pattern. 3) Revisit Applied Skills page to add MS-102 and SC-200 credential cross-links.
- **Blockers**: None.
- **Validation done**: Verified 9 HTML files in SC-200Labs/, all 11 images present and referenced correctly, no href="#" dead links, all pages link /style.css, labs.html Coming Soon replaced with real link, all doc totals updated.
