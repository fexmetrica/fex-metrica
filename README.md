FEX METRICA 
===========

**fex-metrica** comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. This toolbox contains Matlab functions and classes for preprocessing the time series computed with FACET SDK and Emotient Analytics facial expressions recognition tools developped by [Emotient, Inc](http://www.emotient.com).


Project Tree
========


    doc/                documnetation [not developped]
    fexSDK/             software development kit
        samples/        directory for sample application codes
        shared/         directory with shared hardcoded information
        src/            source code directory
            facet/      directory with cpp file for FacetSDK
            fexc.m      master class for fex-metrica
            ui/         directory for user interface
            util/       directory for utilities
            viewer/     visualization toolbox
        test/           directory for tests
    fexinstall.m        installation script
    LICENSE.md          MIT license
    README.md           this file


ANALYTIC TOOLS
===========


Analytic tools can be access using [fexc.m](fexSDK/src/fexc.m), which defines the main object used in **fex-metrica**. This class wraps the [Emotient, Inc](http://www.emotient.com) toolbox for video analysis, as well as generic video manipulation utilities, and timeseries transformations. The tools associated with a **FEXC** object include:

* [facet](fexSDK/src/facet/): a set of hard-coded routines which wrap some of FACET SDK functions;
* [util](fexSDK/src/util/): several functions for data handling, and time series manipulation;
* [ui](fexSDK/src/ui/): A user interface [partially developped].
* [viewer](fexSDK/src/viewer): toolbox for visualization.


REQUIREMENTS
===========


**Fex-metrica** was developped on Unix. Most operation should work on Windows as well, but they were never tested.

The following Matlab modules are required:

* Matlab [stats toolbox](http://www.mathworks.com/products/statistics/);
* Matlab [computer vision toolbox](http://www.mathworks.com/products/computer-vision/);
* Matlab [signal processign toolbox](http://www.mathworks.com/products/signal/).

Additionally, the VIEWER functions require [ffmpeg](https://www.ffmpeg.org) (or avconv).


Facet SDK
===========

When using [Emotient Analytics](http://www.emotient.com/products/emotient-analytics/), the [facet](fexSDK/src/facet/) module is not required. Instruction for installation using Facet SDK are included in the [facet directory](fexSDK/src/facet/).


INSTALLATION GUIDE
===========

Start Matlab, and navigate to the main **fex-metrica** directory. On the Matlab prompt, type the following:

```Matlab
>> fexinstall(1)
```

This will:

* Run some tests;
* Generate a fex_init.m file;
* Unzip the example folder.

After installation, in order to initialize **fex-metrica** type:


```Matlab
fex_init;
```

DCUMENTATION & EXAMPLES
===========


The [doc folder](doc) is empty. For now, documentation for most functions or methods can be accessed from Matlab, using "help" or "doc." 

The [samples folder](fexSDK/samples/README.md) contains examples of some operations that you can carry on in **fex-metrica**. 


UPDATES
==============


Scheduled Uptgrades
------------------

| Method                   | Update                          | isDone? |
| ------------------------ | ------------------------------- | ------- |
| .FEXC                    | Update documentation            |    0    |
|                          | Fix timing issue                |    0    |
| .UPDATE                  | Add multiple args               |    0    |
|                          | .DESIGN & .DESIGNINIT           |    0    |
| .REINITIALIZE            | Use defaults                    |    0    |
| .FEXPORT                 | Clean code                      |    0    |
|                          | Remove method "data1"           |    0    |
| .DERIVESENTIMENTS        | Make Sentiments a getter func   |    0    |
|                          | Set .thrsemo as structure       |    0    |
|                          | Add two thresold method         |    0    |
| .DOWNSAMPLE              | Fix structural & video          |    0    |
|                          | Gaussian kernel option          |    0    |
| .SETBASELINE             | Make a private property         |    0    |
|                          | Improve "neutral options"       |    0    |
| .INTERPOLATE             | Matrix size with structural     |    0    |
| .GETMATRIX               | Implement as MATRIX             |    0    |
| .GETBAND                 | Implement                       |    0    |
| .NORMALIZE               | Add arbitrary bounds            |    0    |
| .FEXEXPORT2VIEWER        | Remove                          |    0    |
| .SHOWANNOTATION          | Make stakable in GET            |    0    |
| .REGRESS                 | Implement MLR                   |    0    |
| .CLASSIFY                | Implement MLR                   |    0    |
| .SHOWANNOTATION          | Make stakable in GET            |    0    |
| .DEFAULT                 | Global default files            |    0    |
| .ESTCRF                  | Canonical Resp. Project         |    0    |
| .TEST                    | Implement tests                 |    0    |

===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.