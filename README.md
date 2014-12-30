
FEX METRICA 
===========


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/fexicon.jpg "Icon")

FexMetrica comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET facial expression recognition tools developped by Emotient, Inc. (http://www.emotient.com).

FexMetrica includes code for running the analysis in the folder "fexSDK/src," code to visualize the data in "fexSDK/src/viewer," and a folder with examples ("fexSDK/src/samples"). Documentation for each function can be accessed from Matlab, using help or doc functions. The folder named "samples" contains data and code which exemplify how to use the toolbox.


===========
fexSDK/src
===========

The code is subdivided in three folders:

* FACET: A folder named "facet," which comprises .cpp code to run analysis of a video using the Emotient toolbox (http://www.emotient.com).

* PROC: The "src/proc" folder contains various functions for filtering, wavelets convolution, normalization etc. The end result of these operations is a matrix that can be used for regression or classification. The main Matlab class used for these operations is defined in FEXC.m. Some extra tools used for processing are stored in the folder "src/util."

* UI: A user interface, which can be used to run the analysis.


===========
fexSDK/viewer 
===========

VIEWER: This code can be used for visualization, and it displays statistics or raw data on images of faces. A manual is provided in the "FexView" folder.


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/FexView-pic.jpg "Fex-Viewer")


===========
REQUIREMENTS
===========


Most of the code in fex-metrica is written in Matlab. The coed was tested on verison 2013a, 2014a, 2014b and 2015a. Fex-metrica requires the following Matlab modules:

* Matlab stats toolbox;
* Matlab computer-vision toolbox;

Some of the VIEWER operations also require ffmpeg (https://www.ffmpeg.org) on OS X (on Linux, avconv is used instead).

Additionally, the "facet" module requires Facet SDK installed (see the documentation provided by Emotient Inc. for instruction) and OpenCV (http://opencv.org).



===========
INSTALLATION (OSX with Homebrew)
===========

This guide applies to OS X only, and to Homebrew users (http://brew.sh). If you already installed the FACET SDK, you probably have already run most of these commands.


If Homebrew is not already set up, install Homebrew from a terminal with the following command:


'''

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

'''

IMPORTANT: if you already use mac-ports (https://www.macports.org), don't use the command above, because it could cause conflicts. If you are willing to switch from mac-port to Homebrew, uninstall mac-ports with these commands: http://guide.macports.org/chunked/installing.macports.uninstalling.html.


After Homebrew is set up, do the following:


'''

brew update
brew tap homebrew/science
brew install cmake, jsoncpp
sudo ln -s /usr/local/include/jsoncpp/json /usr/local/include/json

'''

Now you need to install ffmpeg and opencv. If you haven't installed OpenCv when you installed the Emotient SDK, you need to do it now. You need to change the .rb file. In a terminal, run the following command:


'''

brew edit opencv

'''

This will open the opencv.rb file. Find the following lines in this file:

'''

jpeg = Formula["jpeg"]
py_prefix = %x(python-config --prefix).chomp
py_version = %x(python -c "import sys; print(sys.version)")[0..2]

'''

After the "py_version ... " line, add the following lines:

'''

ENV.append "CXXFLAGS", "-stdlib=libstdc++"
ENV.append "CFLAGS", "-stdlib=libstdc++"
ENV.append "LDFLAGS", "-stdlib=libstdc++ -lstdc++"
ENV["CXX"] = "/usr/bin/clang++ -stdlib=libstdc++"

'''

Now you need to install OpenCv. You can use the following command (which will also install several dependencies, including ffmpeg):


'''

brew install --with-ffmpeg --build-from-source --fresh -vd homebrew/science/opencv

'''


Now that all the dependencies are set up, you can install Fex-Metrica. Open Matlab, and navigate to the main Fex-Metrica directory. On the Matlab prompt type the following:


'''

>> fexinstall

'''

A UI will pop up, which will ask you to indicate the path for the FacetSDK directory -- this is the directory, which contains "facets", "include," "samples", and so on. Afterwords, the .cpp code from Fex-Metrica will be compiled and tested. "fexinstall.m" compiles the .cpp code from Fex-Metrica using the following command:


```

cmake -G "Unix Makefiles" && make

```

NOTE: ...




**



===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.