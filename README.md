
FEX METRICA 
===========


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/fexicon.jpg "Icon")

**fex-metrica** comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET facial expression recognition tools developped by [Emotient, Inc](http://www.emotient.com).

[Fex-Metrica SDK](fexSDK/src) includes code for running the analysis, and code to visualize the raw data or results ([Fex-Viewer](fexSDK/viewer)). The documentation for each function can be accessed from Matlab, using "help" or "doc." Additionally, the folder named [samples](fexSDK/src/samples) contains data and code which exemplify how to use the **fex-metrica**.


Contents
========

The project tree is organized as follows.

    doc/                directory for documentation
    fexinstall.m        installation script
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
    LICENSE.md          MIT license
    manual/             directory with manuals
    README.md           this file


===========
ANALYTIC TOOLS
===========

Analytic tools can be access using [fexc.m](fexSDK/src/fexc.m), the main object defined by **fex-metrica**. This class wraps the [Emotient, Inc](http://www.emotient.com) toolbox for video analysis, as well as generic video manipulation utilities, and timeseries transformations. A **FEXC_OBJECT** generated with [fexc.m](fexSDK/src/fexc.m) can also call the visualization tools described in the next section.

The tools associated with **FEXC_OBJECTs** comprise:

* [facet](fexSDK/src/facet/): a set of hard-coded routines which wrap some of FACET SDK functions;
* [util](fexSDK/src/util/): several functions for data handling, and time series manipulation;
* [ui](fexSDK/src/ui/): [NOT DEVELOPPED] A user interface.
* [viewer](fexSDK/src/viewer): toolbox for visualization.


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/FexView-pic.jpg "Fex-Viewer")


===========
REQUIREMENTS
===========

**Fex-metrica** was developped on Unix. Most operation should work on Windows systems as well, but they were never tested. **Fex-metrica** is almost exclusively written in [Matlab](http://www.mathworks.com). The toolbox was tested on verison 2013b, 2014b and 2015a. **Fex-metrica** requires the following Matlab modules:

* Matlab [stats toolbox](http://www.mathworks.com/products/statistics/);
* Matlab [computer vision toolbox](http://www.mathworks.com/products/computer-vision/);

On OS X, some of the VIEWER functions require [ffmpeg](https://www.ffmpeg.org). Additionally, the [facet](fexSDK/src/facet/) module requires:

* [Facet SDK](http://www.emotient.com);
* [ffmpeg](https://www.ffmpeg.org);
* [OpenCV](http://opencv.org).

Note that the [facet](fexSDK/src/facet/) module is not required to run the analysis. It is possible to access [Emotient](http://www.emotient.com) system output elsewhere, and then generate a [FEXC_OBJECTs](fexSDK/src/fexc.m) for those results.


===========
INSTALLATION GUIDE (OSX with Homebrew)
===========

This guide applies to OS X only, and to [Homebrew](http://brew.sh) users. If you installed FACET SDK, you probably have run most of these commands. However, if [Homebrew](http://brew.sh) is not set up, install Homebrew from a terminal with the following command:


```

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```

IMPORTANT: if you use [mac-ports](https://www.macports.org), don't use the command above, because it could cause conflicts. If you are willing to switch from mac-port to Homebrew, follow this [guide](http://guide.macports.org/chunked/installing.macports.uninstalling.html).


After installing Homebrew, do the following:


```

brew update
brew tap homebrew/science
brew install cmake, jsoncpp
sudo ln -s /usr/local/include/jsoncpp/json /usr/local/include/json

```

If you haven't installed [OpenCV](http://opencv.org), you need to do it now. In a terminal, run the following command:


```

brew edit opencv

```

This will open the opencv.rb file. Find the following lines in the file:

```
jpeg = Formula["jpeg"]
py_prefix = %x(python-config --prefix).chomp
py_version = %x(python -c "import sys; print(sys.version)")[0..2]
```

After the "py_version ... " line, add the following lines:

```
ENV.append "CXXFLAGS", "-stdlib=libstdc++"
ENV.append "CFLAGS", "-stdlib=libstdc++"
ENV.append "LDFLAGS", "-stdlib=libstdc++ -lstdc++"
ENV["CXX"] = "/usr/bin/clang++ -stdlib=libstdc++"
```

Save, and close the .rb file. Now you need to install OpenCV. You can use the following command (which will also install several dependencies, including [ffmpeg](https://www.ffmpeg.org)):

```
brew install --with-ffmpeg --build-from-source --fresh -vd homebrew/science/opencv
```

All required package should be set up, and you can now install **fex-metrica**. Start Matlab, and navigate to the main **fex-metrica** directory. On the Matlab prompt, type the following:

```
>> fexinstall
```

A UI will pop up, which will ask you to indicate the path for the FacetSDK directory -- this is the directory of the Emotient toolbox, which contains subdirectories "facets", "include," "samples," ... After adding the FacetSDK directory, the .cpp code from **fex-metrica** will be compiled and tested.

Once all these steps are completed, you can use **fex-metrica** for your project. However, the "fexinstall.m" file does not add permanently **fex-metrica** to your Matlab paths. Therefore, when you start Matlab, you need to run the following command:


```Matlab
addpath(genpath('FEX_METRICA_PATH'));
```

Change 'FEX_METRICA_PATH' to a string with the full path to the main **fex-metrica** folder.


===========
EXAMPLES
===========


The folder labeled [samples](fexSDK/samples/README.md) contains exemplifications of how to use the **fex-metrica** toolbox.


===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.