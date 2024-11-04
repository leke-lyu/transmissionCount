<a name="readme-top"></a>
# __Characterizing Spatial Epidemiology in a Heterogeneous Transmission Landscape Using a Novel Spatial Transmission Count Statistic__

This repository contains the code, scripts, and data that support the analyses and findings of [our research paper](https://www.medrxiv.org/content/10.1101/2023.12.28.23300535v4).

## Overview

![Graph Abstract](https://github.com/leke-lyu/transmissionCount/blob/main/figures/overview.png)

In this study, we developed a pipeline to understand local-scale epidemic trends. Our approach includes proportional genome sampling based on case counts, followed by phylogeographic analysis using the Nextstrain workflow. Lastly, we summarize and compare transmission patterns across subregions to identify viral sources and sinks. To demonstrate the utility of this method, we focused on the Delta wave in Texas, aiming to characterize viral diffusion within the state and compare epidemic trends between urban and rural areas.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Data

The GISAID accession IDs of the genomes used in this study are provided.

`data/texasDelta.csv`: 24,593 SARS-CoV-2 genomes (Delta variant) sampled in Texas

`data/worldwideDelta.csv`: 6,386 Delta genomes from 49 countries 


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Analysis and Visualization

### Subsampling

Significant heterogeneity in sampling ratios was observed across various metropolitan areas in Texas from Epi-Week 14 to Epi-Week 43. To improve the accuracy of our phylogeographic analysis, we applied a proportional sampling scheme. A consistent sampling ratio of 0.006 served as our baseline. In under-sampled regions (where the sampling ratio was below the baseline), we retained all available genomes. Conversely, in over-sampled regions (where the sampling ratio exceeded the baseline), we down-sampled to match the baseline rate.

Following the approach of [Anderson F.Brito](https://github.com/andersonbrito/subsampler), we developed R scripts, later consolidated into an R package - [**Subsamplerr**](https://github.com/leke-lyu/subsamplerr). This package processes **case count tables** and genome metadata, enabling visual exploration of sampling heterogeneity and the implementation of proportional sampling schemes.

### Phylogeographic Analysis

We conducted a comprehensive phylogeographic analysis of 12,048 SARS-CoV-2 Delta genomes sampled from March 27, 2021, to October 24, 2021, to investigate the timing of virus introduction into Texas and the dynamics of the resulting local transmission lineages. These genomes were selected to ensure a roughly 1:1 ratio between Texas sequences and globally contextual sequences.

We applied the Nextstrain pipeline to generate a time-labeled phylogeny with inferred ancestral trait states. You can view the texas instance in [here](https://nextstrain.org/community/leke-lyu/deltaoutbreak/texas). You can find the config files that runs this build in [here.](https://github.com/leke-lyu/deltaInGreaterHoustonArea)

### Transmission Count

The transmission count metric is calculated to identify viral sources and sinks across subregions. This analysis summarizes transmission patterns within the study area, allowing for the comparison of local transmission intensity. The metric aids in distinguishing regions that are likely contributing to viral spread versus those primarily receiving introductions.

Each script includes specific instructions for running the analyses and generating publication-ready figures that represent the study's findings.


Each script includes specific instructions and is designed to be modular, allowing users to adjust for various data types or research questions.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact and Citation

For any questions, issues, or feedback, please reach out via [lekelyu@uga.edu].

If you use this workflow, please cite the following papers:
- **Transmission Count**: [https://doi.org/10.1101/2023.12.28.23300535]
- **Nextstrain**: [https://doi.org/10.1093/bioinformatics/bty407]
- **Proportional Sampling**: [https://doi.org/10.1016/j.cell.2021.03.061]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

