# Shared setup for every gallery page.
#
# Plots are rendered to a PNG with render_plot() and embedded with
# include_graphics(), rather than relying on knitr's auto-print. The vellum
# backend rejects the integer dpi that knitr's graphics device reports, so we
# keep rendering off that device entirely. render_plot() uses the plot spec's
# own (double) dpi/size instead.
suppressMessages(library(vellumplot))

vg <- function(p, name, dpi = 150) {
  dir.create("figs", showWarnings = FALSE)
  f <- file.path("figs", paste0(name, ".png"))
  render_plot(p, f, dpi = dpi)
  knitr::include_graphics(f)
}
