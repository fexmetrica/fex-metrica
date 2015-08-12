FACET SDK 
===========

This code is a [Matlab](www.mathworks.com) toolbox that wraps some of the functionalities of the [FACET SDK](http://www.emotient.com), and it is part of **Fex-Metrica** ((c) Filippo Rossi 2014 - 2015).

===========
Requirements
===========

In order to run FexFacetUtil you need to have Matlab installed on your computer. Additionally, the [FACET SDK](http://www.emotient.com) needs to be already installed alongside OpenCV (as indicated in [documentation](../../../README.md)).

This module comprises two subdirectories:

 * matlab;
 * cpp.

The "matlab" directory comprises functions and objects which allow to call some of FACET functionalities from matlab. "cpp" contains .cpp files, which call FACET SDK directly. Currently there are two versions, one for Ubuntu, and one for OS X:

 * linux - [obsolete] developed for FACET SDK v2.02 (January 2014);
 * osx - developed for FACET SDK v4.01 (December 2014) on OS X.

===========
Installation (OSX ONLY)
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

After installation, in order to initialize **fex-metrica** type:

```Matlab
fex_init;
```

Change 'FEX_METRICA_PATH' to a string with the full path to the main **fex-metrica** folder.


===========
Comments
===========

The Linux version of the code .cpp code is outdated. The OS X version is under development. The matlab code will be removed.