# Kayal's World — agent notes

A Hugo static blog (no Ruby/Jekyll — deliberately avoided). Deployed to GitHub
Pages at kayalworld.com via GitHub Actions.

## Adding a new post

Three equivalent ways to scaffold one, from fastest to most manual:

- In Claude Code: run `/new-post <title>` — creates the file and image
  folder, then walks through filling in body/images/summary with you.
- `./new-post.sh "Post Title"` — creates `content/posts/<slug>.md` with
  frontmatter pre-filled plus the matching `static/assets/images/<slug>/`
  folder.
- `hugo new posts/<slug>.md` — uses `archetypes/posts.md` to do the same,
  titlecasing the slug into the `title:` field (Hugo's native mechanism).

Or create `content/posts/<slug>.md` by hand:

```markdown
---
title: "Post Title"
date: 2026-09-13T12:00:00.000Z
image: "/assets/images/<slug>/<filename>.jpg"
summary: "One or two sentences shown on the home page card."
---

Post body in markdown. Images referenced the same way as `image` above,
e.g. `![](/assets/images/<slug>/<filename>.jpg)`.
```

- `image` and `summary` are optional but every existing post has both — `image`
  drives the card thumbnail and featured-post treatment; `summary` is the card
  excerpt. Without `image` a post renders with no thumbnail, not a placeholder.
- Put images under `static/assets/images/<slug>/` (create the folder). They're
  served at `/assets/images/<slug>/...` regardless of environment — see the
  render-hook note below for why that "just works".
- The URL slug comes from the **filename**, not the title (`permalinks.posts`
  in `hugo.toml` uses `:contentbasename`). This matters because several
  titles contain emoji, which would otherwise mangle the slug.

## Local preview

Hugo isn't installed system-wide — it's a standalone binary at
`~/.local/bin/hugo` (no Ruby/Jekyll, no npm). Run:

```
~/.local/bin/hugo server --bind 127.0.0.1 --port 1313
```

## Deploy

Push to `main` → `.github/workflows/hugo.yml` builds with Hugo and deploys to
GitHub Pages via `actions/deploy-pages`. Nothing else to run manually.

- Repo Settings → Pages → Source must stay set to **GitHub Actions** (not
  "Deploy from a branch"), otherwise the workflow's `configure-pages` step
  fails outright.
- Editing `.github/workflows/hugo.yml` itself requires a token/credential
  with the `workflow` scope — a plain `contents: write` token gets rejected
  by GitHub on push for that file specifically.
- Custom domain (`kayalworld.com`) is configured in Pages settings + DNS at
  Squarespace (A records on `@` to the four standard GitHub Pages IPs, CNAME
  on `www` to `kayal-imayakumar.github.io`). The `static/CNAME` file in this
  repo just declares the domain to Hugo/Pages; it doesn't configure DNS.
- If the custom domain setting changes (added/removed) *after* a deploy, the
  next build's `steps.pages.outputs.base_url` won't reflect it — re-run the
  workflow (or push any commit) once the domain is actually attached in Pages
  settings, or internal links/images will resolve one path level off.

## The render-hook gotcha (don't remove this)

`layouts/_markup/render-image.html` exists to fix a real Hugo footgun: Hugo's
`relURL`/`absURL` leave a path **unchanged** whenever it already starts with
`/`, treating it as already fully-qualified from the server root — they only
prepend the site's base path for paths *without* a leading slash. Every image
in post content is written as an absolute path (`/assets/images/...`), so
without this hook, images resolve wrong on *any* deployment where the base
path isn't literally site root (e.g. the `kayal-imayakumar.github.io/kayalworld/`
preview URL, or any future project-pages-style subpath).

The same pattern shows up in template code (`layouts/partials/*.html`,
`layouts/_default/single.html`): every place that needs a link/image derived
from an absolute-path string strips the leading slash before piping through
`relURL` (`strings.TrimPrefix "/" $x | relURL`), or better, uses a proper
Hugo accessor (`.Site.Home.RelPermalink`, `.Site.GetPage`,
`.Site.Home.OutputFormats.Get "rss"`) instead of hand-rolling a path string at
all. If you add a new template that links to an internal absolute path, use
one of those two approaches — don't just pipe a literal `"/something"`
through `relURL` and assume it's fixed automatically the way it is elsewhere.

## Design system

Tokens and the whole visual language live in `static/css/style.css`:
white paper background, Baloo 2 (display) + Nunito (body) from Google Fonts,
a five-color "crayon" accent set, and a reusable daisy SVG `<symbol>`
(`layouts/partials/daisy-sprite.html`) instanced via `<use>` for all the
decorative flowers (white petals, yellow centers only — not a rainbow).
The garden-strip divider is `layouts/partials/garden.html`, reused on the
home page, single posts, and the About page.
