# R---Basics
This repository seeks to document a comprehensive journey through programming in R, from the basics to an intermediate level.

## First Analyses
This study analyzes usage data downloaded via API to reach an econometric conclusion. To achieve this, the data were cleaned and organized, and descriptive statistics and graphics were generated using basic procedures in R.

### Data
The data was downloaded from the World Bank server via the API in R as an XML file and covers the period from 2000 to 2022. Afterward, the data were saved as an RData file and used to produce descriptive statistics. Moreover, the indicator choosed were Gini Index, GDP per capita, and population. The missing data were imputed using linear and spline imputation. The cleaned data used basic tools from R, such as dplyr and Tidyverse.       

### Descriptive statistics
A table of descriptive statistics was created and is printed in the R script for the first analyses.

### Graphics 
The following graphic expresses the time series of the Gini Index for the 5 most equal countries and the 5 least equal countries. 

![image alt](https://github.com/meningue91/R---Basics/blob/4499228eb32a3df8d8addb3ed5993be06b5b833b/Images/Gini_index_mean.png)

The following graphic expresses a regression plot of the association between log GDP per capita and the Gini Index
![image alt](https://github.com/meningue91/R---Basics/blob/6b85ca040fed7e80e3626f936e1744b8be607e0d/Images/GDPxGini.png)

### Econometric inference
The result demonstrates the negative association between the Gini index and the natural logarithm of # GDP per capita, such that, in the model with linear imputation of the Gini, a one-unit increase in the values of said index—which for this study has a domain from 0 to 100—is negatively associated with a 5.27% drop in GDP per capita, given that the model used is log-lin. For the model without imputation, this result was 5.52%. Finally, for the model with spline imputation, the coefficient measuring the association between the inequality index and GDP per capita was # 9.03e-5, i.e., null.

### Conclusion
