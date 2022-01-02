## General information ##

In this repository we provide a collection of scripts that were used for conducting data analysis for a
Pancreatic Ductal Adenocarcinoma study in 2022.

## Downloading the repository ##

The repository is structured into submodules, hence we recommend using git to acquire the code:

Use the git command

>     git clone https://github.com/anonymResearcher/PDAC-study-2022.git --recurse-submodules  

to check out all the related repositories instantly.

## Workflows ##

The repository is structured into 2 independent workflows to perform the following tasks:

* Proteomic data analysis
* TMA image registration and quantification

Further information on how to run these workflows can be found below in this readme.

## Environment ##
Our data analysis was conducted with R v4.0.3 and Matlab R2018b on a regular 64bit laptop with Windows10 operating system. The proteomic workflow was also tested on Mac, 
and the TMA image registration on all images was run on clusters for faster processing.

To install R and its most frequently used code editor RStudio follow the general guidelines of these software found at:	
	
* R: https://www.r-project.org/
* RStudio: https://www.rstudio.com/products/rstudio/download/#download

Running the codes written in Matlab (only the TMA registration pipeline) require a license from Mathworks, and available in most academic institutes.
	
## Dependencies ##
	
### R packages ###
We are utilizing several R libraries, each of which can be acquired from the following places:

- CRAN, using the standard `install.packages()` function of R *OR*
- Bioconductor using the `BiocManager::install()` function. This requires first installing BiocManager with `install.packages("BiocManager")`.

## Proteomic data analysis ##

The proteomic data analysis workflow includes the normalization of protein values (batch-effect correction by ComBat, housekeeping normalization), 
pathway expression calculations, principal component analysis (PCA), t-tests between tissue types, volcano plots and Group Factor Analysis.
	
### Source data ###

The proteomics workflow uses and creates several files, most of which should be placed in a so-called "working directory". 
Before running this workflow create your wokring directory and a subfolder named `Data` in it. Download and place the following files into your `Data` folder:

1. P1-5_Pancreas_cancer_Proteins_list.txt containing the proteomic data of patients 1-5, available from PRIDE.
2. P6-14_Pancreas_cancer_Proteins_list.txt containing the proteomic data of patients 6-14, available from PRIDE.
3. Supplemental_File_3 containing the proteomic data of healthy controls, available as a supplement from the publisher's website.
4. Supplemental_File_4 containing the survival data of the patients in this study, available as a supplement from the publisher's website.
5. Create a directory named `reactome` and download into it the following files from https://reactome.org/download/current/ :
	- ReactomePathways.txt
	- ReactomePathwaysRelation.txt
	- UniProt2Reactome_All_Levels.txt
6. Create a directory named `jci-tessa` and download the following files to it from https://insight.jci.org/articles/view/138290#sd :
	- jci.insight.138290.sdt1.xlsx (Supplemental Table 1)
	- jci.insight.138290.sdt2.xlsx (Supplemental Table 2)
	- Download the Supplemental data pdf file to your computer (first pdf), and convert the Supplemental table 2 into an xlsx file. This can be done for instance by opening the pdf in Word, 
	  copy-pasting the table to excel and saving the result file. Name the result file as jci-patients.xlsx .
7. Create a directory named ˙HPM˙ (Human Proteome Map) and download the following files to it from https://www.humanproteomemap.org/download_hpm_data.php . Note that the files are available for download
   after submitting basic information to the form.
	- HPM_gene_level_epxression_matrix_Kim_et_al_052914.xlsx (Gene-level expression matrix)
	- HPM_protein_level_expression_matrix_Kim_et_al_052914.xlsx (Protein-level expression matrix)
	- HPM_protein_level_expression_matrix_Kim_et_al_052914.xlsx (Peptide-level expression matrix)
8. Create a directory named `DeepProteomeAtlas` and download the following file into it from https://www.embopress.org/doi/full/10.15252/msb.20188503 :
	- Table_EV1.xlsx (Table EV1 link in the Supporting Information section, remember to extract the zip file)

### Configuration ###

Beyond creating a working directory, an output (or result) directory is also needed (this may be empty). The specification of these locations happen in the `Proteomics/R/init/init_vars.R` file.
In the beginning of this file, set the variable `wd` to the working directory and `rootResultPath` to the output directory (specify the paths between quotes so that R interprets these values as strings). 
Note that even on Windows machines, the path should be specified with regular slashes (/), e.g. C:/Users/... and not C:\Users\...

On Unix based systems, one can fasten the computations by using the configuration below in the `Proteomics/R/init/init_vars.R` file. These settings will cause some parts of the code to run in parallel.

```
# Examplary setup for Unix machines
wd = "/path_to_my_working_directory",
mcCoresLow = 1,
mcCoresMid1 = 4,
mcCoresMid2 = 6,
mcCoresHigh1 = 7,
mcCoresHigh2 = 8,
foreachCores = 4,
rootResultPath = "/path_to_my_result_directory"
```

### Running the workflow ###

The entry point for the proteomic data analysis is the `Proteomics/R/pipe.R` file. Run this script to reproduce our findings by sourcing it in R (this can be done e.g. by typing in
`source('thePathToThisRepository/Proteomics/R/pipe.R')` to the R console window.

## TMA image registration ##

The TMA image registration workflow is used to quantify tissue Microarray (TMA) microscopy images that were used to quantify protein compartmentalization with antibodies. 
The different antibody stainings were applied on parallel tissue sections, hence the workflow starts with registering them into a common space. The registered images
were color-deconvolved to separate the hematoxylin and antibody signals, and subjected to Mander's colocalization analysis. 
Additionally, the sample and background areas were identified with Ilastik and used in several stages of the workflow. Note, that running this pipeline requires license to the Matlab software.

### Source data ###

We provide a reduced demo dataset at: https://drive.google.com/drive/folders/1Br1uosL5I1_2_caheh7BdQhOSjLr3ba7?usp=sharing for the TMA registration workflow to demonstrate the required input formats and facilitate any possible re-use of this workflow. 
However, we note that parts of this workflow should be customized for new cases, such as the foreground-background detection with Ilastik, and the color-deconvolutions.

1. The source microscope images should be organized into separate folders according to the stains, as in the `sourceImages` directory of the demo data.
2. Ilastik models should be trained for each stain separately. Training images can be created randomly by running the `Registrations/Matlab/Registration/Ilastik/prepareForIlastik.m` script. 
   Note that the workspace has to be configured in advance, with the `Registrations/Matlab/Registration/setRegistrationPipeParameters.m` script. Once the training images are ready, use Ilastik to
   create trained models for separating the foreground and the background. The trained models should be placed under `wrkDir\ilastik\trainImgs` and named according to the stain nomenclature (see the demo example)
3. The color deconvolution requires representative colors of each stain (both for the antibody and the hematoxylin channels). 
   These can be specified in a separate `singleStainSamples.mat` file located in the work directory, or if the file is not present the workflow prompts the user to select representative colors on the images.
   The prepared file contains a matrix variable named `myStain` (each row is a single channel, 2 rows per antibody, and columns correspond to RGB) specifying these representative colors.
 
### Dependencies ###

1. The workflow internally calls python, hence a python installation is required (we used python v 3.6.6 in this project), see https://www.python.org/downloads/ for details. 
   Note, that additional (standard) python modules should be installed: numpy, scipy, math, sys, time and os.
2. This workflow requires Ilastik to be installed, available from: https://www.ilastik.org/ .

### Configuration and run ###

The workflow is configured using the `Registrations/Matlab/Registration/setRegistrationPipeParameters.m` script, check the variable descriptions in the comments of the file. 
Note, that the working directory of the demo dataset (and referred to above) is the `targetDir` variable.

Finally, add all code to the Matlab search path by `addpath(genpath("path_to_this_repository"))`, and then run the workflow with the `fullPipe` command, until the `collocalizeSet` script.

In addition to the `setRegistrationParameters` file, one should also specify the manual threshold values for the deconvolved images. The workflow performs the color deconvolution in the `colorDeconvolveSet` script, 
called in the end of the `fullPipe` script. The deconvolved images will be placed in the working directory under the `Deconvolved` and `DeconvolvedSmall` subdirectories. The threshold values can be determined 
by opening the images in an external program for instance in Fiji. Once the satisfactory threshold value is found, it should be specified in the `Registrations/Matlab/Registration/collocalizeSet.m`.

After the threshold values are customized to the image set, finish the run of the `fullPipe.m` script with calling the `collocalizeSet` script.

### Plot creation ###

The main script of the workflow does not prepare the box-plots of the study, it only creates the raw data needed for creating those. There are both Matlab and R (ggplot) figure creation codes available. 

1. First, configure and run the `Registrations/Matlab/Registration/plotBoxPlot.m` script (configuration means that, set the `dataPath` variable to the `CollocResults` subdirectory of your working directory, and 
   specifying the `stainNames` variable to match with your current stains). Note, that there is a possibility to manually exclude certain spots from the analysis by the `ignoreList` variable, if the registration does not satisfy your expectations.
2. Run the `runFullTransformOnIlastikPrediction` script from the Matlab terminal.
3. Run the `createGlobalSampleCoverage` script from the Matlab terminal.
4. The figures of the publication were created with R and ggplot, which can be done with running the `Registrations/R/boxPlot.R` script. The configuration of this script involves setting the `basePath` variable 
   to the same path as the `dataPath` in point 1., and specifying the location for the `TMA_diagnosticInfo.csv` file. This latter file can be used to assign patient IDs and diagnoses to be used for the
   final plots. See the example in the demo dataset.
   
## Contacts ##

Unavailable due to double-blind-peer-review process. Please use the submission system for any inquiries.
