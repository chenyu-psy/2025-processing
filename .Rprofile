if (interactive()) {
  message("Loading initRproject...")
  if (!require("initRproject", quietly = TRUE)) {
    message("Installing initRproject from GitHub...")
    if (!require("remotes", quietly = TRUE)) {
      install.packages("remotes")
    }
    remotes::install_github("chenyu-psy/initRproject")
    library(initRproject)
  }
}
