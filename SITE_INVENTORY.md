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
| `pluralsightlabs.html` | Hub page — Pluralsight hands-on labs in 7 sections (Azure Fundamentals, Networking, Storage, Security, Identity & Governance, Monitoring, AI & Containers); 48 of 50 planned labs done across 40 writeup pages, 2 still coming soon |
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

## `PluralSightLabs/` (40 files)

Pluralsight hands-on lab writeups, linked from `pluralsightlabs.html`. 40 pages covering 48 of 50 planned labs; 2 hub entries remain `.coming-soon`. Five pages each consolidate 2–3 closely related labs into one writeup with per-lab `<h2>` subsections. See `LABS_INVENTORY.md` for the section-by-section breakdown.

| File | What it is |
|---|---|
| `accessing-using-azure-portal.html` | Accessing and Using the Azure Portal |
| `accessing-using-azure-cloud-shell.html` | Accessing and Using the Azure Cloud Shell |
| `deploying-first-azure-virtual-machine.html` | Deploying Your First Azure Virtual Machine |
| `add-existing-data-disk-vm-azure.html` | Add Existing Data Disk to a VM in Azure |
| `troubleshooting-restoring-misconfigured-vm.html` | Troubleshooting and Restoring a Misconfigured Virtual Machine |
| `create-virtual-network-azure.html` | Create a Virtual Network |
| `create-multiple-subnets-azure.html` | Create Multiple Subnets in Azure |
| `create-configure-vnet-peering-azure.html` | Create and Configure VNet Peering in Azure — **consolidated** (2 labs; linked twice from the hub as the base and "v3" entries) |
| `vnet-to-vnet-vpn-gateway.html` | Configuring an Azure VNet-to-VNet VPN Gateway (v2) |
| `implement-custom-network-routes-azure.html` | Implement Custom Network Routes in Azure Virtual Network |
| `implementing-secure-vnet-peering-departmental-networks.html` | Implementing Secure VNet Peering Between Departmental Networks |
| `implement-configure-private-dns-azure.html` | Implement and Configure Private DNS in Azure |
| `access-windows-vms-ssl-azure-bastion.html` | Access Windows VMs over SSL without Public IPs Using Azure Bastion |
| `creating-azure-storage-account-blob-container.html` | Creating an Azure Storage Account and Blob Container |
| `configuration-security-azure-storage-accounts.html` | Securing Azure Storage with Shared Access Signatures — **consolidated** (3 SAS labs: storage account security, secure storage access, limit access via SAS URI) |
| `configuring-azure-private-link-blob-storage.html` | Configuring Azure Private Link for Blob Storage — **consolidated** (2 labs) |
| `create-service-endpoints-vms-blob-storage.html` | Create Service Endpoints Between Virtual Machines and Blob Storage |
| `create-user-delegation-sas-azure-cli.html` | Create a User Delegation SAS Using Azure CLI |
| `create-restore-file-share-snapshots-azure.html` | Create and Restore File Share Snapshots in Azure |
| `expire-data-age-azure-blob-storage.html` | Expire Data Based on Age in Azure Blob Storage |
| `implement-defense-in-depth.html` | Implement Defense in Depth on Azure (layered security: perimeter, network, identity, compute, application, data, security operations) |
| `secure-network-traffic-nsgs-azure-firewall.html` | Secure Network Traffic with NSGs and Azure Firewall |
| `configure-application-level-rules-azure-firewall.html` | Configure Application-Level Rules within Azure Firewall |
| `deploy-secure-web-app-nsgs-private-endpoints.html` | Deploy a Secure Web App Using NSGs and Private Endpoints |
| `securely-access-script-secrets-key-vault.html` | Securely Access Script Secrets in Azure Key Vault |
| `enabling-always-encrypted-azure-sql.html` | Enabling Always Encrypted in Azure SQL |
| `configure-data-masking-azure-sql.html` | Configure Data Masking in Azure SQL Database |
| `applying-azure-disk-encryption-windows-vm.html` | Applying Azure Disk Encryption to a Windows Virtual Machine |
| `setting-up-backup-recovery-compliance.html` | Setting Up Backup and Recovery to Meet Compliance Requirements |
| `deploying-cost-optimized-compute-storage.html` | Deploying a Cost-Optimized Compute and Storage Solution |
| `create-manage-entra-id-users-portal.html` | Managing Users and Groups in Microsoft Entra ID — **consolidated** (3 labs: create/manage users, create group + membership/ownership, organize users & groups for access control) |
| `perform-bulk-entra-id-operations-portal.html` | Perform Bulk Microsoft Entra ID Operations in the Portal |
| `ensuring-compliance-azure-policies.html` | Ensuring Compliance with Azure Policies |
| `using-azure-policy-resource-locks.html` | Using Azure Policy and Resource Locks |
| `cost-planning-management-azure.html` | Cost Planning and Management in Azure |
| `understanding-azure-monitor-alerting.html` | Azure Monitor Alerting: Rules, Action Groups, and Investigation — **consolidated** (3 labs: Activity Log investigation, alert rule via CLI, action groups + alert processing rules) |
| `analyzing-faces-azure-ai.html` | Analyzing Faces with Azure AI |
| `object-detection-azure-custom-vision.html` | Object Detection with Azure Custom Vision |
| `create-web-app-docker-container-azure.html` | Create Web App from Docker Container in Azure |
| `build-run-container-azure-acr-tasks.html` | Build and Run a Container Using Azure ACR Tasks |

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

**Totals**: 173 HTML files — 18 root, 36 in `projects/`, 11 in `FirewallSetup/`, 14 in `SC-401Labs/`, 3 in `DLP-Labs/`, 1 in `Misc/`, 23 in `AppliedSkills/`, 7 in `AgentAcademy/`, 11 in `MS-102Labs/`, 9 in `SC-200Labs/`, 40 in `PluralSightLabs/`.
