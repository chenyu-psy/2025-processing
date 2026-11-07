#' Plot helpers for processing experiment analyses.
#'
#' Source this file before creating plots. The shared themes keep typography
#' and facet styling consistent across experiments.

# ---- shared themes ----

#' Shared theme for analysis figures.
#'
#' Centralizes the font size and facet-strip styling used across experiments.
theme_analysis <- function() {
  font_size <- 10.5

  ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size = font_size),
      axis.title = ggplot2::element_text(size = font_size),
      strip.text = ggplot2::element_text(size = font_size),
      strip.background = ggplot2::element_rect(fill = "#bababa")
    )
}

#' Shared theme for processing-model posterior figures.
theme_posterior <- function() {
  theme_analysis() +
    ggplot2::theme(
      legend.position = "right",
      strip.background.x = ggplot2::element_rect(fill = "#bababa", color = "grey40"),
      strip.background.y = ggplot2::element_blank(),
      strip.text.y.left = ggplot2::element_text(angle = 90),
      panel.grid = ggplot2::element_blank(),
      panel.spacing.x = grid::unit(0.8, "lines"),
      panel.spacing.y = grid::unit(0.7, "lines")
    )
}
