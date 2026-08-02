# powerbash.github.io

The site at [powerbash.org](https://powerbash.org) — landing page and the full
[documentation](https://powerbash.org/docs/).

## Working on it

There is no build step and no dependencies. Open `index.html` in a browser:

```bash
xdg-open index.html      # or: open index.html
make serve               # or over http, if you need absolute paths to resolve
```

Everything is hand-written HTML and one stylesheet. The page makes **zero
external requests** — no fonts, no CDN, no analytics — and **runs no code**:
the only `<script>` on either page is an `application/ld+json` block, which is
structured data for search engines and is never executed. The prompt
configurator on the landing page is checkboxes and `:checked` sibling
selectors, not JavaScript. Keep it that way.

`make check` enforces the parts of that which are mechanical, and CI runs the
same target:

```bash
make check      # sitemap covers every page, skill digests match, no remote assets
make og         # re-render og.png from og.svg (needs chromium)
```

`.nojekyll` tells GitHub Pages to serve the tree verbatim rather than running
it through Jekyll. It is also what makes `.well-known/` reachable.

## Colors

The palette is not invented. Every segment color in `css/main.css` is the color
powerbash actually emits, read off a real prompt render — see the comment at
the top of that file for the `tput` codes each one corresponds to.

## Content

The documentation lives here, not in the app repo. Adding a user-visible
setting to [napalm255/powerbash](https://github.com/napalm255/powerbash) means
updating **three** files in this repo:

| File | Why |
|---|---|
| `docs/index.html` | the documentation itself |
| `.well-known/agent-skills/powerbash/SKILL.md` | what agents install and configure powerbash from |
| `.well-known/agent-skills/index.json` | the `digest` there is a SHA-256 of `SKILL.md` |

`make check-skills` fails when the digest and the file disagree, so the third
one is hard to forget. Recompute it with:

```bash
sha256sum .well-known/agent-skills/powerbash/SKILL.md
```

New pages additionally need an entry in `sitemap.xml` — `make check-sitemap`
fails otherwise — and usually a line in `llms.txt`.

## Agents and search engines

The files that exist only to be read by machines, and what each is for:

| File | Purpose |
|---|---|
| `robots.txt` | crawl rules, AI-crawler rules, `Content-Signal`, and the sitemap pointer |
| `sitemap.xml` | the canonical URL of every page |
| `llms.txt` | an annotated map of the site for language models ([spec](https://llmstxt.org/)) |
| `.well-known/agent-skills/` | an installable skill, per the Agent Skills Discovery RFC |
| `og.svg` / `og.png` | the social preview card; the SVG is the source, the PNG is what ships |

The content signal is `search=yes, ai-input=yes, ai-train=yes` — everything
here is MIT-licensed documentation for a free script, and the point is for
agents to be able to recommend and install it.

Some checks at [isitagentready.com](https://isitagentready.com/powerbash.org)
will never pass, and should not: MCP server cards, OAuth discovery, and the
commerce protocols all describe an API and a checkout that a static docs site
for a shell script does not have. Publishing them would advertise services that
do not exist.

## License

MIT — see [LICENSE](LICENSE).
