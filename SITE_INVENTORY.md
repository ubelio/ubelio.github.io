# SITE_INVENTORY.md

Every HTML file in the repo, grouped by folder, with a one-line description of what it is. Generated as a snapshot of the current `main` branch — re-generate rather than hand-editing when pages are added or removed.

## Root

| File | What it is |
|---|---|
| `index.html` | Homepage — bio, skills, certifications |
| `projects.html` | Hub page — links to every project writeup (in `projects/` and three at repo root) |
| `labs.html` | Top-level hub — links to `agentacademy.html`, `ms102labs.html`, `sc200labs.html`, the five lab-category hub pages below, plus 4 "Coming Soon" placeholder `<li>` entries (`href="#"`, no pages yet) for SC-300, AZ-104, MD-102, AZ-500 |
| `ms102labs.html` | Hub page — links to the 11 `MS-102Labs/` lab writeups |
| `sc200labs.html` | Hub page — links to the 9 `SC-200Labs/` lab writeups |
| `scripts.html` | Hub page — PowerShell scripts with excerpts, download links, and links back to project writeups |
| `homelabconfig.html` | Writeup — home lab equipment and configuration |
| `homelabfirewall.html` | Hub page — links to the `FirewallSetup/` lab writeups |
| `contact.html` | Contact info + resume download |
| `DLPInformationProtection.html` | Hub page — links to the `DLP-Labs/` lab writeups |
| `SC-401labs.html` | Hub page — links to the `SC-401Labs/` lab writeups (h1 now reads "SC-401: Microsoft Information Protection Administrator") |
| `Misc.html` | Hub page — links to the `Misc/` lab writeup(s) |
| `appliedskills.html` | Hub page — links to the 23 `AppliedSkills/` credential writeups |
| `agentacademy.html` | Hub page — links to the `AgentAcademy/` lab writeups (Rank Progression, Special Ops, Cowork Collective tracks); also carries `.coming-soon` entries for ranks/missions not yet completed |
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

## `AgentAcademy/` (7 files)

Copilot Studio Agent Academy lab writeups, linked from `agentacademy.html`. Badge-image pattern distinct from `AppliedSkills/` — At a Glance table, Overview, What I Built, View Badge link (see `CLAUDE.md` §2 and `WORKFLOW.md`'s "Adding an Agent Academy Page" section). See `LABS_INVENTORY.md` for the full per-file breakdown. 3 more pages (Cowork Collective track) are linked from the hub but not yet built.

## `MS-102Labs/` (11 files)

MS-102 exam prep lab writeups, linked from `ms102labs.html`. Completed in a personal Microsoft 365 test tenant using official MicrosoftLearning GitHub lab instructions and Microsoft Learn exercises. Same text-only structure as other lab writeup pages (no screenshots).

| File | What it is |
|---|---|
| `ms102-lab1.html` | Lab 1 — Tenant initialization, users, groups, custom domain |
| `ms102-lab2.html` | Lab 2 — Admin roles, monitoring, M365 Apps |
| `ms102-lab3.html` | Lab 3 — Identity synchronization with Entra Connect |
| `ms102-lab4.html` | Lab 4 — Secure user access and PIM workflows |
| `ms102-lab5.html` | Lab 5 — Safe Attachments and Safe Links (Defender for Office 365) |
| `ms102-lab6.html` | Lab 6 — Alert policies and Attack Simulation Training |
| `ms102-lab7.html` | Lab 7 — Retention policies and labels in Microsoft Purview |
| `ms102-lab8.html` | Lab 8 — DLP policy creation and testing |
| `ms102-lab9.html` | Lab 9 — Sensitivity labels and label policies |
| `ms102-lab10.html` | Lab 10 — Conditional Access policies |
| `ms102-lab11.html` | Lab 11 — Authentication methods (MFA, SSPR, passwordless) |

## `SC-200Labs/` (9 files + 11 images)

SC-200 exam prep lab writeups, linked from `sc200labs.html`. Completed across an employer-provided Azure subscription (resources deleted after each lab) and a personal Microsoft 365 E5 test tenant. Pages include embedded lab architecture diagrams sourced from MicrosoftLearning/SC-200T00A-Microsoft-Security-Operations-Analyst under MIT License.

| File | What it is |
|---|---|
| `sc200-lab1.html` | Lab 1 — Microsoft Defender XDR |
| `sc200-lab2.html` | Lab 2 — Microsoft Security Copilot |
| `sc200-lab3.html` | Lab 3 — Purview: Audit, DLP, eDiscovery & Insider Risk |
| `sc200-lab4.html` | Lab 4 — Microsoft Defender for Endpoint |
| `sc200-lab5.html` | Lab 5 — Kusto Query Language (KQL) |
| `sc200-lab6.html` | Lab 6 — Sentinel deployment and data connectors |
| `sc200-lab7.html` | Lab 7 — Sentinel analytics rules, detections, and ASIM |
| `sc200-lab8.html` | Lab 8 — Sentinel incidents, playbooks, and investigation |
| `sc200-lab9.html` | Lab 9 — Sentinel threat hunting, workbooks, and notebooks |

---

**Totals**: 132 HTML files — 17 root, 36 in `projects/`, 11 in `FirewallSetup/`, 14 in `SC-401Labs/`, 3 in `DLP-Labs/`, 1 in `Misc/`, 23 in `AppliedSkills/`, 7 in `AgentAcademy/`, 11 in `MS-102Labs/`, 9 in `SC-200Labs/`.
