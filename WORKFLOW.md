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
5. Add a hub entry to `projects.html` under the matching category `<h2>` (Identity & Access, Security & Compliance, Cloud & Governance, AI & Copilot Agent Development, Endpoint Management, Automation & Scripting, Infrastructure — same order as `index.html`'s Technical Skills), **at the top of that category's `<ul>`**, matching the existing `<li>` entry format (comment + `<strong>` title + one-line description + `View Project →` link). Identity & Access starts with a group of "Coming Soon" placeholders: put new real entries directly below that group, and if the new page fulfils one of them, delete that placeholder `<li>` (and its comment) in the same commit. Also add the file to that category's row in `PROJECTS_INVENTORY.md`'s "Hub Categories" table.
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
- Employers are named only on resumes tailored to specific job applications, never on the site.

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

### 2026-08-27
- Goal: Create Pluralsight hands-on labs section — pluralsightlabs.html hub at root, entry on labs.html, all 50 labs as coming-soon placeholders organized into 7 sections. PluralSightLabs/ subfolder planned but not yet populated.
- Current status: Done. Branch pluralsight-labs. Hub and labs.html entry complete. Docs updated. Awaiting commit.
- Files touched: pluralsightlabs.html (new), labs.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- Next 3 actions: 1) Merge pluralsight-labs to main and push. 2) Build individual lab pages in PluralSightLabs/ one at a time (Phase 2 — user will supply content per lab). 3) Flip each coming-soon entry to a real link as pages are built.
- Blockers: None.
- Validation done: Confirmed pluralsightlabs.html links /style.css, all 50 entries present across 7 sections, labs.html entry added at top of hub list.

### 2026-08-27
- Goal: Build the first PluralSightLabs/ page (Implement Defense in Depth on Azure) and flip its coming-soon entry to a real link, then sync all four doc files to reflect progress (1 of 50 planned labs built).
- Current status: Done. `PluralSightLabs/implement-defense-in-depth.html` built following the standard At a Glance / Overview / detail-sections pattern, with active-nav remap to `labs.html`. `pluralsightlabs.html`'s Security-section entry now links to it. Committed directly to `main` and pushed. CLAUDE.md, SITE_INVENTORY.md, and LABS_INVENTORY.md updated with the new file, revised counts (134 total HTML files, 80 lab writeups, 1/50 PluralSightLabs built), and a new `PluralSightLabs/` breakdown section in SITE_INVENTORY.md.
- Files touched: PluralSightLabs/implement-defense-in-depth.html (new), pluralsightlabs.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- Next 3 actions: 1) Build the next PluralSightLabs/ page when the user supplies content (49 remain — see roadmap in LABS_INVENTORY.md). 2) Flip each coming-soon entry to a real link as pages are built, same pattern as this one. 3) No other open follow-up.
- Blockers: None.
- Validation done: Confirmed the new page links /style.css, has exactly one `<style>` block, and the active-nav remap targets its own filename. Confirmed pluralsightlabs.html's Security section now links instead of showing coming-soon for this lab. Cross-checked all doc totals arithmetically before writing them down.

### 2026-08-28
- Goal: Build all 50 Pluralsight lab individual pages in PluralSightLabs/ and flip all hub entries from coming-soon to real links.
- Current status: Done. All 50 labs built across 7 sections. Two sets of duplicate-topic labs consolidated into single pages (Private Link Blob Storage: labs 5 and 23 -> one page; VNet Peering: labs 27 and 31 -> one page), with both hub entries pointing to the same file in each case. Lab 22 (service endpoints) absorbed a shorter duplicate lab with identical content -- no separate page needed. Total new HTML files: 48 individual lab pages in PluralSightLabs/. All hub entries on pluralsightlabs.html flipped to real links.
- Files touched: PluralSightLabs/*.html (48 new files), pluralsightlabs.html (all 50 entries updated), WORKFLOW.md
- Next 3 actions: 1) Update SITE_INVENTORY.md and LABS_INVENTORY.md totals and per-file tables to reflect 48 new PluralSightLabs pages. 2) Update CLAUDE.md page count. 3) Consider adding a Survey Resource Alerts lab page (lab 45) if content becomes available.
- Blockers: None.
- Validation done: All pages link /style.css, active-nav remap to labs.html confirmed in prompt pattern, all hub entries flipped from coming-soon spans to real links.

### 2026-08-28 (later — supersedes the entry above)
- Goal: Finish building the PluralSightLabs/ pages and reconcile the docs to the real end state.
- Current status: Done. 40 HTML pages exist in PluralSightLabs/, covering 48 of 50 planned Pluralsight labs. 2 hub entries remain .coming-soon with no page: "Azure Resource Manager Tagging and Locking Scenarios" (Azure Fundamentals) and "Survey Resource Alerts Using Azure Monitor" (Monitoring). Five pages each consolidate 2-3 related labs into one writeup with per-lab <h2> subsections: SAS storage -> configuration-security-azure-storage-accounts.html (title "Securing Azure Storage with Shared Access Signatures"); Entra ID users/groups -> create-manage-entra-id-users-portal.html (title "Managing Users and Groups in Microsoft Entra ID"); Azure Monitor alerting -> understanding-azure-monitor-alerting.html (title "Azure Monitor Alerting: Rules, Action Groups, and Investigation"); Private Link Blob Storage -> configuring-azure-private-link-blob-storage.html; VNet Peering -> create-configure-vnet-peering-azure.html (linked twice from the hub as the base and "v3" entries). Redundant standalone pages from the consolidations were git rm-ed. Also today: added AZ-500 (Azure Security Engineer Associate) to the Completed certifications list in index.html.
- Files touched: PluralSightLabs/*.html (40 files, net), pluralsightlabs.html, index.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- Doc counts now: 173 total HTML files (40 in PluralSightLabs/); 119 lab writeups.
- Next 3 actions: 1) Build the 2 remaining coming-soon labs when content is supplied. 2) When built, flip their hub spans to links and update the doc counts (40 -> 42 pages, 173 -> 175 HTML, 119 -> 121 writeups, "48 of 50" -> "50 of 50"). 3) No other open follow-up.
- Blockers: None.
- Validation done: ls PluralSightLabs/*.html = 40; find -name "*.html" = 173; grep coming-soon pluralsightlabs.html = 2 real entries (+1 CSS rule); every PluralSightLabs page linked from the hub, create-configure-vnet-peering-azure.html intentionally linked twice.

### 2026-09-02
- **Goal**: Add the last remaining Pluralsight lab page (Survey Resource Alerts Using Azure Monitor) and remove the unresolvable Azure Resource Manager Tagging and Locking Scenarios hub entry.
- **Current status**: Done. Built survey-resource-alerts-azure-monitor.html in PluralSightLabs/; flipped its Monitoring-section hub entry from coming-soon to a real link; deleted the Azure Fundamentals coming-soon entry for Azure RM Tagging entirely. All 49 planned labs now have pages; 0 coming-soon entries remain on pluralsightlabs.html. Docs updated.
- **Files touched**: PluralSightLabs/survey-resource-alerts-azure-monitor.html (new), pluralsightlabs.html, LABS_INVENTORY.md, SITE_INVENTORY.md, CLAUDE.md, WORKFLOW.md
- **Next 3 actions**: 1) Build remaining AgentAcademy Cowork Collective pages (badge-check.html, out-of-office.html, compliance-packet.html). 2) Build Identity & Access advanced project pages when ready. 3) Build out SC-300, AZ-104, MD-102 lab sections.
- **Blockers**: None.
- **Validation done**: Confirm 41 files in PluralSightLabs/, zero coming-soon spans in pluralsightlabs.html, all doc totals match.

### 2026-09-10
- **Goal**: Keep index.html's Certifications section current — add a newly-earned credential and correct its Pursuing-list timing.
- **Current status**: Done. Added SC-500 (Cloud and AI Security Engineer Associate) to Completed. It had briefly been listed under Pursuing with an ETA in the same session before being confirmed complete, so it was removed from Pursuing rather than left duplicated. No lab/writeup files touched — this was an index.html-only content update, not a structural site change, so SITE_INVENTORY.md/LABS_INVENTORY.md/PROJECTS_INVENTORY.md needed no edits.
- **Files touched**: index.html
- **Next 3 actions**: 1) Keep the Completed/Pursuing lists in sync as further certifications land. 2) No other open follow-up from this task. 3) None.
- **Blockers**: None.
- **Validation done**: Reviewed the diff before each commit — only the intended `<li>` moved/edited, nothing else in the section changed.

### 2026-09-25
- **Goal**: Reflect newly-earned SC-100 certification and broaden the "Currently Working On" list on index.html with current cert study targets and Agent Academy / GRC agent work.
- **Current status**: Done. Moved SC-100 (Microsoft Cybersecurity Architect Expert) from Pursuing to Completed. Expanded "Currently Working On" to read: studying for AB-620, AZ-305, and CompTIA Security+; completing Copilot Studio Agent Academy Recruit/Operative/Single Missions Next Gen labs; developing Copilot Studio agents for Company Policy, Automated AI Workflows, and Third-Party Cybersecurity Vendor Assessments (GRC automation); and continuing enterprise Copilot Studio agent development / Azure AI Foundry exploration. No lab/writeup files touched — index.html-only content update, so the file-inventory docs (SITE_INVENTORY.md/LABS_INVENTORY.md/PROJECTS_INVENTORY.md) needed no edits since no HTML pages were added, removed, or renamed.
- **Files touched**: index.html
- **Next 3 actions**: 1) Build the 3 remaining AgentAcademy Cowork Collective pages (`badge-check.html`, `out-of-office.html`, `compliance-packet.html`) once content is ready — still the longest-standing open item (see 2026-08-24 entry). 2) Keep Completed/Pursuing cert lists in sync as AB-620/AZ-305/Security+ land. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Reviewed each commit's diff — confirmed only the intended `<li>` moves/edits landed in the Certifications and Currently Working On sections.

### 2026-09-26
- **Goal**: `git pull` to sync with origin, then bring the markdown docs current against the real repo state.
- **Current status**: Done. Pull fast-forwarded `main` from `cc6f5e7` to `d9da9ca` (the two cert-update commits above, plus a `.DS_Store` change). Verified via `find`/`ls` that every count in SITE_INVENTORY.md, LABS_INVENTORY.md, and PROJECTS_INVENTORY.md still matches the filesystem exactly (174 total HTML files, 41 in PluralSightLabs/, 36 in projects/, etc.) — no HTML pages were added/removed/renamed since the last doc sync, so those three files needed no content changes. The actual drift was this Session Handoff Log itself, which hadn't been updated for the 2026-09-10 and 2026-09-25 sessions despite the standing rule — backfilled both entries above from `git log`/`git show`. Also refreshed README.md, which had gone stale independently of the HTML-file-count docs: wrong Secure Score figure (said 30%→87%, actual project page says 40%→87%), a placeholder `yourusername` GitHub link, and a LinkedIn URL (`ubeliofernandeztabet`) that doesn't match the one actually used site-wide (`ubelio`).
- **Files touched**: WORKFLOW.md (this entry + the two backfilled entries above), README.md
- **Next 3 actions**: 1) Build the 3 remaining AgentAcademy Cowork Collective pages (`badge-check.html`, `out-of-office.html`, `compliance-packet.html`). 2) Keep Completed/Pursuing cert lists in sync as AB-620/AZ-305/Security+ land. 3) No other open follow-up.
- **Blockers**: None.
- **Validation done**: Cross-checked all nine lab-folder counts and the root/projects counts against `find` output before confirming no inventory edits were needed. Confirmed the corrected Secure Score figure and LinkedIn URL against `projects/secure-score.html` and `contact.html`/`index.html` respectively before editing README.md.

### 2026-09-26 (later — same day, continued session)
- **Goal**: Expand index.html's Technical Skills section with detection-engineering/automation-platform detail, move AB-620 to Completed now that it's earned, refresh the "Currently Working On" list to drop stale/completed items, and clean up the pile of stale local branches that had accumulated (19 of them, all from prior sessions' work already merged into `main` under different commit hashes).
- **Current status**: Done, across two commits plus a branch sweep. `6b2ee10` added Sentinel detection-engineering detail, Vulnerability Management, Least Privilege Access Governance, SCIM Provisioning, Enterprise AI Governance & Administration, and Power Automate/Azure Logic Apps to the existing Technical Skills categories — no categories added/removed, just items within existing ones. `f988853` moved AB-620 (AI Agent Builder Associate) from Pursuing to Completed (dropping its ETA to match the Completed-list convention of no ETA), and rewrote "Currently Working On" to remove items that were either completed (AB-620 study) or stale (MFA/CA rollout, Intune/Autopilot modernization, EDR maturity — all longstanding BAU items superseded by more current priorities) in favor of: Sentinel detection-coverage expansion, Azure AI Foundry hardening, an Azure cost cleanup initiative, and building lab writeups for the four certs (SC-300, AZ-104, MD-102, AZ-500) completed since the labs.html placeholders were created. Both commits were made on short-lived feature branches (`homepage-skills-update`, `homepage-currently-working-on`) created outside this session, fast-forward merged into `main`, and pushed. Also swept 19 local branches (`cert-section-update`, `currently-working-update`, `homepage-skills-update`, `homepage-welcome-refresh`, `labs-title-fix`, `pluralsight-labs`, 7 `project-*` branches, `projects-subtitle-update`, `secure-score-addendum`, `skills-incident-tweak`, `tagline-update`, `welcome-skills-update`) that were fully merged into `main` (verified each tip via `git merge-base --is-ancestor` before deleting) but never cleaned up — deleted with `git branch -d`, which independently re-verifies merge status, so nothing was force-deleted. `main` now has zero other local branches and matches `origin/main` exactly. No lab/writeup files touched by either content commit, and file counts are unchanged (174 total HTML files, 36 in `projects/`, 41 in `PluralSightLabs/` — reverified against `find`), so SITE_INVENTORY.md/LABS_INVENTORY.md/PROJECTS_INVENTORY.md/CLAUDE.md needed no edits; only this Session Handoff Log entry was added.
- **Files touched**: index.html (both commits), WORKFLOW.md (this entry)
- **Next 3 actions**: 1) Build the 3 remaining AgentAcademy Cowork Collective pages (`badge-check.html`, `out-of-office.html`, `compliance-packet.html`) — still the longest-standing open item. 2) Build out the SC-300/AZ-104/MD-102/AZ-500 lab writeups now called out in "Currently Working On." 3) Keep Completed/Pursuing cert lists in sync as AZ-305/Security+ land.
- **Blockers**: None.
- **Validation done**: Reviewed each commit's diff before pushing — confirmed only the intended `<li>` items changed within Technical Skills, Certifications, and Currently Working On. Confirmed all 19 deleted branches were ancestors of `main` before removal, and confirmed post-cleanup that `git branch -vv` shows only `main`, tracking `origin/main` with a clean working tree.

### 2026-09-26 (later — projects.html categorization)
- **Goal**: Pull latest from origin, then restructure projects.html from one flat list into 7 category sections matching index.html's Technical Skills order.
- **Current status**: Done on branch `projects-categorization` (created outside this session), pushed to origin — **not yet merged into `main`**, so not live. Pull fast-forwarded `main` `d9da9ca` → `52a3df2`. Commit `8aa4efc` regrouped all 39 project `<li>` entries under 7 `<h2>` headings (Identity & Access, Security & Compliance, Cloud & Governance, AI & Copilot Agent Development, Endpoint Management, Automation & Scripting, Infrastructure) with `<hr class="section-divider">` between sections, adding the same `.section-divider` rule `FirewallSetup/` pages use to projects.html's inline `<style>`. Within each category, entries keep their prior on-page relative order. Only other content change: the SSO entry's `<strong>` title went from the raw filename `SSO-Deployments.html` to `SSO Deployments`. No project writeup files touched.
- **Files touched**: projects.html, WORKFLOW.md (this entry)
- **Next 3 actions**: 1) Merge `projects-categorization` into `main` and push so the change goes live. 2) Optionally fix remaining projects.html title/description typos left untouched by request ("Upgrdaes", "Critial", "Flacon", "ouron prem"). 3) Build the 3 remaining AgentAcademy Cowork Collective pages.
- **Blockers**: None.
- **Validation done**: Scripted check against `HEAD:projects.html` confirmed all 39 `<li>` blocks are byte-identical apart from the SSO title, and that `<head>` (except the added divider rule), header/nav/nav-script, and footer are unchanged.

### 2026-09-26 (later — docs sync + merge for projects.html categorization)
- **Goal**: Bring the markdown docs in line with the new categorized projects.html, then merge `projects-categorization` into `main` and push so it goes live.
- **Current status**: Done. Updated "Adding a Project Page" step 5 (new entries now go at the top of the matching category's `<ul>`, not the top of one flat list). Added a "Hub Categories" table (category → files, 39 total) to PROJECTS_INVENTORY.md. Refreshed the projects.html descriptions in CLAUDE.md, SITE_INVENTORY.md, and README.md. Fast-forward merged `projects-categorization` into `main` and pushed; this supersedes the "not yet merged" status in the previous entry.
- **Files touched**: WORKFLOW.md, PROJECTS_INVENTORY.md, CLAUDE.md, SITE_INVENTORY.md, README.md
- **Next 3 actions**: 1) Optionally fix projects.html typos ("Upgrdaes", "Critial", "Flacon", "ouron prem"). 2) Build the 3 remaining AgentAcademy Cowork Collective pages. 3) Build SC-300/AZ-104/MD-102/AZ-500 lab writeups.
- **Blockers**: None.
- **Validation done**: Hub Categories table counts (14/6/2/5/6/4/2 = 39) checked against the `<li>` count under each `<h2>` in projects.html.

### 2026-10-16
- **Goal**: Remove all resume offerings from the site — resumes are now tailored per job description rather than published.
- **Current status**: Done, committed on `main`, **not pushed** (awaiting user approval). Pulled first (fast-forward `52a3df2` → `555e0bd`). Deleted the "Download My Resume" `<section>` from index.html and the resume button plus its now-unused `.resume-button`/`:hover` CSS from contact.html (header/nav inline overrides untouched, no footer added). `git rm`'d the root resume `.docx`. Docs synced: CLAUDE.md (root assets list, contact.html description, Quirk #3), SITE_INVENTORY.md (contact.html description), WORKFLOW.md (Employer Anonymity line reworded). Unrelated "resume"/".docx" grep hits in `AgentAcademy/operative.html` (lab content about ingesting resumes) and `SC-200Labs/sc200-lab4.html` (attack-sim `.docx` filename) left as-is.
- **Files touched**: index.html, contact.html, root resume .docx (deleted), CLAUDE.md, SITE_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Push `main` once the user approves. 2) Build the 3 remaining AgentAcademy Cowork Collective pages. 3) Build SC-300/AZ-104/MD-102/AZ-500 lab writeups.
- **Blockers**: None — push pending user approval.
- **Validation done**: Repo-wide grep for the resume filename returns zero hits. Served locally on port 5500: index.html and contact.html both HTTP 200, zero case-insensitive "resume"/".docx" matches, each links `/style.css`.

### 2026-10-16 (later — AB-620 placeholder)
- **Goal**: Add an AB-620 (AI Agent Builder Associate) "Coming Soon" placeholder to labs.html, matching the existing SC-300/AZ-104/MD-102/AZ-500 placeholders.
- **Current status**: Done, committed on `main`, **not pushed** (awaiting user approval). Pull was already up to date. Added one `<li>` (`<a href="#">AB-620: AI Agent Builder Associate</a>` + the identical inline "Coming Soon" `<span>`) directly after AZ-500 — the placeholders follow insertion order, not alphabetical/code order. Link text matches how index.html's Certifications list already names AB-620. Updated the placeholder count/list (4 → 5, adding AB-620) in CLAUDE.md §1, SITE_INVENTORY.md, and LABS_INVENTORY.md's intro; no other current-state doc mentions the count (older WORKFLOW.md log entries left untouched). No new pages, so HTML file and lab writeup totals are unchanged.
- **Files touched**: labs.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Push `main` once the user approves. 2) Build lab writeups for the 5 Coming Soon certs (SC-300, AZ-104, MD-102, AZ-500, AB-620). 3) Build the 3 remaining AgentAcademy Cowork Collective pages.
- **Blockers**: None — push pending user approval.
- **Validation done**: Served locally on port 5500: labs.html HTTP 200, links `/style.css`, exactly 5 `<a href="#">` entries each with a "Coming Soon" badge. `git diff` on labs.html shows only the 4 added lines.

### 2026-10-16 (later — CompTIA Security+ placeholder)
- **Goal**: Add a CompTIA Security+ "Coming Soon" placeholder to labs.html, matching the existing Coming Soon placeholders.
- **Current status**: Done, committed on `main`, **not pushed** (awaiting user approval). Pull was already up to date. Found 5 existing placeholders (SC-300, AZ-104, MD-102, AZ-500, AB-620) in insertion order; added one `<li>` (`<a href="#">CompTIA Security+</a>` + the identical inline "Coming Soon" `<span>`) directly after AB-620. Link text matches index.html's Pursuing list — no exam code, no Microsoft wording. Updated the placeholder count/list (5 → 6, adding CompTIA Security+) in CLAUDE.md §1, SITE_INVENTORY.md, and LABS_INVENTORY.md's intro; no other current-state doc mentions the count. No new pages, so HTML file and lab writeup totals are unchanged.
- **Files touched**: labs.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Push `main` once the user approves. 2) Build lab writeups for the 6 Coming Soon certs. 3) Build the 3 remaining AgentAcademy Cowork Collective pages.
- **Blockers**: None — push pending user approval.
- **Validation done**: Served locally on port 5500: labs.html HTTP 200, links `/style.css`, exactly 6 `<a href="#">` entries each with a "Coming Soon" badge. `git diff` on labs.html shows only the 4 added lines.

### 2026-10-16 (later — Recruit GitHub Copilot Harness page)
- **Goal**: Build `AgentAcademy/recruit-github-copilot-harness.html` (Recruit NextGen badge, earned September 28, 2026) and flip its `.coming-soon` entry on agentacademy.html to a real link.
- **Current status**: Done on branch `agent-academy-recruit-nextgen` — committed, **not merged or pushed**. Pull was already up to date. Page built from `AgentAcademy/operative.html`: `<head>`/inline `<style>`/nav/footer copied verbatim (only `<title>` changed), active-nav script remaps the new filename to `labs.html`, content uses only user-supplied data (Products/Skills joined with ` · ` to match operative.html's At a Glance separator). Hub entry replaced in place — after Operative, before Commander — matching earned-date order. Commander and the 3 Special Ops `.coming-soon` spans untouched. Docs: CLAUDE.md (8 of 11 linked AgentAcademy pages exist; 175 HTML files), SITE_INVENTORY.md (8 AgentAcademy files; 175 total), LABS_INVENTORY.md (new Rank Progression row, removed this entry from the not-yet-built note, 121 lab writeups / 8 AgentAcademy).
- **Files touched**: AgentAcademy/recruit-github-copilot-harness.html (new), agentacademy.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Merge `agent-academy-recruit-nextgen` into `main` and push once the user approves. 2) Build the 3 Cowork Collective pages (still 404) and 3 remaining Special Ops missions once the user supplies their data. 3) Build lab writeups for the 6 labs.html Coming Soon certs.
- **Blockers**: None — merge/push pending user approval.
- **Validation done**: Served locally on port 5500: new page and agentacademy.html HTTP 200; new page links `/style.css`, has one `<style>` and one `<h1>`; `<head>`/footer diff against operative.html shows only the `<title>` line differs. All 8 built hub links return 200 (3 Cowork links still 404, pre-existing). Live badge image and verification URL both return 200. `find` confirms 175 HTML files and 8 in AgentAcademy/, matching the docs.

### 2026-10-16 (later — Operative GitHub Copilot Harness page)
- **Goal**: Build `AgentAcademy/operative-github-copilot-harness.html` (Operative NextGen badge, earned October 12, 2026) and add a new Rank Progression entry for it on agentacademy.html.
- **Current status**: Done — committed on branch `agent-academy-operative-nextgen`, fast-forward merged into `main`, and pushed (user approved). Page built from `AgentAcademy/operative.html`: `<head>`/inline `<style>`/nav/footer copied verbatim (only `<title>` changed), active-nav script remaps the new filename to `labs.html`, content uses only user-supplied data (Products/Skills joined with ` · ` to match operative.html). New hub `<li>` inserted after "Recruit — GitHub Copilot Harness" and before Commander (earned-date order). Docs: CLAUDE.md (9 of 12 linked AgentAcademy pages exist; 176 HTML files), SITE_INVENTORY.md (9 AgentAcademy files; 176 total), LABS_INVENTORY.md (new Rank Progression row; 122 lab writeups / 9 AgentAcademy).
- **Files touched**: AgentAcademy/operative-github-copilot-harness.html (new), agentacademy.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Build the 3 Cowork Collective pages (still 404) and 3 remaining Special Ops missions once the user supplies their data. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Delete merged local branches `agent-academy-recruit-nextgen` / `agent-academy-operative-nextgen` if the user wants.
- **Blockers**: None.
- **Validation done**: Served locally on port 5500: new page and hub HTTP 200. Scripted checks: `<style>` byte-identical to operative.html, head (minus title) + footer identical, `/style.css` linked, one `<h1>`, h1/h2 inline styles match, badge `<img>` has the same attrs (src, alt) as operative.html, View Badge href and remap filename correct. All 9 built hub links 200 (3 Cowork links still 404, pre-existing). Badge image: `curl -sI` returns 405 because globalai.community rejects HEAD (same for the already-live Recruit NextGen badge); GET returns 200 image/png with a valid PNG header — user approved proceeding. `find` confirms 176 HTML files / 9 in AgentAcademy/.

### 2026-10-16 (later — Cowork Collective pages)
- **Goal**: Build the 3 missing Cowork Collective pages (`badge-check.html`, `out-of-office.html`, `compliance-packet.html`) that agentacademy.html already linked to (previously 404).
- **Current status**: Done — committed on branch `agent-academy-cowork-collective`, fast-forward merged into `main`, and pushed (user approved). Pages built from `AgentAcademy/operative.html`: `<head>`/inline `<style>`/nav/footer copied verbatim (only `<title>` changed), active-nav script remaps each page's own filename to `labs.html`, content uses only user-supplied data (Products/Skills joined with ` · `). Hub hrefs and "Earned June 25, 2026" dates already matched, so agentacademy.html was not edited. Docs: CLAUDE.md (all 12 linked AgentAcademy pages exist; 179 HTML files; removed §1 "still to be built" and §2 "currently 404" caveats), SITE_INVENTORY.md (12 AgentAcademy files; 179 total; removed "3 more pages not yet built" note), LABS_INVENTORY.md (3 Cowork Collective rows; "Not yet built" note now only Commander + 3 Special Ops missions; 125 lab writeups / 12 AgentAcademy; removed "linked-but-missing" remark).
- **Files touched**: AgentAcademy/badge-check.html, AgentAcademy/out-of-office.html, AgentAcademy/compliance-packet.html (all new), CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Build the 3 remaining Special Ops missions (Marketing Agent with Skills, Secure MCP with OAuth 2.0, RAG with Azure AI Search) once the user supplies data. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Delete merged local `agent-academy-*` branches if the user wants.
- **Blockers**: None.
- **Validation done**: Served locally on port 5500: all 3 pages + hub HTTP 200; every hub link 200 (no Cowork 404s). Per page, scripted checks: `<style>` byte-identical to operative.html, head (minus title) + footer identical, `/style.css` linked, one `<h1>`, h1/h2 inline styles match, badge `<img>` attrs (src, alt) match and non-empty, View Badge href and remap filename correct. Badge images: `curl -sI` returns 405 (globalai.community rejects HEAD); GET returns 200 image/png for all 3 — user approved proceeding. View Badge URLs all 200. `find` confirms 179 HTML files / 12 in AgentAcademy/.

### 2026-10-16 (later — Special Ops completion)
- **Goal**: Build the 3 remaining Special Ops pages (`marketing-agent-skills.html`, `azure-ai-search-rag.html`, `mcp-oauth.html`) and replace their "Not yet completed" `.coming-soon` entries on agentacademy.html with real links.
- **Current status**: Done — committed on branch `agent-academy-special-ops-completion`, fast-forward merged into `main`, and pushed (user approved). Pages built from `AgentAcademy/docusign-mcp.html`: `<head>`/inline `<style>`/nav/footer copied verbatim (only `<title>` changed), subtitles keep docusign's "Special Ops Mission" wording, Category row uses the user-specified "Special Ops", active-nav script remaps each page's own filename to `labs.html`, content uses only user-supplied data. Hub: the 3 spans were replaced with links in chronological order after Docusign (Sept 24, Oct 12, Oct 13). Commander is now the only `.coming-soon` entry. Docs: CLAUDE.md (all 15 linked AgentAcademy pages exist; 182 HTML files), SITE_INVENTORY.md (15 AgentAcademy files; 182 total), LABS_INVENTORY.md (3 Special Ops rows; "Not yet built" note now only Commander; 128 lab writeups / 15 AgentAcademy).
- **Files touched**: AgentAcademy/marketing-agent-skills.html, AgentAcademy/azure-ai-search-rag.html, AgentAcademy/mcp-oauth.html (all new), agentacademy.html, CLAUDE.md, SITE_INVENTORY.md, LABS_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Build the Commander page once Microsoft releases it. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Delete merged local `agent-academy-*` branches if the user wants.
- **Blockers**: None.
- **Validation done**: Served locally on port 5500: 3 pages + hub HTTP 200; all 8 Special Ops links (and every hub link) 200. Per page, scripted checks: `<style>` byte-identical to docusign-mcp.html (which is itself identical to operative.html's), head (minus title) + footer identical, `/style.css` linked, one `<h1>`, h1/h2 inline styles match, badge `<img>` attrs (src, alt) match and non-empty, View Badge href and remap filename correct. Badge images: `curl -sI` returns 405 (globalai.community rejects HEAD); GET returns 200 image/png for all 3 — user approved proceeding. View Badge URLs all 200. `find` confirms 182 HTML files / 15 in AgentAcademy/.

### 2026-10-16 (later — labs.html entry format)
- **Goal**: Make every `<li>` in labs.html's "Lab Sections" list use one format: `<li><a href="..."><strong>Title</strong></a> — description</li>` for live entries; same bold-inside-link title + unchanged "Coming Soon" badge for placeholders.
- **Current status**: Done, committed on `main`, **not pushed** (awaiting user approval). Pull was already up to date. Base pattern taken from the Pluralsight/MS-102/SC-200 entries. Agent Academy's `<strong>`-outside-link, multi-line entry and the 6 multi-line Coming Soon entries collapsed to single lines (badge `<span>` byte-identical, one space before it so rendering is unchanged); DLP entry's trailing space dropped. Text changes: Pluralsight "50" → "49" (hub has 42 entries/41 unique pages, but 5 consolidated pages cover 2–3 labs each, so 49 labs done per LABS_INVENTORY.md); Agent Academy description joined onto one line, wording identical; descriptions added to SC-401 (14), DLP (3), Misc (1 writeup), Home-Lab Firewall (11), Applied Skills (23) — all counts verified with `ls`. Titles, hrefs, order, and the commented-out block unchanged. No doc describes the labs.html entry format, so no other doc edits.
- **Files touched**: labs.html, WORKFLOW.md
- **Next 3 actions**: 1) Push `main` once the user approves. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Build the Agent Academy Commander page once Microsoft releases it.
- **Blockers**: None — push pending user approval.
- **Validation done**: Served locally on port 5500: labs.html HTTP 200, links `/style.css`. Scripted checks against the pre-change `HEAD:labs.html`: all 15 `<li>`s have exactly one `<a>` wrapping exactly one `<strong>`, no line breaks inside any `<li>`; every live entry has " — " + non-empty text after `</a>`; all 6 Coming Soon badges byte-identical; href sequence identical; commented-out block identical; everything outside the `<ul>` identical.

### 2026-10-16 (later — projects.html Coming Soon placeholders)
- **Goal**: Add 7 "Coming Soon" placeholder entries for upcoming Identity & Access project writeups to projects.html.
- **Current status**: Done, committed on `main`, **not pushed** (awaiting user approval). Pull was already up to date. Added as a group at the top of the Identity & Access `<ul>` (top of the project list), in this order: 1) Protected Actions with Authentication Contexts, 2) Access Reviews for PIM, 3) Passwordless Authentication, 4) Hybrid Identity Rollout, 5) Restricted Management Administrative Units (RMAUs), 6) Group Licensing, 7) Break Glass Policy Review and Monitoring via Sentinel. Markup matches labs.html's placeholders: `<a href="#"><strong>Title</strong></a>` + the identical inline-styled "Coming Soon" `<span>` (labs.html has no CSS rule for the badge, so none was added). No description or "View Project" link; each gets a `<!-- Coming Soon placeholder -->` comment instead of a "Project N" number; existing entries/numbering untouched. CLAUDE.md §1 and SITE_INVENTORY.md projects.html descriptions note the 7 placeholders. HTML totals and PROJECTS_INVENTORY.md unchanged (no new pages). **Each placeholder must be removed and replaced with a real entry (comment + `<strong>` title + description + "View Project →" link, per "Adding a Project Page") when its page is built.**
- **Files touched**: projects.html, CLAUDE.md, SITE_INVENTORY.md, WORKFLOW.md
- **Next 3 actions**: 1) Push `main` once the user approves. 2) Build the 7 Identity & Access project pages, replacing each placeholder as its page lands (and update CLAUDE.md/SITE_INVENTORY.md placeholder counts + PROJECTS_INVENTORY.md). 3) Build lab writeups for the 6 labs.html Coming Soon certs.
- **Blockers**: None — push pending user approval.
- **Validation done**: Served locally on port 5500: projects.html HTTP 200, links `/style.css`. Scripted checks against `HEAD:projects.html`: exactly 7 new placeholder `<li>`s (0 before), titles in the requested order, each exactly `href="#"` + `<strong>` title + byte-identical badge with no description/"View Project"; all 39 existing `<li>`s identical in content and order; href sequence equals `["#"]*7` + the old sequence; file line endings consistent (all CRLF).

### 2026-10-16 (later — labs.html regular-weight titles)
- **Goal**: Keep labs.html's "Lab Sections" list in one consistent format, but with regular-weight titles: `<li><a href="...">Title</a> — description</li>` for live entries; `<li><a href="#">Title</a>` + unchanged "Coming Soon" badge for placeholders.
- **Current status**: Done, committed on `main` and pushed (user pre-approved the push). **Decision: lab hub titles are regular weight, not bold** — supersedes the bold-inside-link format from the earlier 2026-10-16 entry. Removed all 15 `<strong>` pairs from the list and deleted the `font-weight: bold;` declaration from labs.html's inline `li a` rule (only `<ul>` on the page, so it only affected the list). `/style.css` untouched (its only bold rule is `nav a`). The Coming Soon badge `<span>` stays bold via its own inline `font-weight:bold;` — left as-is per instructions. Text changes from the earlier pass (Pluralsight 49, Agent Academy one-line, 5 added descriptions) were already present; counts re-verified (SC-401 14, DLP 3, Misc 1, FirewallSetup 11, AppliedSkills 23; Pluralsight hub 42 entries / 41 pages = 49 labs). No doc describes the labs.html entry format, so no other doc edits.
- **Files touched**: labs.html, WORKFLOW.md
- **Next 3 actions**: 1) Build the 7 Identity & Access project pages, replacing each projects.html placeholder as its page lands. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Build the Agent Academy Commander page once Microsoft releases it.
- **Blockers**: None.
- **Validation done**: Served locally on port 5500: labs.html HTTP 200, links `/style.css`. Scripted checks against the pre-change `HEAD:labs.html`: all 15 `<li>`s have exactly one `<a>`, zero `<strong>`/`<b>`, no `font-weight` outside the badge, no line breaks; every live entry has " — " + non-empty text; no `font-weight` left in labs.html's `<style>`; all 6 badges byte-identical; href sequence identical; commented-out block identical; everything outside the `<ul>` (other than the `<style>` edit) identical.

### 2026-10-16 (later — docs sync + branch cleanup)
- **Goal**: Confirm everything is committed/pushed, clean up merged branches, and bring all markdown docs in line with the current site.
- **Current status**: Done, committed on `main` and pushed (user requested). Deleted 4 merged local branches (`agent-academy-recruit-nextgen`, `agent-academy-operative-nextgen`, `agent-academy-cowork-collective`, `agent-academy-special-ops-completion`), each verified as an ancestor of `main` and removed with `git branch -d`; only `main` remains. Doc fixes: CLAUDE.md §1 labs.html bullet now records the Lab Sections entry format (regular-weight `<a>` title + " — " description; placeholders = `href="#"` + Coming Soon badge); CLAUDE.md §2 and SITE_INVENTORY.md agentacademy.html row now say Commander is the only `.coming-soon` entry; PROJECTS_INVENTORY.md notes the 7 Identity & Access Coming Soon placeholders and how to retire them; WORKFLOW.md "Adding a Project Page" step 5 now says new Identity & Access entries go directly below the placeholder group and a fulfilled placeholder is deleted in the same commit; README.md mentions the upcoming project writeups and Coming Soon cert labs. All counts (182 HTML files, 128 lab writeups, 15 AgentAcademy, 39 projects) were already correct.
- **Files touched**: CLAUDE.md, SITE_INVENTORY.md, PROJECTS_INVENTORY.md, README.md, WORKFLOW.md
- **Next 3 actions**: 1) Build the 7 Identity & Access project pages, replacing each projects.html placeholder as its page lands. 2) Build lab writeups for the 6 labs.html Coming Soon certs. 3) Build the Agent Academy Commander page once Microsoft releases it.
- **Blockers**: None.
- **Validation done**: `git status` clean and `git log --branches --not --remotes` empty before starting; scanned every .md for stale counts, "not yet built"/404/Coming Soon wording, resume references, and Secure Score figures against the live HTML. README.md's Secure Score "40% to 87%" matches `projects/secure-score.html` (index.html's 98% refers to a different role), so it was left as-is.

### 2026-10-17
- **Goal**: Add the Microsoft Sentinel SIEM migration project as 4 pages in `projects/` on a new branch `sentinel-pages`.
- **Current status**: Done, committed on `sentinel-pages`; **not merged or pushed** (per instructions). Pull was already up to date. Built `sentinel-siem-migration.html` (hub, full), `sentinel-migration-parity.html` (full), and two stubs, `sentinel-detection-engineering.html` and `sentinel-ingestion-soar.html` (subtitle "Coming Soon", `.note` + Planned Content list). The stubs are linked from the hub's How It Works with a `.coming-soon` span. Only the hub is listed in projects.html, at the top of the **Security & Compliance** `<ul>` (WORKFLOW step 5 puts new entries at the top of their category, not the top of the page), using comment `Project -11`. The Break Glass via Sentinel placeholder is a separate writeup and was left as is. Pages use `<div class="container">` (the task required it, although other `projects/` pages use `<main>`). They have no `og:image` because no diagram exists yet. Wording rules: no employer, industry, dollar figures, or claims that attacks were stopped; no KQL, and scripts.html is untouched. Doc counts: projects/ 36 → 40, total HTML 182 → 186 (the task brief said 174 → 178, but `find` showed 182 before the change), hub writeups 39 → 40, Security & Compliance 6 → 7.
- **Files touched**: projects/sentinel-siem-migration.html, projects/sentinel-migration-parity.html, projects/sentinel-detection-engineering.html, projects/sentinel-ingestion-soar.html, projects.html, PROJECTS_INVENTORY.md, SITE_INVENTORY.md, CLAUDE.md, README.md, WORKFLOW.md
- **Next 3 actions**: 1) Review the branch, then merge and push once approved. 2) Add screenshots/diagrams to the parity page and hub (pending), and an `og:image` once one exists. 3) Write the full detection-engineering and ingestion/SOAR pages to replace the stubs, and finalize the connector list.
- **Blockers**: Screenshots pending; final connector list not confirmed.
- **Validation done**: Served on port 5500: all 4 pages and projects.html returned HTTP 200. Each new page links `/style.css` and has exactly one `<style>` block and the active-nav script. Case-insensitive grep of the new pages for financ/bank/FS-ISAC/`$`/"per month"/"/yr" returned zero hits. All internal `sentinel-*` links resolve. `find` gives 40 `projects/*.html` and 186 HTML files in total, matching the docs.

### 2026-10-17 (later — Sentinel pages live)
- **Goal**: Publish the Sentinel project pages to the live site.
- **Current status**: Done. Pushed `sentinel-pages` to origin, then fast-forwarded `main` to it (`ac326f9..e574634`) and pushed. This replaces the "not merged or pushed" status in the previous entry. The `sentinel-pages` branch still exists locally and on origin.
- **Files touched**: WORKFLOW.md
- **Next 3 actions**: 1) Add screenshots/diagrams and an `og:image` to the Sentinel hub and parity pages. 2) Replace the two Sentinel stub pages with full writeups. 3) Delete the merged `sentinel-pages` branch if no longer needed.
- **Blockers**: None.
- **Validation done**: `git merge --ff-only` succeeded; `main` matches `origin/main` at `e574634` after the push.

### 2026-10-17 (later — Sentinel ongoing-project disclaimer)
- **Goal**: Mark the Sentinel project as ongoing on all 4 pages and on the projects.html entry.
- **Current status**: Done. Committed on `sentinel-pages` (first fast-forwarded to `main`), then fast-forwarded `main` and pushed, since the user asked for it to go live. The hub and parity pages gained a new `.note` (`#E6E5DE` bg / `#0078D4` 4px left border, defined inline) with the exact disclaimer text, placed first inside `.container`. In both stubs, the old "in progress" `.note` wording was replaced with the same text; the "Coming Soon" subtitle and Planned Content lists are unchanged. The projects.html Sentinel entry got an italic grey "Ongoing: still being updated due to project scope." line before "View Project →".
- **Files touched**: projects/sentinel-siem-migration.html, projects/sentinel-migration-parity.html, projects/sentinel-detection-engineering.html, projects/sentinel-ingestion-soar.html, projects.html, WORKFLOW.md
- **Next 3 actions**: 1) Add screenshots/diagrams and an `og:image` to the Sentinel hub and parity pages. 2) Replace the two stubs with full writeups. 3) Remove the disclaimer once the project content is settled.
- **Blockers**: None.
- **Validation done**: The exact disclaimer appears once in each of the 4 pages (4 total). Each page still has exactly one `<style>` block. Forbidden-term grep (financ/bank/FS-ISAC/`$`/"per month"/"/yr") found zero hits. Served on port 5500: all 4 pages and projects.html returned HTTP 200. `find` shows 40 `projects/*.html` and 186 HTML files in total, so no other docs needed count changes.

### 2026-10-17 (later — Power Automate disclaimer + Passkey placeholder)
- **Goal**: Add a "being built" disclaimer to `power-automate-flows.html` and its projects.html entry, and add a Passkey Authentication Deployment Coming Soon placeholder.
- **Current status**: Done. Committed on `projects-updates`, then fast-forwarded `main` and pushed, since the user asked for it to go live. Added a `.note` (defined inline, `#E6E5DE` / 4px `#0078D4`) with the exact disclaimer text as the first child of the page's `<main>`; no other page content changed. Added an italic grey "In progress: still being built." line to the existing Power Automate hub entry. Added the Passkey placeholder at the end of the Identity & Access Coming Soon group, byte-matching the existing placeholder markup. **The requested one-line description was not added**, because none of the existing placeholders has one and the brief required an exact match. Note: "Passkey Authentication Deployment" overlaps the existing "Passwordless Authentication" placeholder. Placeholder count went 7 → 8 in CLAUDE.md, SITE_INVENTORY.md, PROJECTS_INVENTORY.md (list updated), and README.md.
- **Files touched**: power-automate-flows.html, projects.html, CLAUDE.md, SITE_INVENTORY.md, PROJECTS_INVENTORY.md, README.md, WORKFLOW.md
- **Next 3 actions**: 1) Decide whether placeholders should carry descriptions (then add Passkey's) and whether Passkey and Passwordless should be merged. 2) Expand power-automate-flows.html and remove the disclaimer when done. 3) Sentinel screenshots and stub writeups.
- **Blockers**: None.
- **Validation done**: Exact disclaimer appears once in power-automate-flows.html, which still has one `<style>` block. All 8 placeholder `<li>`s are identical apart from the title. projects.html and power-automate-flows.html return HTTP 200 on port 5500. Grep of the added lines for financ/bank/`$` found zero hits. `find` shows 40 `projects/*.html` and 186 HTML files in total, both unchanged.

### 2026-10-17 (later — Defender for Cloud Apps placeholder)
- **Goal**: Add a "Defender for Cloud Apps: Shadow IT Discovery" Coming Soon placeholder to projects.html.
- **Current status**: Done. Committed on `projects-updates` (first fast-forwarded to `main`), then fast-forwarded `main` and pushed, since the user asked for it to go live. Placed at the end of the Identity & Access Coming Soon group, after Passkey; the brief said to match the existing placeholders' placement, although by topic it fits Security & Compliance. The comment, `<li><a href="#"><strong>`, and badge are byte-identical to the other placeholders. As requested, it also adds a `<br>` + description line and the grey italic "Ongoing: detections and policies are still maturing." line, which makes it the only placeholder with a description. Placeholder count went 8 → 9 in CLAUDE.md, SITE_INVENTORY.md, README.md, and PROJECTS_INVENTORY.md (list updated and the description exception noted).
- **Files touched**: projects.html, CLAUDE.md, SITE_INVENTORY.md, PROJECTS_INVENTORY.md, README.md, WORKFLOW.md
- **Next 3 actions**: 1) Decide whether all placeholders should carry descriptions (Passkey's is still pending) and whether the Defender for Cloud Apps placeholder should move to Security & Compliance. 2) Build the Defender for Cloud Apps page once detections and policies mature. 3) Sentinel screenshots and stub writeups.
- **Blockers**: None.
- **Validation done**: All 9 placeholders share the same `<a href="#">` + badge markup, so no placeholder links to a real path and none can 404. projects.html returned HTTP 200 on port 5500. Grep of the added lines for financ/bank/`$`/E5/RHEL/firewall vendor names found zero hits. `find` shows 40 `projects/*.html` and 186 HTML files in total, both unchanged.

### 2026-10-17 (later — Exchange Online transport rule placeholder)
- **Goal**: Add an "Exchange Online Transport Rule Remediation" Coming Soon placeholder to projects.html.
- **Current status**: Done. Committed on `projects-updates` (first fast-forwarded to `main`), then fast-forwarded `main` and pushed, since the user asked for it to go live. Placed at the end of the Identity & Access Coming Soon group, after Defender for Cloud Apps. The comment, `<li><a href="#"><strong>`, and badge are byte-identical to the other placeholders, followed by a `<br>` and the requested description line; there is no "Ongoing" line because none was requested. The description says "email security gateway", not the gateway vendor's name. Placeholder count went 9 → 10 in CLAUDE.md, SITE_INVENTORY.md, README.md, and PROJECTS_INVENTORY.md (list and description note updated).
- **Files touched**: projects.html, CLAUDE.md, SITE_INVENTORY.md, PROJECTS_INVENTORY.md, README.md, WORKFLOW.md
- **Next 3 actions**: 1) Decide on placeholder descriptions (Passkey still has none) and whether non-identity placeholders (Defender for Cloud Apps, Exchange transport rules) should move to their topical categories. 2) Build the placeholder pages as projects complete. 3) Sentinel screenshots and stub writeups.
- **Blockers**: None.
- **Validation done**: All 10 placeholders share the same `<a href="#">` + badge markup, so none can 404. projects.html returned HTTP 200 on port 5500. Grep of the added lines for financ/bank/`$` found zero hits. `find` shows 40 `projects/*.html` and 186 HTML files in total, both unchanged.
