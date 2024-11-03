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

### Subsampling

Following the approach of [Anderson F.Brito](https://www.cell.com/cell/fulltext/S0092-8674(21)00434-7), we developed R scripts, later consolidated into an R package - [**Subsamplerr**](https://github.com/leke-lyu/subsamplerr). This package processes case count tables and genome metadata, enabling visual exploration of sampling heterogeneity and the implementation of proportional sampling schemes.

### Phylogeographic Analysis

Our pipeline integrates with the Nextstrain framework to conduct phylogeographic analysis. This step involves reconstructing phylogenetic trees and mapping the geographic spread of lineages over time. We also include options for visualizing lineage migration patterns, highlighting the movement of viral strains between urban and rural areas.

### Transmission Count

The transmission count metric is calculated to identify viral sources and sinks across subregions. This analysis summarizes transmission patterns within the study area, allowing for the comparison of local transmission intensity. The metric aids in distinguishing regions that are likely contributing to viral spread versus those primarily receiving introductions.

Each script includes specific instructions for running the analyses and generating publication-ready figures that represent the study's findings.


Each script includes specific instructions and is designed to be modular, allowing users to adjust for various data types or research questions.

## Contact and Citation

For any questions, issues, or feedback, please reach out via [Your Contact Information].

If you use this code, please cite our paper as follows:
- **Citation**: [Your Paper Title, Authors, Journal/Publisher, DOI if available]

