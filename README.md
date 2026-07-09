# vellum gallery

A [Quarto](https://quarto.org) gallery for the **vellum** graphics ecosystem in
R — a Rust-backed rendering backend
([vellum](https://github.com/r-vellum/vellum)), a pipe-first grammar of graphics
([vellumplot](https://github.com/r-vellum/vellumplot)), client-side interactive
widgets ([vellumwidget](https://github.com/r-vellum/vellumwidget)), and a
meta-package that ties them together
([vellumverse](https://github.com/r-vellum/vellumverse)).

The site is styled to match the ecosystem's pkgdown pages: a parchment / sepia
palette set in Spectral.

Live site: <https://r-vellum.github.io/vellumgallery/>

## Structure

```
index.qmd            Home — hero, ecosystem overview, a taste plot
about.qmd            What vellum is and how the pieces fit together
gallery/
  index.qmd          A filterable grid listing of every example
  *.qmd              One example per file (code + rendered result)
  _helper.R          Shared setup: renders a plot spec to PNG and embeds it
theme/vellum.scss    The parchment theme (matches the pkgdown sites)
includes/head.html   Google fonts + theme-color
assets/              Hex logos and favicon
```

## Building locally

Rendering the examples requires the vellum packages (and therefore a Rust
toolchain to build `vellum`):

```r
# install.packages("pak")
pak::pak(c("r-vellum/vellum", "r-vellum/vellumplot", "r-vellum/vellumwidget"))
```

Then:

```sh
quarto render          # render the whole site to _site/
quarto preview         # live preview while editing
```

## How deployment works

Every computational result is **frozen** into `_freeze/` (`execute: freeze:
auto` in `_quarto.yml`). The GitHub Actions workflow
(`.github/workflows/publish.yml`) therefore only installs Quarto — no R, no
Rust, no vellum packages — and reuses the frozen output when it renders and
pushes to the `gh-pages` branch.

**This means: after editing any R chunk, re-render locally and commit the
refreshed `_freeze/` directory** (and any changed images under `gallery/figs/`
or `figs/`). If you forget, the deployed site will keep showing the old output.

## Notes

- Plots are rendered with `render_plot()` and embedded with `include_graphics()`
  rather than knitr's auto-print, because the vellum backend rejects the integer
  dpi that knitr's graphics device reports. See `gallery/_helper.R`.
- Interactive examples use `vellumwidget::as_widget()`; the widgets are
  self-contained and need no server.
