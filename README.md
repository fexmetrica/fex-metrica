
FEX METRICA 
===========

FexMetrica 1.0.1 comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET facial expression recognition tools developped by Emotient, Inc. (http://www.emotient.com).

===========
CONTENT
===========

FexMetrica includes three main modules:

* FACET/VideUtilities: A preprocessing object allows you to modify the raw video data, and let you process it with the Emotient SDK (http://www.emotient.com).

* PRE- and POST-PROCESSING: post-processing is done on a preprocessed object, namely the end result of the operations carried on by the preprocessing module. The "postproc" folder contains various functions for filtering, wavelets convolution, normalization etc. The end result of these operations is a matrix that can be used for regression or classification.

* FexViewer: This code can be used for visualization, and it displays statistics or raw data on images of faces. A manual is provided in the "FexView" folder.


===========
INSTALLATION
===========

After you download the folder, you need to add it to your Matlab path, at which point you can start using the various functions. Additionally, there is an "example" folder, which contains some notes on how to preprocess FACET time series, and how to generate facial features, such as complex Morlet wavelets. The code in the folder preproc/fexfacetutil can be compiled on Linux systems only (tested on Ubuntu 12.04 and 13.10). Follow instructions in the README file provided there for installation.

===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.