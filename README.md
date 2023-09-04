# Code to adjust draft DGVs for copper and zinc
This Rcode enables users to adjust the draft default guideline values (DGVs) for the toxicants copper and zinc in fresh water. These DGVs are calculated based on concentrations of dissolved organic carbon, pH and hardness.
The draft DGVs are those submitted to ANZG in 2023. 
https://www.waterquality.gov.au/anz-guidelines/guideline-values/default/draft-dgvs#draft-default-guideline-values
Those draft DGVs may change and if so the code here will be updated.

## Using this code
The code has several required dependencies (see below) and a library, two functions (one for copper and one for zinc) and example data to test. 
Users will need to read in their data (DOC, pH and hardness) and then use the functions to calculate the DGVs.
Bioavailable copper concentrations are also estimated, based on the tier 1 DGV (at DOC of <=0.5 mg/L). Bioavailable zinc concentrations are also calculated but these should only be used when using the zinc attribute table to grade site. These bioavailable zinc concentrations NOT recommended for other uses.

## Dependencies
To use the code for zinc, you need the following:
1) The Burrlioz application must be installed on your computer. Download from here: 
https://research.csiro.au/software/burrlioz/
2) Rdata files with the required zinc toxicity data and MLR parameters. These are found in this github and need to be saved into a folder on your drive.
   
## Development
The code and files will be updated if the draft DGVs are updated. Feel free to submit any requests for new functionality, and get in contact if there are issues. 
For help with the code, contact below. For help using github, ask someone else. 

## Contacts
Maintainer: Jennifer Gadd  jennifer.gadd@niwa.co.nz
With thanks to Caroline Fraser (LWP) on the R coding.

