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
Installation
===========

Start your copy of [Matlab](www.mathworks.com), and nvigate to the main [**Fex-Metrica** directory](../../../). Then, issue the following command:

```Matlab

>> fexinstall

```
**Fex-Metrica** is now up and running.


===========
Comments
===========

The Linux version of the code .cpp code is outdated. The OS X version is under development. The matlab code will be removed.