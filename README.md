
FEX METRICA 
===========


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/fexicon.jpg "Icon")

**fex-metrica** comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET facial expression recognition tools developped by Emotient, Inc. (http://www.emotient.com).

FEX METRICA includes code for running the analysis (fexSDK/src), and code to visualize the raw data or results (fexSDK/viewer). The documentation for each function can be accessed from Matlab, using "help" or "doc." Additionally, the folder named "samples" contains data and code which exemplify how to use the **fex-metrica**.


===========
ANALYTIC TOOLS
===========

Analytic tools can be access from [fexc.m](fexSDK/src/fexc.m), the main object defined by **fex-metrica**. This class wraps the Emotient tools for video analysis, generic video manipulation utilities, and timeseries transformations. A FEXC_OBJECT can also call the visualization tools described in the next section.

The tools associated with FEXC_OBJECTs comprise:

* "facet": a set of hard-coded routines which wrap some of FACET SDK functions;
* "util": several functions for data handling, and time series manipulation;
* "ui": [NOT DEVELOPPED] A user interface, which can be used instead of running the analysis from Matlab command line.


===========
VISUALIZATION
===========

**fex-metrica** viewer can be used for visualization, and it displays statistics or raw data on images of faces. A manual is provided in the "viewer/man" folder.


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/FexView-pic.jpg "Fex-Viewer")


===========
REQUIREMENTS
===========

**fex-metrica** was developped on unix machine. Despite most operation should work on Windows systems as well, they were never tested. FEX METRICA is almost exclusively written in Matlab. The toolbox was tested on verison 2013a, 2013b, 2014b and 2015a. **fex-metrica** requires the following Matlab modules:

* Matlab stats toolbox;
* Matlab computer-vision toolbox;

On OS X, some of the VIEWER functions require ffmpeg (https://www.ffmpeg.org).

Additionally, the "facet" module requires:

* Facet SDK;
* ffmpeg (https://www.ffmpeg.org);
* OpenCV (http://opencv.org).


===========
INSTALLATION GUIDE (OSX with Homebrew)
===========

This guide applies to OS X only, and to Homebrew users (http://brew.sh). If you installed FACET SDK, you probably have run most of these commands. However, if Homebrew is not set up, install Homebrew from a terminal with the following command:


```

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```

IMPORTANT: if you use mac-ports (https://www.macports.org), don't use the command above, because it could cause conflicts. If you are willing to switch from mac-port to Homebrew, follow this guide: http://guide.macports.org/chunked/installing.macports.uninstalling.html.


After installing Homebrew, do the following:


```

brew update
brew tap homebrew/science
brew install cmake, jsoncpp
sudo ln -s /usr/local/include/jsoncpp/json /usr/local/include/json

```

If you haven't installed OpenCv, you need to do it now. In a terminal, run the following command:


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

Save, and close the .rb file. Now you need to install OpenCv. You can use the following command (which will also install several dependencies, including ffmpeg):


```

brew install --with-ffmpeg --build-from-source --fresh -vd homebrew/science/opencv

```


All required package should be set up, and you can now install **fex-metrica**. Start Matlab, and navigate to the main **fex-metrica** directory. On the Matlab prompt, type the following:


```

>> fexinstall

```

A UI will pop up, which will ask you to indicate the path for the FacetSDK directory -- this is the directory of the Emotient toolbox, which contains subdirectories "facets", "include," "samples" ... After adding the FacetSDK directory, the .cpp code from **fex-metrica** will be compiled and tested.


NOTE that, based on your matlab installation, during the testing phase you may run in the following error message:


```
dyld: Symbol not found: __ZN2cv5MutexD1Ev
    Referenced from: /usr/local/lib/libopencv_ocl.2.4.dylib
    Expected in: /Applications/MATLAB_R2013a.app/bin/maci64/libopencv_core.2.4.dylib
    in /usr/local/lib/libopencv_ocl.2.4.dylib
```


This is due to the fact that the copy of OpenCv used by Matlab, and the one used by the FACET SDK are not compatible. This means that you cannot call the FACET SDK from Matlab -- although you can still call it from the terminal. I am currently working on this bug.


Once all these steps are completed, you can use **fex-metrica** for your project. However, the "fexinstall.m" file does not add permanently **fex-metrica** to your Matlab paths. Therefore, when you start Matlab, you need to run the following command:


```

addpath(genpath('STRING_WITH_FEX_METRICA_PATH'));

```

Change 'STRING_WITH_FEX_METRICA_PATH' to a string with the full path to the main **fex-metrica** folder.


===========
EXAMPLES
===========


The folder labeled [samples](fexSDK/samples/README.md) contains exemplifications of how to use the **fex-metrica** toolbox.


===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.