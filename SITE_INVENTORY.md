# SITE_INVENTORY.md

Every HTML file in the repo, grouped by folder, with a one-line description of what it is. Generated as a snapshot of the current `main` branch — re-generate rather than hand-editing when pages are added or removed.

## Root

| File | What it is |
|---|---|
| `index.html` | Homepage — bio, skills, certifications |
| `projects.html` | Hub page — links to every project writeup (in `projects/` and three at repo root) |
| `labs.html` | Top-level hub — links to the five lab-category hub pages below, plus 6 "Coming Soon" placeholder `<li>` entries (`href="#"`, no pages yet) for MS-102, SC-200, SC-300, AZ-104, MD-102, AZ-500 |
| `scripts.html` | Hub page — PowerShell scripts with excerpts, download links, and links back to project writeups |
| `homelabconfig.html` | Writeup — home lab equipment and configuration |
| `homelabfirewall.html` | Hub page — links to the `FirewallSetup/` lab writeups |
| `contact.html` | Contact info + resume download |
| `DLPInformationProtection.html` | Hub page — links to the `DLP-Labs/` lab writeups |
| `SC-401labs.html` | Hub page — links to the `SC-401Labs/` lab writeups (h1 now reads "SC-401: Microsoft Information Protection Administrator") |
| `Misc.html` | Hub page — links to the `Misc/` lab writeup(s) |
| `appliedskills.html` | Hub page — links to the 23 `AppliedSkills/` credential writeups |
| `leading-ai-implementation.html` | Project writeup — sits at repo root, not in `projects/` (see note below) |
| `power-automate-flows.html` | Project writeup — sits at repo root, not in `projects/` (see note below) |
| `power-platform-implementation.html` | Project writeup — sits at repo root, not in `projects/` (see note below) |

**Note**: the three AI/Power Platform project pages above are linked from `projects.html` (as "Project -10", "-9", "-8") but live at the repo root instead of inside `projects/`, unlike every other project writeup. Not something this inventory fixes — just flagging the inconsistency for whoever edits these next.

## `projects/` (36 files)

One HTML writeup per professional project — see `PROJECTS_INVENTORY.md` for the full per-file breakdown (title + summary).

## `FirewallSetup/` (11 files)

Lab writeups — homelab OPNsense/VLAN/switch configuration series, linked from `homelabfirewall.html`. See `LABS_INVENTORY.md` for the full per-file breakdown.

## `SC-401Labs/` (14 files)

Lab writeups — SC-401 certification exam prep labs, linked from `SC-401labs.html`. See `LABS_INVENTORY.md` for the full per-file breakdown.

## `DLP-Labs/` (3 files)

Lab writeups — Microsoft Purview DLP / compliance labs, linked from `DLPInformationProtection.html`. See `LABS_INVENTORY.md` for the full per-file breakdown.

## `Misc/` (1 file)

| File | What it is |
|---|---|
| `Misc/imacwindows.html` | Lab writeup — repurposing unsupported Intel iMacs as Windows 11 workstations, linked from `Misc.html` |

## `AppliedSkills/` (23 files)

Microsoft Applied Skills credential writeups, linked from `appliedskills.html`. Each follows a distinct sub-pattern from the other lab folders — At a Glance table, Overview, Skills Assessed, View Credential link (see `CLAUDE.md` §2 and `WORKFLOW.md`'s "Adding an Applied Skills Page" section). See `LABS_INVENTORY.md` for the full per-file breakdown.

---

**Totals**: 102 HTML files — 14 root, 36 in `projects/`, 11 in `FirewallSetup/`, 14 in `SC-401Labs/`, 3 in `DLP-Labs/`, 1 in `Misc/`, 23 in `AppliedSkills/`.
