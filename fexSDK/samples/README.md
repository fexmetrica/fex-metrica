
FexMetrica Examples Folder
===========

This folder contains an examplification of some of the tools from **fex-metrica**. The code can be run from the file [fexemple1.m](fexemple1.m).


File Description
===========

This directory is organized as follow:

    
    data/                   directory for data
        contempt.json       js file for contempt movie
        contempt.mov        movie with contempt expression
        disgust.json        js file for disgust movie
        disgust.mov         movie with disgust expression
        smile.json          js file for smile movie
        smile.mov           movie with smile expression
    fexemple1.m             main script for example
    README.md               this file        
    


Generate a FEXC object
===========

A **fexc** object is the main class used for the analysis, and can be generated in several ways. The easiest way is to use the "ui" option. The UI let you select:

1. Video files;
2. Files with the facial expressions timeseries;
3. Outout directory.


```Matlab
fex_init;
fexobj = fexc('ui');
```

Note that Calling FEX_INIT adds **fex-metrica** to Matlab search path.

If you have the movies, but not the files with facial expressions, the UI gives you the option to analyze the data by pressing the FACET button. For this option to work, you need to have a local copy of the Facet SDK installed. Additionallty, you need to run [fexinstall](../../fexinstall.m).


![alt text](https://github.com/filipporss/fex-metrica/master/fexSDK/samples/constimg.png "Fexc Constructor UI")

