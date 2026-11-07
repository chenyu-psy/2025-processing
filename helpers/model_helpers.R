#' Model helpers for processing experiment analyses.
#'
#' This file contains small helpers for summarising fitted Bayesian models. The
#' helpers keep repeated `emmeans` and Bayes-factor code in one place while
#' leaving the main analysis questions visible in the Quarto scripts.

# ---- Bayes-factor tables ----

tidy_bf_table <- function(bf, task, model, analysis) {
  table <- bf %>%
    as.data.frame() %>%
    as_tibble() %>%
    rename(parameter = any_of("Parameter")) %>%
    mutate(
      task = task,
      model = model,
      analysis = analysis,
      .before = 1
    )

  if ("log_BF" %in% names(table)) {
    table <- table %>%
      mutate(BF = exp(log_BF))
  }

  table
}

model_parameter_bf_table <- function(
    model,
    prior = NULL,
    task,
    model_label,
    analysis = "parameter"
) {
  bf <- if (is.null(prior)) {
    bayestestR::bf_parameters(model)
  } else {
    post_parameters <- insight::get_parameters(model, effects = "fixed")
    prior_parameters <- insight::get_parameters(prior, effects = "fixed")
    bayestestR::bf_parameters(post_parameters, prior_parameters)
  }

  tidy_bf_table(
    bf,
    task = task,
    model = model_label,
    analysis = analysis
  )
}

# ---- Bayes factors for trends ----

#' Compute Bayes factors for estimated trends from a brms model.
#'
#' @param model A fitted `brmsfit` model used for posterior trend estimates.
#' @param prior A fitted prior-only `brmsfit` model. If `NULL`, the prior model
#'   is generated with `bayestestR::unupdate(model)`.
#' @param specs An `emmeans` formula or character string defining the groups for
#'   trend estimates.
#' @param var Name of the numeric predictor whose trend should be estimated,
#'   such as `"step"`.
#' @param cont_values Optional named list passed to the `at` argument of
#'   `emmeans::emtrends()`. Use this to average over selected numeric values,
#'   such as `list(phase = c(0, 1))`.
#' @param compare Whether to compare trends pairwise. Use `FALSE` to test each
#'   trend against 0, and `TRUE` to test pairwise differences between trends.
#' @param direction Direction passed to `bayestestR::bayesfactor_parameters()`.
#'   The default `"two-sided"` tests evidence for a non-zero effect.
#' @return A list containing posterior trends, prior trends, and Bayes factors.
#'   When `compare = TRUE`, the list also contains posterior and prior pairwise
#'   trend contrasts.
#' @details Use this helper for continuous predictors. Here, `var = "step"`
#'   estimates the linear change from one serial-position step to the next.
#'   Use `bf_pairwise()` instead when the predictor is a factor.
bf_emtrends <- function(
    model,
    prior = NULL,
    specs,
    var,
    cont_values = NULL,
    compare = FALSE,
    direction = "two-sided"
) {
  if (is.null(prior)) {
    prior <- bayestestR::unupdate(model)
  }

  post_trends <- emmeans::emtrends(
    model,
    specs = specs,
    var = var,
    at = cont_values
  )
  prior_trends <- emmeans::emtrends(
    prior,
    specs = specs,
    var = var,
    at = cont_values
  )

  if (compare) {
    post_pairwise <- emmeans::contrast(post_trends, method = "pairwise")
    prior_pairwise <- emmeans::contrast(prior_trends, method = "pairwise")
    bf_result <- bayestestR::bayesfactor_parameters(
      post_pairwise,
      prior = prior_pairwise,
      direction = direction
    )

    return(list(
      trends = post_trends,
      trends_prior = prior_trends,
      pairwise = post_pairwise,
      pairwise_prior = prior_pairwise,
      bayesfactor = bf_result
    ))
  }

  bf_result <- bayestestR::bayesfactor_parameters(
    post_trends,
    prior = prior_trends,
    direction = direction
  )

  list(
    trends = post_trends,
    trends_prior = prior_trends,
    bayesfactor = bf_result
  )
}
