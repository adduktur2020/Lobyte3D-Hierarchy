Welcome to Lobyte 3D, the reduced-complexity dispersive flow fan model. See Burgess et al (2019) for more details of this model and what it does, 
but to get started, just follow these simple instructions

Double-click on Lobyte3D.m to start Matlab and load this source code file

To run the model with a specified parameter input file, on the Matlab command line type:
lobyte3D modelInputParameters/bigFan.txt

Note that bigFan.txt is an example input file, of which there are several in the modelInputParameters folder, 
all of which can be edited to change the model input paramters

Also, in the folder codeRunSpecificModels you will find Matlab code to run specific models and combinations of models - 
these may not all work without the associated parameter files, but they are good examples to see how to set up several model runs to run automatically

Other sub folders are:
codeCreateInputParameterFiles 	- code in here to create Lobyte3D input files, for example new initiial topography input files
codeModel			- all the source code the forward model part of Lobyte3D
codePlottingModelOutput		- all the plotting routines, to plot e.g. cross sections, chonostrat diagrams, maps etc
codePostprocessingAndAnalysis	- code to do stats analysis on the model output. Remember, all models are wrong but some are interesting to analyse statistically...
codeRunSpecificModels		- code to run specific models and combinations of models
modelInputParameters		- all the input parameter information that Lobyte3D needs is kept in here
modelOutput			- Lobyte3D output files are all kept in here. Note that the main output file containing saved strata is named using the model name parameter which is the first input parameter


