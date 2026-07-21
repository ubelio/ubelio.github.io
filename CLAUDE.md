# CLAUDE.md

Context for working in this repository — Ubelio Fernandez-Tabet's IT portfolio site, served as a static site via GitHub Pages (custom domain in `CNAME`). No build step, no framework, no package.json — every page is hand-authored HTML with inline CSS.

## 1. Site Structure

### Top-level pages (root)
- `index.html` — homepage / bio / skills summary
- `projects.html` — index/hub linking to all pages in `projects/`
- `labs.html` — index/hub linking to all pages in `SC-401Labs/`
- `scripts.html` — index/hub linking to files in `scripts/`
- `homelabconfig.html` — hub for the homelab writeups (links into `FirewallSetup/`, `DLP-Labs/`, etc.)
- `homelabfirewall.html` — homelab firewall overview/hub
- `contact.html` — contact info + resume download link
- `DLPInformationProtection.html`, `SC-401labs.html`, `Misc.html` — additional index/hub pages
- `README.md`, `CNAME`, `favicon.png`, `headshot.jpg`, `labdiagram.png`, `UbelioFernandezTabetResume.docx` — site metadata/assets at root

### Content subfolders
- `projects/` — one HTML writeup per professional project (Entra ID, Intune, SSO, PIM, patching, etc.), each paired with `*.png` diagrams in the same folder.
- `SC-401Labs/` — SC-401 certification exam lab writeups (`sc401-lab*.html`, several with `v1`/`v2`/`v3`/`v4` revisions coexisting side by side rather than being overwritten).
- `FirewallSetup/` — homelab OPNsense/VLAN/switch configuration writeups, each paired with `*.png` screenshots in the same folder.
- `DLP-Labs/` — Microsoft Purview DLP / compliance lab writeups, each paired with `*.png` screenshots.
- `Misc/` — miscellaneous writeups (e.g. `imacwindows.html`) + related images.
- `scripts/` — raw PowerShell scripts (`.ps1`) referenced/linked from `scripts.html`.

### Asset convention
Screenshots and diagrams live **next to** the HTML file that uses them (same folder), not in a shared `/assets` or `/images` directory. Every content subfolder is a flat mix of `.html` writeups and their `.png` companions.

## 2. Styling Conventions

**There is no shared stylesheet.** Every page defines its own `<style>` block in `<head>`, duplicating the same rules page to page. (See Quirks below — some pages also link to a `style.css` that doesn't exist.)

### Color palette (hex)
| Color | Hex | Used for |
|---|---|---|
| Near-black | `#141413` | body text, `header` background, `header` text on light bg, `h1`/`h2` |
| Header text / warm greige | `#C9C8BF` | `body` background, `header` text |
| Nav background | `#AFACA1` | `nav` background |
| Footer background | `#BDBBB2` | `footer` background, `.section-divider` |
| Figure/callout background | `#E6E5DE` | `figure` background on lab writeup pages |
| List/code background | `#E0DFD6` | `li` backgrounds on hub pages, `pre` background on `scripts.html` |
| Accent blue (links, active nav) | `#0073e6` | `nav a.active`, general link color |
| Microsoft blue (callout accent) | `#0078D4` | `.impact-box` left border on project pages |
| Impact box background | `#f0f8ff` | `.impact-box` background on project pages |

Font is `Arial, sans-serif` everywhere. No web fonts, no CSS framework.

### Repeated layout pattern
Nearly every page follows this structure:
```html
<header>
  <h1>Page Title</h1>
  <p>Subtitle / description</p>
</header>

<nav id="main-nav">
  <a href="/index.html">Home</a>
  <a href="/projects.html">Projects</a>
  <a href="/scripts.html">Scripts</a>
  <a href="/homelabconfig.html">Home-Lab Config</a>
  <a href="/labs.html">Labs</a>
  <a href="/contact.html">Contact</a>
</nav>

<script>
  const current = window.location.pathname.split("/").pop();
  document.querySelectorAll("#main-nav a").forEach(link => {
    if (link.getAttribute("href").endsWith(current)) {
      link.classList.add("active");
    }
  });
</script>

<!-- page content, wrapped in either <main> or <div class="container"> -->

<footer>
  <p>Email: <a href="mailto:ubelio@ubeliofernandez.com">ubelio@ubeliofernandez.com</a></p>
  <p>LinkedIn: <a href="https://www.linkedin.com/in/ubelio/" target="_blank" rel="noopener noreferrer">linkedin.com/in/ubelio</a></p>
</footer>
```
Key points:
- Nav links are always **absolute paths** (`/index.html`, not `index.html` or `../index.html`), so the same nav markup works unmodified from root pages and from subfolder pages (`projects/`, `FirewallSetup/`, etc.).
- The active-page highlight is done client-side with a small inline `<script>` that matches the current URL against nav hrefs and adds an `.active` class — there's no server-side templating.
- Content is wrapped in `<main>` on the primary site pages (`index.html`, `projects.html`, `scripts.html`, `labs.html`... though see quirk below) and in `<div class="container">` on most lab/writeup detail pages (`FirewallSetup/`, `SC-401Labs/`, `DLP-Labs/`). Both are just styled as `max-width: 900px; margin: auto;` — functionally identical, just named differently.
- Lab writeup pages commonly add extra local classes: `.impact-box`, `figure`/`.screenshot`/`figcaption.screenshot-note` for screenshots, `.section-divider` (hr), `.img-caption`, `.note`.

## 3. Known Quirks / Inconsistencies

Be aware of these when editing — don't "fix" them silently as drive-by cleanup unless asked, since they're widespread and consistent-with-themselves across many files:

1. **Dead `style.css` reference.** ~26 files (all of `FirewallSetup/`, `SC-401Labs/`, `DLP-Labs/`, `Misc/imacwindows.html`, plus root `labs.html`) contain `<link rel="stylesheet" href="style.css">` (or `../style.css` from subfolders). **This file does not exist anywhere in the repo.** It's a harmless dead request (each page's real styling comes entirely from its inline `<style>` block), but it's not something to "fix" by creating a `style.css` — that would be a scope change (see §4).
2. **Duplicated `nav a.active` block.** Many pages (index.html, contact.html, projects.html, scripts.html, homelabconfig.html, and most `projects/*.html`) have the *same* `nav a.active { text-decoration: underline; color: #0073e6; }` rule declared in **two separate, adjacent `<style>` tags** placed in the body right after the active-nav `<script>`. It's redundant but harmless (identical rules, last one just wins).
3. **Two different wrapper conventions**: `<main>` vs `<div class="container">`, used inconsistently even at the root level — e.g. `labs.html` uses `.container` while its siblings `index.html`/`projects.html`/`scripts.html` use `<main>`. Visually identical, just be aware which one a given file uses before adding markup.
4. **Two "accent blue" hexes**: `#0073e6` (nav active state, general links) and `#0078D4` (Microsoft-blue `.impact-box` left border on project pages) are both in use and are not the same color. Match whichever the surrounding page already uses.
5. **`contact.html` breaks the layout pattern**: no `<header>` element (uses a bare `<h1>`/`<p>` instead) and no `<footer>` element (email/LinkedIn/GitHub links are inline in the body). It also has a malformed unclosed anchor tag around the LinkedIn link (`</a` missing its closing `>`, line 109) — a real HTML bug, not intentional.
6. **`SC-401Labs/` has multiple revisions of the same lab living side by side** (`sc401-lab1.html`, `sc401-lab1v2.html`, `sc401-lab1v3.html`, `sc401-lab1v4.html`, etc.) rather than one file being updated in place. Confirm which version is actually linked from `labs.html`/`SC-401labs.html` before assuming a given file is "the" current one.
7. Inline `style="..."` attributes are used liberally on top of the `<style>` block for one-off tweaks (e.g. centering a section, sizing an image) — there's no strict separation between "page stylesheet" and "inline styling"; both are used interchangeably per-element.

## 4. Conventions for New Pages

When adding a new project or lab writeup, match the existing pattern rather than introducing something new:

- Copy the `<header>` / `<nav id="main-nav">` / active-nav `<script>` / `<footer>` block verbatim from a recent, non-quirky page (e.g. `projects/microsoft-pim.html` for a project page, `FirewallSetup/opnsensebaselinerules.html` for a lab writeup) rather than from `contact.html`.
- Use **absolute** nav hrefs (`/index.html`, etc.) even for pages inside subfolders.
- Keep styling inline in a per-page `<style>` block in `<head>` — do not introduce a shared `style.css` or extract one, since that would require touching every existing page to actually load it (and none currently do, live reference notwithstanding).
- Reuse the existing palette hex codes exactly (see table in §2) rather than picking new colors. For a Microsoft-product-flavored callout, use `.impact-box` (`#f0f8ff` bg / `#0078D4` left border); for the general link/active accent, use `#0073e6`.
- Store new screenshots/diagrams in the same folder as the HTML file that references them, not in a shared assets folder.
- Wrap main content in `<div class="container">` for subfolder lab/project writeups (matching the majority convention in `FirewallSetup/`, `SC-401Labs/`, `DLP-Labs/`), or `<main>` if adding a new top-level hub page.
- Don't duplicate the `nav a.active` `<style>` block — one copy is enough (existing duplication is a pre-existing quirk, not something to replicate).
- Add the new page's link to the relevant hub page (`projects.html`, `labs.html`, `homelabconfig.html`, etc.) so it's actually reachable from navigation.
