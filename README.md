# Maintenance and Processing in Working Memory

This repository provides the data and R/Quarto analyses for three complex-span experiments testing whether memory-processing costs reflect shared-resource competition or the encoding of additional working-memory representations.

## Getting started

### Requirements

- R
- RStudio with Quarto support
- A working installation of `cmdstanr` and CmdStan
- Internet access on the first run so the scripts can install the required CRAN and GitHub packages

### Data

The source datasets in `data/source/` are de-identified and stored in a standardized tabular format. Participant exclusions and trial-level cleaning have not been applied at this stage. Each experiment script performs these steps and writes its analysis-ready datasets to `data/processed/`.

The processed datasets are included in the repository, so the analyses can be run without regenerating them first.

### Running the analyses

1. Open `2025-processing.Rproj` in RStudio so relative paths resolve from the project root.
2. Run any of the three experiment scripts—`scripts/01_analysis_Exp1.qmd`, `scripts/02_analysis_Exp2.qmd`, or `scripts/03_analysis_Exp3.qmd`—interactively. They are independent and can be run in any order.
3. Run `scripts/04_analysis_cross_experiment.qmd` for the cross-experiment analyses. This script uses the processed memory and cognitive-load data from Experiments 1–3, which are already included in `data/processed/`.

Rerun an experiment script before the cross-experiment analysis only when you want to regenerate its processed data from `data/source/`.

### Model fitting and CPU settings

The experiment scripts submit Bayesian models through `taskr`. After submitting a model, wait for it to finish before running the corresponding prior-model or results chunks, as marked in each document.

Model fitting, especially for the reaction-time models, may take several hours to several days depending on CPU performance. Before fitting a model, set its `cores` argument to the number of physical CPU cores that the machine can safely allocate, from 1 to 8. Keep `chains = 8`, `iter`, `warmup`, and the other model settings unchanged. The `cores` argument controls how many chains run in parallel; changing it affects runtime but not the total number of chains.

On a server or high-performance PC, advanced users can additionally enable within-chain parallelization with `threads = brms::threading(t)`. Keep `cores × t` within the number of allocated physical CPU cores; for example, `cores = 8` and `threads = brms::threading(4)` may use up to 32 cores. The models in this project can benefit from using up to eight threads per chain.

## Coding conventions

The scripts use compact codes that correspond to the manuscript terminology:

- `condition`: `A` = None; `B` = Response; `C`/`C1` = Judgment + Response; `C2` = Double-Judgment + Response; `D`/`D1` = Encoding + Judgment + Response; `D2` = Encoding + Double-Judgment + Response.
- `phase`: `ST` = Single-task; `CS` = Complex-span.
- Experiment 3 `group`: `noDist` = No-Distractor Group; `Dist` = Distractor Group.

## Project contents

- `scripts/01_analysis_Exp1.qmd` to `scripts/03_analysis_Exp3.qmd`: preprocess and analyze the three experiments independently.
- `scripts/04_analysis_cross_experiment.qmd`: compares memory performance and cognitive load across experiments.
- `data/source/` and `data/processed/`: source and analysis-ready datasets described above.
- `helpers/`: shared preprocessing, labeling, modeling, and plotting functions.
- `results/models/`: fitted Bayesian models, created automatically when the analyses are run.
- `results/figures/` and `results/stats/`: generated figures and Bayes-factor tables.
