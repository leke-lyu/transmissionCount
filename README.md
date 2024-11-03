# __Characterizing Spatial Epidemiology in a Heterogeneous Transmission Landscape Using a Novel Spatial Transmission Count Statistic__

This repository contains the code, scripts, and data that support the analyses and findings of [our research paper](https://www.medrxiv.org/content/10.1101/2023.12.28.23300535v4).

## Overview

![Graph Abstract](https://github.com/leke-lyu/transmissionCount/blob/main/figures/overview.png)

- Background
Viral genomes contain records of geographic movements and cross-scale transmission dynamics. However, the impact of regional heterogeneity, particularly among rural and urban centers, on viral spread and epidemic trajectory has been less explored due to limited data availability. Intensive and widespread efforts to collect and sequence SARS-CoV-2 viral samples have enabled the development of comparative genomic approaches to reconstruct spatial transmission history and understand viral transmission across different scales.

- Methods
We proposed a novel spatial transmission count statistic that efficiently summarizes the geographic transmission patterns imprinted in viral phylogenies. Guided by a time-scaled tree with ancestral trait states, we identified spatial transmission linkages and categorize them as imports, local transmissions, and exports. These linkages were then summarized to represent the epidemic profile of the focal area.

- Results
We demonstrated the utility of this approach for near real-time outbreak analysis using over 12,000 full genomes and linked epidemiological data to investigate the spread of the SARS-CoV-2 in Texas. Our study showed (1) highly populated urban centers were the main sources of the epidemic in Texas; (2) the outbreaks in urban centers were connected to the global epidemic; and (3) outbreaks in urban centers were locally maintained, while epidemics in rural areas were driven by repeated introductions.

- Conclusions
In this study, we introduce the Source Sink Score, which allows us to determine whether a localized outbreak may be the source or sink to other regions, and the Local Import Score, which assesses whether the outbreak has transitioned to local transmission rather than being maintained by continued introductions. These epidemiological statistics provide actionable information for developing public health interventions tailored to the needs of affected areas.


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

