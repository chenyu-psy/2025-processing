# Analysis Template

A standardized template for data analysis projects using Quarto documents in RStudio.

## Overview

This repository serves as a template for data analysis projects using Quarto (.qmd) files in RStudio. It provides a consistent structure for your analysis workflows, making it easier to organize your code, data, and outputs while ensuring reproducibility.

## Getting Started

### Using this Template

1. Click the green "Use this template" button at the top of this repository
2. Select "Create a new repository"
3. Name your repository and click "Create repository from template"
4. Clone the new repository to your local machine
5. Open the project in RStudio by clicking on the .Rproj file
6. Begin your analysis by modifying the template.qmd file in the root directory

### Alternative Method

If you prefer to use RStudio directly:

1. In RStudio, go to File → New Project → Version Control → Git
2. Paste the repository URL: `https://github.com/chenyu-psy/AnalysisTemplate.git`
3. Choose a directory for your project
4. Click "Create Project"

## Project Structure

```
AnalysisTemplate/
├── README.md                 # Project documentation
├── AnalysisTemplate.Rproj    # RStudio project file
├── data/                     # Data directory
│   ├── raw/                  # Raw, unprocessed data
│   └── processed/            # Cleaned and processed data
├── figures/                  # Output figures and visualizations
├── models/                   # Saved statistical models
├── samples/                  # Example files and sample outputs
├── scripts/                  # Supporting R scripts
├── functions/                # Custom functions for the project
```

## Contributing

If you have suggestions for improving this template, please open an issue or submit a pull request.

---

Created for data analysts who value reproducibility and organization.

