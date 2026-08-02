# powerbash.org site tasks.
#
# CI calls these same targets, so a check that stops matching what the site
# actually does fails on the next push rather than going stale in prose.
#
# There is still no build step: `make check` only validates what is already
# committed, and `make og` regenerates one image from its own source. Opening
# index.html over file:// remains the way to work on the site.
#
# Recipes are written for GNU make 3.81, which is what macOS ships: no
# .ONESHELL, so multi-step recipes are one backslash-continued shell line.

CHROMIUM ?= chromium

.DEFAULT_GOAL := help

.PHONY: help check check-sitemap check-skills check-html og serve

help: ## Show this message
	@echo "powerbash.org"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'
	@echo
	@echo "  CHROMIUM=/path/to/chromium   which browser renders og.png"

check: check-sitemap check-skills check-html ## Everything CI runs

# Two pages today, but the sitemap is hand-maintained and a third page would
# otherwise be invisible to crawlers with nothing to say so.
check-sitemap: ## Every HTML page appears in sitemap.xml
	@fail=0; \
	for f in $$(find . -name '*.html' -not -path './.git/*' -not -name '404.html'); do \
	    url="https://powerbash.org$$(echo $$f | sed -e 's|^\.||' -e 's|/index\.html$$|/|')"; \
	    grep -qF "<loc>$$url</loc>" sitemap.xml \
	      || { echo "sitemap.xml is missing $$url (from $$f)" >&2; fail=1; }; \
	done; \
	[ $$fail -eq 0 ] && echo "sitemap.xml: every page listed"

# The digest is the one thing here that rots silently: edit SKILL.md, and the
# index still advertises the old hash. Agents fetching it are entitled to
# assume the hash matches.
check-skills: ## agent-skills digests match the files they describe
	@fail=0; \
	for skill in .well-known/agent-skills/*/SKILL.md; do \
	    name=$$(basename $$(dirname $$skill)); \
	    want=$$(grep -A4 "\"name\": \"$$name\"" .well-known/agent-skills/index.json \
	              | sed -n 's/.*"digest": "sha256:\([a-f0-9]*\)".*/\1/p'); \
	    got=$$(shasum -a 256 "$$skill" 2>/dev/null || sha256sum "$$skill"); \
	    got=$$(echo "$$got" | cut -d' ' -f1); \
	    [ "$$want" = "$$got" ] \
	      || { echo "$$skill: index.json says $$want, file is $$got" >&2; fail=1; }; \
	done; \
	[ $$fail -eq 0 ] && echo "agent-skills: digests match"

# Not a validator -- just the invariants that have actually been broken here:
# a page with no canonical, and the "no external requests" promise in README.
#
# Only things the browser actually fetches count as a request. An absolute URL
# in rel=canonical, og:image or ld+json is a reference, not a load, and has to
# be absolute to be correct -- so the patterns below name the fetching
# elements rather than looking for https:// anywhere.
check-html: ## Each page declares a canonical URL and loads nothing remote
	@fail=0; \
	for f in index.html docs/index.html; do \
	    grep -q 'rel="canonical"' "$$f" \
	      || { echo "$$f: no rel=canonical" >&2; fail=1; }; \
	done; \
	if grep -nE '<(img|script|iframe)[^>]+src="https?://' *.html */*.html \
	   || grep -nE '<link[^>]+rel="(stylesheet|icon|preload|apple-touch-icon)"[^>]+href="https?://' *.html */*.html \
	   || grep -nE '@import|url\(https?://' css/*.css; then \
	    echo "above: remote asset -- the site must make no external requests" >&2; \
	    fail=1; \
	fi; \
	[ $$fail -eq 0 ] && echo "html: canonical present, no remote assets"

og: ## Re-render og.png from og.svg
	$(CHROMIUM) --headless --disable-gpu --no-sandbox --hide-scrollbars \
	  --window-size=1200,630 --screenshot=$(CURDIR)/og.png $(CURDIR)/og.svg
	@echo "og.png regenerated -- check it before committing"

serve: ## Serve the site at http://localhost:8000
	python3 -m http.server 8000
