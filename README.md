
WARNING: I am restructuring the code to make it object oriented. THE CODE is NOT reliable at this moment. I will let you know when it's safe to use it again.

There will be 4 main modules with four corresponding main objects:

* Preprocessing/VideUtilities: A preprocessing object allows you to modify the raw video data, and let you process it with the Emotient SDK (or 	CERT if you have the command line version of it).

* Postprocessing: post processing is done on a dataset object (the end result of preprocessing). This module contains the various functions for filtering, wavelet convolution etc. that used to be in the src folder. Additionally, I am adding some dimensionality reduction tools, and sources decomposition.

* Statistics: This creates a model  object from a dataset object. It includes utilities for design specification, statistical testing with permutation tests, and bootstrapping. 

* Visualization: This code display statistics from model estimation (or from raw data) on a template image of the face. 


fex-metrica
===========

fex_met 1.0.1 is the first documented version of my preprocessing scripts and statistical tools for the analysis of time series of facial expressions.

The package so far contains only Matlab script for perprocessing the timeseries outputed by FACET/CERT.

After you download the folder, you need to add it to your matlab path, and you can start using the various functions. Additionally, there is an "example" folder, which contains some notes on how to preprocess FACET timeseris, and how to generate facial features, such as Gaussian bumbs or complex Morelet wavelets.

The module in the folder src/preproc/fexfacetutil works on Linux only. Follow instructions in the README file provided there for installation.

I am keeping this project private for the time being, because there is a ton of code I need to add.
