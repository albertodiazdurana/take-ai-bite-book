# DSM Jupyter Book — Take AI Bite

Live site: **https://albertodiazdurana.github.io/take-ai-bite-book/**

A MyST-based Jupyter Book rendering the public methodology content from
[take-ai-bite](https://github.com/albertodiazdurana/take-ai-bite) (the
public mirror of the private DSM Central methodology hub). The site is
rebuilt and redeployed whenever take-ai-bite publishes a new tagged
release.

## How it works

This repo is a **build pipeline**, not a content repo. Tracked files are:

- `scripts/` — three bash scripts that check upstream, copy content, inject the version
- `.github/workflows/scheduled-build.yml` — single-job orchestrator (check → clone → copy → inject → build → deploy → commit-back)
- `book/myst.yml` — MyST book configuration (TOC + theme settings)
- `package.json` + `package-lock.json` — Node environment pin for mystmd

The rendered markdown content (`book/content/`) is gitignored and is
populated fresh on every build by copying from a shallow clone of
take-ai-bite at the latest tag.

## Related projects

- **Upstream (public mirror, what this book renders):** [take-ai-bite](https://github.com/albertodiazdurana/take-ai-bite)
- **Upstream-upstream (private methodology hub, governance only):** DSM Central (private)

## Author

Alberto Diaz Durana · [GitHub](https://github.com/albertodiazdurana) · [LinkedIn](https://www.linkedin.com/in/albertodiazdurana/)
