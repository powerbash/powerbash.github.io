# powerbash.github.io

The site at [powerbash.org](https://powerbash.org) — landing page and the full
[documentation](https://powerbash.org/docs/).

## Working on it

There is no build step and no dependencies. Open `index.html` in a browser:

```bash
xdg-open index.html      # or: open index.html
```

Everything is hand-written HTML and one stylesheet. The page makes **zero
external requests** — no fonts, no CDN, no analytics, no scripts at all. The
prompt configurator on the landing page is checkboxes and `:checked` sibling
selectors, not JavaScript. Keep it that way.

`.nojekyll` tells GitHub Pages to serve the tree verbatim rather than running
it through Jekyll.

## Colors

The palette is not invented. Every segment color in `css/main.css` is the color
powerbash actually emits, read off a real prompt render — see the comment at
the top of that file for the `tput` codes each one corresponds to.

## Content

The documentation lives here, not in the app repo. Adding a user-visible
setting to [napalm255/powerbash](https://github.com/napalm255/powerbash) means
updating `docs/index.html` in this repo too.

## License

MIT — see [LICENSE](LICENSE).
