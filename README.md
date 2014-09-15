
WARNING: THE CODE is NOT reliable at this moment. I will let you know when it's safe to use it again. I am keeping this project private for the time being, because there is some code I need to add. I am working on the following improvements/modifications:


* FexView UI (update the existing UI to wrap the new visualization code);
* FexBeat: code to estimate heart beat from a video;
* fex_crf.m: code to estimate a canonical response function for AUs/emotions using stimuli onsets and specific kernels; 
* Update the "example" folder [THIS IS OUTDATED];
* Add all manuals and documentation.


===========

FexMetrica 1.0.1 is the first documented version of my preprocessing scripts and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET/CERT.

FexMetrica includes three main modules:

* Preprocessing/VideUtilities: A preprocessing object allows you to modify the raw video data, and let you process it with the Emotient SDK (http://www.emotient.com).

* Postprocessing: post-processing is done on a preprocessed object, namely the end result of the operations carried on by the preprocessing module. The "postproc" folder contains various functions for filtering, wavelets convolution, normalization etc. The end result of these operations is a matrix that can be used for regression or classification.

* FexView: This code can be used for visualization, and it displays statistics or raw data on images of faces. A manual is provided in the "FexView" folder.


INSTALLATION: After you download the folder, you need to add it to your Matlab path, at which point you can start using the various functions. Additionally, there is an "example" folder, which contains some notes on how to preprocess FACET time series, and how to generate facial features, such as complex Morlet wavelets. The code in the folder preproc/fexfacetutil can be compiled on Linux systems only (tested on Ubuntu 12.04 and 13.10). Follow instructions in the README file provided there for installation.

===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.