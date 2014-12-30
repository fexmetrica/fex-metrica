
FexMetrica FACET wrapper
===========

This code is a Matlab (www.mathworks.com) toolbox that wraps some of the functionalities of the FACET SDK (http://www.emotient.com), and it is included in “FexMetrica” (Filippo Rossi, www.github.com).

===========
Requirements
===========

In order to run FexFacetUtil you need to have Matlab installed on your computer. Additionally, the Emotient SDK needs to be already installed alongside OpenCV (as indicated in the Emotient SDK manual).

This module comprises two subdirectories:

 * matlab;
 * cppdir.

The "matlab" directory comprises functions and objects which allow to call some of FACET functionalities from matlab. "cppdir" contains .cpp files, which call FACET SDK directly. Currently there are two versions, one for Ubuntu (obsolete), and one for OS X:

 * linux - [obsolete] developed for FACET SDK v2.3 (January 2014) on Ubuntu;
 * osx - developed for FACET SDK v4.0 (December 2014) on OS X.

===========
Installation
===========

From a terminal, go in the src/facet/osx directory and type:

```

cmake -G "Unix Makefiles" && make

```

===========
Example
===========

...

===========
Comments
===========

The Linux version of the code .cpp code is outdated. The OS X version is under development. 