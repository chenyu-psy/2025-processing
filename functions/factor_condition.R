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
#' factor_condition(c("B", "C", "D"))
#' factor_condition(c("C1", "D1", "C2", "D2"))
factor_condition <- function(condition) {
  condition_labels <- c(
    "A" = "None",
    "B" = "S",
    "C" = "S + J",
    "D" = "S + J + D",
    "C1" = "S + J",
    "D1" = "S + J + D",
    "C2" = "S + J2",
    "D2" = "S + J2 + D"
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
