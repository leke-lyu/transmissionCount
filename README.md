# __Characterizing Spatial Epidemiology in a Heterogeneous Transmission Landscape Using a Novel Spatial Transmission Count Statistic__

This repository contains the code, scripts, and data that support the analyses and findings of [our research paper](https://www.medrxiv.org/content/10.1101/2023.12.28.23300535v4).

## Overview

![Graph Abstract](https://github.com/leke-lyu/transmissionCount/blob/main/figures/overview.png)

In this study, we developed a pipeline to understand local-scale epidemic trends. Our approach includes proportional genome sampling based on case counts, followed by phylogeographic analysis using the Nextstrain framework. Lastly, we summarize and compare transmission patterns across subregions to identify viral sources and sinks. To demonstrate the utility of this method, we focused on the Delta wave in Texas, aiming to characterize viral diffusion within the state and compare epidemic trends between urban and rural areas.


## Data

The data used in this study is partially available in this repository, with some components accessible upon request due to [any applicable restrictions]. For reproducibility, ensure the data is in the expected format as outlined in `data/README.md`.

To get started:
1. Place all required data files in the `data` directory.
2. Follow the file naming conventions and format requirements for seamless integration with the scripts.

## Analysis and Visualization

The `analysis` folder includes scripts for conducting the following:
- **Data Analysis**: Scripts for calculating core metrics, including Source Sink Score and Local Import Score.
- **Phylogenetic Analysis**: Steps for tree generation and related calculations.
- **Sensitivity Analysis**: Evaluate metric stability across different regions or datasets.
- **Visualization**: Generate publication-ready figures reflecting the study’s findings.

Each script includes specific instructions and is designed to be modular, allowing users to adjust for various data types or research questions.

## Contact and Citation

For any questions, issues, or feedback, please reach out via [Your Contact Information].

If you use this code, please cite our paper as follows:
- **Citation**: [Your Paper Title, Authors, Journal/Publisher, DOI if available]

