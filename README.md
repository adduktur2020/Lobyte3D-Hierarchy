Lobyte3D is a reduced-complexity numerical forward stratigraphy model designed to simulate deep-marine sediment transport and deposition. 

Full details of this method are given in Tahiru et al. 2024 and Burgess et al. 2019.

To run the Lobyte3D model, ensure that the MATLAB path includes the folder where the code and parameter files are stored. Load and run the Lobyte3D.m file in MATLAB. The model is controlled via a parameter file, allowing users to adjust sediment supply, flow characteristics, and depositional settings.

For example, on the Matlab command line type:
lobyte3D modelInputParameters/bigFan.txt

Note that bigFan.txt is an example input file, of which there are several in the modelInputParameters folder, all of which can be edited to change the model input parameters.

