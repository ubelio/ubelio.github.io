# CLAUDE.md

Context for working in this repository — Ubelio Fernandez-Tabet's IT portfolio site, served as a static site via GitHub Pages (custom domain in `CNAME`). No build step, no framework, no package.json — every page is hand-authored HTML. Site-wide chrome styling lives in a shared `style.css`; page-specific styling stays inline per page (see §2).

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

**The site uses a shared stylesheet at `/style.css` (repo root)**, linked from every one of the 67 HTML pages via `<link rel="stylesheet" href="/style.css">` in `<head>` — always the absolute path, so it resolves identically from root pages and from subfolder pages (`projects/`, `FirewallSetup/`, etc.).

`style.css` contains only the universal site chrome, shared byte-for-byte across every page before the refactor:
- `body` (font-family, margin, background-color, color)
- `header` (dark-band styling)
- `nav`, `nav a`, `nav a:hover`, `nav a.active`
- `main, .container` (the shared `max-width: 900px; margin: auto; padding: 20px;` layout wrapper — combined into one rule since both selectors carried identical values)
- `footer`, `footer a`, `footer a:hover`

**Everything page-specific stays inline** in that page's own `<style>` block in `<head>` — this was deliberately *not* moved to `style.css`. That includes: `section`, `h2`, `.impact-box` (project pages), `figure`/`.screenshot`/`figcaption.screenshot-note`/`.section-divider`/`.note`/`.img-caption` and other lab-writeup classes, `pre`/`.download-link` (scripts.html), `ul`/`li` list styling (hub pages), and all image/diagram styling (`img.diagram`, etc.). When adding new page-specific styling, put it in that page's inline `<style>` block, not in `style.css`.

**`contact.html` intentionally keeps inline overrides that are *not* in `style.css`** and must stay that way: a `header { margin: -40px -20px 0; }` hack and `nav` side-margin overrides (both counteract `body`'s page-specific `text-align`/`padding` so the header/nav still render edge-to-edge despite `contact.html`'s own body padding). These aren't leftover cruft — don't "clean them up" into `style.css` or delete them; they're what makes `contact.html` render correctly given its one-off body padding.

**Local preview requires a web server, not `file://`.** Because every page links `style.css` with an absolute path (`/style.css`), opening an HTML file directly in a browser (`file:///Users/.../index.html`) will fail to resolve that path and the page will render unstyled. Serve the repo root locally first, e.g. `python3 -m http.server` from the repo root, then browse `http://localhost:8000/`.

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
- Pages commonly add extra local classes on top of the shared chrome: `projects/*.html` use `.impact-box` for callouts; `FirewallSetup/`/`DLP-Labs/`/`SC-401Labs/` writeups use `figure`/`.screenshot`/`figcaption.screenshot-note` for screenshots, `.section-divider` (hr), `.img-caption`, `.note`. See §2 for the full split between what's in `style.css` and what stays inline per page.

## 3. Known Quirks / Inconsistencies

Be aware of these when editing — don't "fix" them silently as drive-by cleanup unless asked, since they're widespread and consistent-with-themselves across many files:

1. **Two different wrapper conventions**: `<main>` vs `<div class="container">`, used inconsistently even at the root level — e.g. `labs.html` uses `.container` while its siblings `index.html`/`projects.html`/`scripts.html` use `<main>`. Visually identical (both are the same `main, .container` rule in `style.css`), just be aware which one a given file uses before adding markup.
2. **Two "accent blue" hexes**: `#0073e6` (nav active state, general links) and `#0078D4` (Microsoft-blue `.impact-box` left border on project pages) are both in use and are not the same color. Match whichever the surrounding page already uses.
3. **`contact.html` still has no `<footer>` element** — email/LinkedIn/GitHub links and the resume button are loose in the body instead. It does now have a proper `<header>` and its own inline style overrides (see §2) — those overrides are intentional, not a quirk to fix.
4. **`SC-401Labs/` has multiple revisions of the same lab living side by side** (`sc401-lab1.html`, `sc401-lab1v2.html`, `sc401-lab1v3.html`, `sc401-lab1v4.html`, etc.) rather than one file being updated in place. Confirm which version is actually linked from `labs.html`/`SC-401labs.html` before assuming a given file is "the" current one.
5. Inline `style="..."` attributes are used liberally on top of the `<style>` block for one-off tweaks (e.g. centering a section, sizing an image) — there's no strict separation between "page stylesheet" and "inline styling"; both are used interchangeably per-element.

## 4. Conventions for New Pages

When adding a new project or lab writeup, match the existing pattern rather than introducing something new:

- Copy the `<header>` / `<nav id="main-nav">` / active-nav `<script>` / `<footer>` block verbatim from a recent, non-quirky page (e.g. `projects/microsoft-pim.html` for a project page, `FirewallSetup/opnsensebaselinerules.html` for a lab writeup) rather than from `contact.html`.
- Use **absolute** nav hrefs (`/index.html`, etc.) even for pages inside subfolders.
- **Link the shared stylesheet**: add `<link rel="stylesheet" href="/style.css">` in `<head>` (absolute path, leading slash — required even from subfolder pages). Do not re-declare `body`, `header`, `nav`, `nav a`, `nav a:hover`, `nav a.active`, `main`/`.container`, `footer`, `footer a`, or `footer a:hover` inline — `style.css` already provides all of those. Only add a page-specific inline `<style>` block for things `style.css` doesn't cover (`section`, `h2`, `.impact-box`, `figure`/`.screenshot`/`.section-divider`, image/diagram classes, etc.).
- Reuse the existing palette hex codes exactly (see table in §2) rather than picking new colors. For a Microsoft-product-flavored callout, use `.impact-box` (`#f0f8ff` bg / `#0078D4` left border); for the general link/active accent, use `#0073e6`.
- Store new screenshots/diagrams in the same folder as the HTML file that references them, not in a shared assets folder.
- Wrap main content in `<div class="container">` for subfolder lab/project writeups (matching the majority convention in `FirewallSetup/`, `SC-401Labs/`, `DLP-Labs/`), or `<main>` if adding a new top-level hub page.
- Add the new page's link to the relevant hub page (`projects.html`, `labs.html`, `homelabconfig.html`, etc.) so it's actually reachable from navigation.
