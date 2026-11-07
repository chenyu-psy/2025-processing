#' Label helpers for processing experiment analyses.
#'
#' This file contains small helpers that convert compact raw experiment codes
#' into ordered factors with readable labels. Source this file once in analysis
#' scripts before making figures or tables that need reader-friendly labels.

#' Convert raw condition codes to ordered, readable factor labels.
#'
#' @param condition A vector of condition codes, such as `"A"`, `"B"`, `"C"`,
#'   `"D"`, `"C1"`, or `"D2"`. Factors are converted to their displayed values
#'   before labeling.
#' @return A factor with labels ordered according to the experiment design,
#'   after dropping labels for condition codes that are not present in
#'   `condition`. Unknown condition codes are kept as their raw values so the
#'   output does not silently turn valid data into missing values.
#' @details The raw condition codes should still be used for filtering and
#'   modeling. This helper is intended for plot labels, where reader-friendly
#'   condition names are clearer.
#' @examples
#' label_condition(c("B", "C", "D"))
#' label_condition(c("C1", "D1", "C2", "D2"))
label_condition <- function(condition) {
  condition_labels <- c(
    "A" = "None",
    "B" = "R",
    "C" = "J + R",
    "C1" = "J + R",
    "C2" = "D-J + R",
    "D" = "E + J + R",
    "D1" = "E + J + R",
    "D2" = "E + D-J + R"
  )

  condition_chr <- as.character(condition)
  known_codes <- names(condition_labels)
  used_codes <- known_codes[known_codes %in% condition_chr]
  unknown_codes <- unique(condition_chr[!condition_chr %in% known_codes])
  unknown_codes <- unknown_codes[!is.na(unknown_codes)]

  condition_names <- unname(condition_labels[condition_chr])
  condition_names[condition_chr %in% unknown_codes] <- condition_chr[
    condition_chr %in% unknown_codes
  ]

  factor(
    condition_names,
    levels = unique(c(unname(condition_labels[used_codes]), unknown_codes))
  )
}

#' Convert raw phase codes to ordered, readable factor labels.
#'
#' @param phase A vector of phase codes. Expected values are `"ST"` for trials
#'   from the Single-task phase and `"CS"` for trials from the Complex-span
#'   phase.
#' @return A factor with levels ordered as `"Single-task"` followed by
#'   `"Complex-span"`. Unknown phase codes become `NA`, matching the
#'   usual behavior of `factor()`.
#' @details Use this helper after combining Single-task phase trials and
#'   Complex-span phase trials. The raw codes are compact for data
#'   processing, while the labels are clearer in tables and plots.
#' @examples
#' label_phase(c("ST", "CS"))
label_phase <- function(phase) {
  factor(
    phase,
    levels = c("ST", "CS"),
    labels = c("Single-task", "Complex-span")
  )
}

#' Convert Exp3 raw group codes to readable distractor-group labels.
#'
#' @param group A vector of Exp3 group codes, usually `"noDist"` or `"Dist"`.
#'   Factors are converted to their displayed values before labeling.
#' @return A factor with labels ordered as the no-distractor group followed by
#'   the distractor group.
#'   Unknown group codes are kept as their raw values so valid data are not
#'   silently converted to missing values.
#' @details The raw group codes should still be used for filtering and modeling.
#'   This helper is intended for plot labels, where the distractor grouping is
#'   clearer than the internal group code.
#' @examples
#' label_exp3_group(c("noDist", "Dist"))
label_exp3_group <- function(group) {
  group_labels <- c(
    "noDist" = "No-Distractor Group",
    "Dist" = "Distractor Group"
  )
  group_levels <- unname(group_labels)

  group_chr <- as.character(group)
  known_codes <- names(group_labels)
  unknown_codes <- unique(group_chr[!group_chr %in% known_codes])
  unknown_codes <- unknown_codes[!is.na(unknown_codes)]

  group_names <- unname(group_labels[group_chr])
  group_names[group_chr %in% unknown_codes] <- group_chr[
    group_chr %in% unknown_codes
  ]

  factor(
    group_names,
    levels = unique(c(group_levels, unknown_codes))
  )
}
