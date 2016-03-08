# stELMOD: A Stochastic Multi-Market Optimization Model with Rolling Planning
## Description
stELMOD is a stochastic optimization model to analyze the impact of uncertain wind generation on the dayahead and intraday electricity markets as well as network congestion management. The consecutive clearing of the electricity markets is incorporated by a rolling planning procedure resembling the market process of most European markets.

The model is documented in:
[Abrell, J. and Kunz, F. (2015): Integrating Intermittent Renewable Wind Generation - A Stochastic Multi-Market Electricity Model for the European Electricity Market, *Networks and Spatial Economics* 15(1), pp. 117-147.](http://link.springer.com/article/10.1007/s11067-014-9272-4)

The entire model is coded in [GAMS](http://gams.com/) and solved with CPLEX.

## License
This work is licensed under the MIT License (MIT).

>The MIT License (MIT)
>Copyright (c) 2016 Friedrich Kunz (DIW Berlin) and Jan Abrell (ETH Zurich)

>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## Citation
Whenever you use this code, please refer to
>[Abrell, J. and Kunz, F. (2015): Integrating Intermittent Renewable Wind Generation - A Stochastic Multi-Market Electricity Model for the European Electricity Market, *Networks and Spatial Economics* 15(1), pp. 117-147.](http://link.springer.com/article/10.1007/s11067-014-9272-4)

## Contact
Friedrich Kunz, DIW Berlin, [fkunz@diw.de](fkunz@diw.de), phone: +49(0)30 89789 495

___

## Model Structure
The model resembles three different market, **Dayhead**, **Reserve capacity**, and **Intraday market**. Additionally, **congestion management**, performed outside the market by the TSO, is considered. The different mmodules are connected through a rolling planning approach, which iterates through the hours of the year and solves the daily dayahead and reserve, hourly intraday market and hourly congestion management.

**Generation** is reflected by a unit commitment approach, which can be defined as a binary or integer (clustered) unit commitment.

**Load** is considered as price-inealastic fixed hour load. Load shedding options are available as last-resort option with high unit costs.

**Renewable generation** is valued at zero marginal costs and can be considered as either stochastic or deterministic infeed. The stochastics take effect in the intraday market as well as they could be considered in the congestion management. The dayahead market is defined as a deterministic model in any case.


## Model Files
To structure the entire code, different GAMS files are specified for specific purposes.

- **call.gms** - Main model file, which calls other gms-files
- **dataload.gms** - Dataupload and preprocessing of input data
- **construct_tree.gms** - Tree construction in case of stochastic model version
- **model_dayahead.gms** - Dayahead and reserve model
- **model_intraday_det.gms** - Deterministic intraday model
- **model_intraday_sto.gms** - Stochastic intraday model
- **model_congestionmanagement_det.gms** - Deterministic congestion management model
- **model_congestionmanagement_sto.gms** - Stochastic congestion management model
- **prepare_da_init.gms** - Prepare input data for initial dayahead model
- **prepare_da.gms** - Prepare input data for dayahead models in rolling planning
- **prepare_id.gms** - Prepare input data for initial intraday model
- **prepare_cm.gms** - Prepare input data for initial congestion management model
- **unfix.gms** - Unifx decision variables (used in prepare_*.gms)
- **import_gdx.gms** - Import gdx files with individual model results
- **report.gms** - Reporting of model results


## Model Input
This version of the model uses two separate input file formats: Excel and GDX

- **_%data%_.xls** - Definition of (nearly) all input data in corresponding sheets
- **_%ptdf%_.gdx** - Input for power-transfer-distribution-matrix (PTDF)


## Model Output
The model results are reported in GAMS gdx-format in a single file named _%result%_.gdx

The naming of the raw result parameters, final report (fr_*), is as follows:
- __fr_da_*__ - Final report of dayhead model results
- __fr_id_*__ - Final report of intraday model results
- __fr_cm_*__ - Final report of congestion management model results

These final reporting parameters are written after each model solve to a gdx-file and after successful rolling planning merged and uploaded to GAMS for further post-processing. 

**NOTE**: These individual gdx-files report only the results of the relevant hours or hour, and not the full solution of the entire model solve. E.g. Dayahead model is solved for 36 hour, but only 24 hour are reported. For intraday and congestion management, only the first hour is reported.

Within the report.gms a post-processing of the final reports is performed, with a pre-specified set of relevant output parameters. Once the model is solved, the reporting could be changed and the model option "_only_reporting_" allows to rerun the reporting with the previous model results.