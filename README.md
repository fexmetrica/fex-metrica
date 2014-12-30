
FEX METRICA 
===========


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/fexicon.jpg "Icon")

FexMetrica comprises a set of preprocessing and statistical tools for the analysis of time series of facial expressions. The toolbox contains  Matlab functions and classes for preprocessing the time series computed with FACET facial expression recognition tools developped by Emotient, Inc. (http://www.emotient.com).

FEX METRICA includes code for running the analysis (fexSDK/src), and code to visualize the raw data or results (fexSDK/viewer). The documentation for each function can be accessed from Matlab, using "help" or "doc." Additionally, the folder named "samples" contains data and code which exemplify how to use the FEX METRICA.


===========
fexSDK/src
===========

The code is subdivided in three folders:

* FACET: the folder named "src/facet" comprises .cpp code to run analysis of a video using the Emotient toolbox (http://www.emotient.com).

* PROC: The "src/proc" folder contains various functions for filtering, wavelets convolution, normalization etc. The main Matlab object used for these operations is defined in FEXC.m. Some extra tools used for processing are stored in the folder "src/util."

* UI: A user interface, which can be used to run the analysis.


===========
fexSDK/viewer 
===========

VIEWER: This code can be used for visualization, and it displays statistics or raw data on images of faces. A manual is provided in the "FexView" folder.


![alt text](https://github.com/filipporss/fex-metrica/blob/master/manual/images/FexView-pic.jpg "Fex-Viewer")


===========
REQUIREMENTS
===========

FEX METRICA was developped on unix machine. Despite most operation should work on Windows systems as well, they were never tested. FEX METRICA is almost exclusively written in Matlab. The toolbox was tested on verison 2013a, 2013b, 2014b and 2015a. FEX METRICA requires the following Matlab modules:

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

This guide applies to OS X only, and to Homebrew users (http://brew.sh). If you already installed the FACET SDK, you probably have already run most of these commands. If Homebrew is not already set up, install Homebrew from a terminal with the following command:


```

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```

IMPORTANT: if you use mac-ports (https://www.macports.org), don't use the command above, because it could cause conflicts. If you are willing to switch from mac-port to Homebrew, uninstall mac-ports with these commands: http://guide.macports.org/chunked/installing.macports.uninstalling.html.


After installing Homebrew, do the following:


```

brew update
brew tap homebrew/science
brew install cmake, jsoncpp
sudo ln -s /usr/local/include/jsoncpp/json /usr/local/include/json

```

If you haven't installed OpenCv when you installed the Emotient SDK, you need to do it now. In a terminal, run the following command:


```

brew edit opencv

```

This will open the opencv.rb file. Find the following lines in the file:


>> jpeg = Formula["jpeg"]
>> py_prefix = %x(python-config --prefix).chomp
>> py_version = %x(python -c "import sys; print(sys.version)")[0..2]


After the "py_version ... " line, add the following lines:


>> ENV.append "CXXFLAGS", "-stdlib=libstdc++"
>> ENV.append "CFLAGS", "-stdlib=libstdc++"
>> ENV.append "LDFLAGS", "-stdlib=libstdc++ -lstdc++"
>> ENV["CXX"] = "/usr/bin/clang++ -stdlib=libstdc++"


Save, and close the .rb file. Now you need to install OpenCv. You can use the following command (which will also install several dependencies, including ffmpeg):


```

brew install --with-ffmpeg --build-from-source --fresh -vd homebrew/science/opencv

```


All required package should be set up, and you can now install FEX METRICA. Start Matlab, and navigate to the main FEX METRICA directory. On the Matlab prompt type the following:


```

>> fexinstall

```

A UI will pop up, which will ask you to indicate the path for the FacetSDK directory -- this is the directory of the Emotient toolbox, which contains subdirectories "facets", "include," "samples" ... After adding the FacetSDK directory, the .cpp code from FEX METRICA will be compiled and tested.


NOTE that based on your matlab installation, during the testing phase, you may run in the following error message:


>> dyld: Symbol not found: __ZN2cv5MutexD1Ev
>>  Referenced from: /usr/local/lib/libopencv_ocl.2.4.dylib
>>  Expected in: /Applications/MATLAB_R2013a.app/bin/maci64/libopencv_core.2.4.dylib
>>  in /usr/local/lib/libopencv_ocl.2.4.dylib


This is due to the fact that the copy of OpenCv used by Matlab, and the one used by the FACET SDK are not compatible. I am currently working on this issue. This means that you cannot call the FACET SDK from Matlab -- although you can still call it from the terminal. I am currently working on this bug.


===========

Support for this research was provided by NSF SBE 1232676. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the authors and do not necessarily reflect the views of NSF.