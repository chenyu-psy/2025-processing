#' Preprocessing helpers for processing experiment analyses.
#'
#' This file is reserved for small data-cleaning helpers used before modeling
#' or plotting. Good candidates include participant exclusion rules, response
#' recoding, trial numbering, and RT cleaning rules that are shared across
#' experiments.

# ---- source protocol recoding ----

#' Recode raw screen identifiers as canonical phase codes.
#'
#' @param screen_id A vector of raw `screenID` values.
#' @return A character vector using `"ST"` for Single-task trials and `"CS"`
#'   for Complex-span trials. Other values become `NA`.
#' @examples
#' recode_phase(c("processing", "memory-resp", "retrieval"))
recode_phase <- function(screen_id) {
  dplyr::recode_values(
    as.character(screen_id),
    "processing" ~ "ST",
    "memory-resp" ~ "CS",
    default = NA_character_
  )
}

# ---- participant exclusions ----

#' Filter groups with low response rate or low accuracy.
#'
#' @param data A data frame that has already been filtered to the trials used
#'   for the performance check.
#' @param response_col Name of the response column as a string.
#' @param acc_col Name of the accuracy column as a string. Values are treated
#'   like the current analysis scripts: missing responses become missing
#'   accuracy, `TRUE` or non-zero values become `1`, and other values become
#'   `0`.
#' @param min_resp Minimum acceptable response rate.
#' @param min_acc Minimum acceptable accuracy.
#' @param null_response Response value that means no response was given. The
#'   default is `"NULL"`, matching the exported experiment data.
#' @param .by Column name, or names, used to compute performance summaries.
#' @return A data frame containing the `.by` column(s), `pResp`, and `pAcc` for
#'   groups where `pResp < min_resp` or `pAcc < min_acc`.
#' @details Keep experiment-specific trial filters outside this helper. For
#'   example, filter to the relevant `screenID` and `condition` in the script,
#'   then call this function to calculate the low-performance groups.
#' @examples
#' trial_perf <- data.frame(
#'   participant = c(1, 1, 2, 2),
#'   response = c("left", "NULL", "left", "right"),
#'   acc = c(TRUE, FALSE, TRUE, FALSE)
#' )
#' filter_low_perf(
#'   trial_perf,
#'   response_col = "response",
#'   acc_col = "acc",
#'   min_resp = 0.75,
#'   min_acc = 0.75,
#'   .by = "participant"
#' )
filter_low_perf <- function(
    data,
    response_col,
    acc_col,
    min_resp,
    min_acc,
    null_response = "NULL",
    .by
) {
  response <- data[[response_col]]
  response[response == null_response] <- NA

  acc_bool <- as.logical(data[[acc_col]])
  acc <- dplyr::case_when(
    is.na(response) ~ NA_real_,
    !is.na(acc_bool) & acc_bool ~ 1,
    TRUE ~ 0
  )

  data$.response_clean <- response
  data$.acc_clean <- acc

  data |>
    dplyr::summarise(
      pResp = sum(!is.na(.response_clean), na.rm = TRUE) / dplyr::n(),
      pAcc = mean(.acc_clean, na.rm = TRUE),
      .by = dplyr::all_of(.by)
    ) |>
    dplyr::filter(pResp < min_resp | pAcc < min_acc)
}

# ---- trial and response cleaning ----

#' Score retrieval responses by response type.
#'
#' @param data A data frame with one row per retrieval response option.
#' @param target_col Name of the target column as a string.
#' @param distractor_col Name of the distractor column as a string.
#' @param response_col Name of the response column as a string.
#' @param null_response Response value that means no response was given. The
#'   default is `"NULL"`, matching the exported experiment data.
#' @param .by Column name, or names, that define one retrieval trial. Other
#'   targets and distractors are searched within each `.by` group.
#' @return The original data frame with six added response-scoring columns:
#'   `Correct`, `Other`, `Dist`, `OtherDist`, `NPL`, and `NoRes`.
#' @details This helper only scores response type. Keep retrieval filtering,
#'   joins with processing-task data, trial ordering, and file output visible in
#'   the analysis scripts.
#' @examples
#' trial_resp <- data.frame(
#'   participant = c(1, 1),
#'   trialID = c(1, 1),
#'   target = c("image1", "image2"),
#'   distractor = c("image3", "image4"),
#'   response = c("image1", "image1")
#' )
#' score_retrieval_response(trial_resp, .by = c("participant", "trialID"))
score_retrieval_response <- function(
    data,
    target_col = "target",
    distractor_col = "distractor",
    response_col = "response",
    null_response = "NULL",
    .by
) {
  data$.score_target <- data[[target_col]]
  data$.score_distractor <- data[[distractor_col]]
  data$.score_response <- data[[response_col]]

  data |>
    dplyr::mutate(
      Correct = ifelse(.score_target == .score_response, 1, 0),
      NoRes = ifelse(.score_response == null_response, 1, 0)
    ) |>
    dplyr::mutate(
      Dist = ifelse(.score_response == .score_distractor, 1, 0),
      OtherDist = ifelse(
        Dist == 0 & .score_response %in% .score_distractor,
        1,
        0
      ),
      .by = dplyr::all_of(.by)
    ) |>
    dplyr::mutate(
      Other = ifelse(Correct == 0 & .score_response %in% .score_target, 1, 0),
      NPL = 1 - Correct - Other - NoRes,
      .by = dplyr::all_of(.by)
    ) |>
    dplyr::select(-.score_target, -.score_distractor, -.score_response)
}

#' Remove implausible and outlying reaction times.
#'
#' @param rt A numeric vector of reaction times, usually measured in seconds.
#' @param min_cutoff The smallest plausible reaction time. Values below this are
#'   replaced with `NA`.
#' @param sd_cutoff The number of standard deviations used for the upper and
#'   lower outlier bounds.
#' @param na_rm Whether to ignore missing values when computing the mean and
#'   standard deviation. The default is `FALSE` to match the previous inline
#'   `mean(rt)` and `sd(rt)` behavior in the scripts.
#' @return A numeric vector with the same length as `rt`. Values below
#'   `min_cutoff` or outside `mean(rt) +/- sd_cutoff * sd(rt)` are replaced with
#'   `NA`.
#' @details When RT should be cleaned separately by participant, phase, or
#'   condition, call this function inside `dplyr::mutate()` with `.by`. This
#'   keeps the grouping rule visible in the preprocessing pipeline.
#' @examples
#' clean_rt(c(0.1, 0.5, 0.6, 4.0), min_cutoff = 0.2, sd_cutoff = 3)
#' dplyr::mutate(df, RT = clean_rt(RT, min_cutoff = 0.2, sd_cutoff = 3), .by = phase)
clean_rt <- function(rt, min_cutoff, sd_cutoff, na_rm = FALSE) {
  rt_mean <- mean(rt, na.rm = na_rm)
  rt_sd <- stats::sd(rt, na.rm = na_rm)

  lower_bound <- rt_mean - sd_cutoff * rt_sd
  upper_bound <- rt_mean + sd_cutoff * rt_sd

  clean <- rt
  too_fast <- !is.na(rt) & rt < min_cutoff
  too_low <- !is.na(rt) & !is.na(lower_bound) & rt < lower_bound
  too_high <- !is.na(rt) & !is.na(upper_bound) & rt > upper_bound

  clean[too_fast | too_low | too_high] <- NA_real_
  clean
}

# number_trial_steps()
