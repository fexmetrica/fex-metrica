Development Notes
===============

This files contains a list of scheduled updates and a log of the update committed. Each commitment is preceeded by a set of tags, which are described below:

**SCOPE**: name of the **fex-metrica** module, to which commitment applies. Options include:

* [VIEW] -- Submissions that apply to **fex-metrica** viewer module;
* [OS]   -- Submissions which adds functionality for specific OS;
* [SRC]  -- This option indicates changes made to **fex-metrica** processing functions;
* [DOC]  -- Changes made to documentation and samples;
* [GLOB] -- Changes made to folder structure, and meta-data included. 

**TYPE**: type of update provided, namely one of the following options:

* [NEW]  -- Add new functionality;
* [UP]   -- Upgrade of functionality for existing method of function;
* [BUG]  -- Fix existing issue.

**METHOD**: name of the main FEXC method to which an update applies, or function modified by the submission.

**STATUS**: indicates what is the status of the submission under consideration. Status can be one of the following:

* [W] -- [W]aiting status: submission is planned, but not yet implemented;
* [P] -- [P]artial submission: a planed change was partially committed, but not yet completed; 
* [D] -- [D]one: submission was completed.


Updates Log
===============


Jan 18 - Jan 24
---------------

| Scope  | Type   | **fexc** method     | Description             | Status | Num  | Date   | 
| ------ | ------ | ------------------- | ----------------------- | ------ | ---- | ------ |
| [DOC]  | [NEW]  | []                  | Add UPDATE.md file      |   [D]  | 1    | 18-Jan |
| [DOC]  | [UP]   | []                  | Add documentation       |   [D]  | 1    | 21-Jan |
| [VIEW] | [UP]   | [.VIEWER]           | Make stackable          |   [P]  | 2    | 18-Jan |
| [VIEW] | [UP]   | [.SHOW]             | Make interactive        |   [P]  | 1    | 19-Jan |
| [SRC]  | [UP]   | [.FEXC]             | Add varargin construct  |   [P]  | 1    | 21-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | time for constructor    |   [P]  | 2    | 19-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | nan for constructor     |   [P]  | 1    | 18-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | cell input option       |   [P]  | 1    | 18-Jan |
| [SRC]  | [UP]   | [.FEXC]             | design importer         |   [P]  | 1    | 22-Jan |
| [SRC]  | [BUG]  | [.FEXPORT]          | export to cvs option    |   [W]  | 1    | 18-Jan |
| [SRC]  | [BUG]  | [.DESCRIPTIVES]     | bug in derive stats     |   [P]  | 2    | 20-Jan |
| [OS]   | [UP]   | []                  | .bashrc related issue   |   [P]  | 1    | 18-Jan |
| [OS]   | [BUG]  | [FEXW_SEARCHG]      | "find" issue on Windows |   [P]  | 1    | 18-Jan |


Jan 25 - Jan 31
---------------

| Scope  | Type   | **fexc** method     | Description             | Status | Num  | Date   | 
| ------ | ------ | ------------------- | ----------------------- | ------ | ---- | ------ |
| [SRC]  | [UP]   | [.NORMALIZE]        | Combine with SETBASLINE |  [P]   | 1    | 26-Jan |
| [SRC]  | [UP]   | [.FEXC]             | Demographics info       |  [D]   | 1    | 26-Jan |
| [SRC]  | [NEW]  | [.SUMMARY]          | Print summary info      |  [P]   | 2    | 29-Jan |
| [GLOB] | [UP]   | [fex_init.m]        | Improve set up          |  [D]   | 1    | 27-Jan |  
| [SRC]  | [UP]   | [.DESIGN]           | Design UI               |  [P]   | 1    | 29-Jan |  
| [SRC]  | [UP]   | [FEX_FACETPROC.m]   | min size for facet cmd  |  [P]   | 1    | 29-Jan |  
| [DOC]  | [UP]   | [FEXEMPLE_SERVER]   | Add example of server   |  [P]   | 1    | 30-Jan |
| [SRC]  | [NEW]  | [FEX_VIDEOCROP]     | Cropping video util     |  [P]   | 1    | 30-Jan |

Feb 1 - Feb 7
---------------

| Scope  | Type   | **fexc** method     | Description               | Status | Num  | Date   | 
| ------ | ------ | ------------------- | ------------------------- | ------ | ---- | ------ |
| [SRC]  | [NEW]  | [FEXDESIGNC]        | Helper design class       |  [P]   | 1    | 2-Feb  |
| [SRC]  | [UP]   | [FEXDESIGNC]        | UI wrapper for design     |  [P]   | 1    | 2-Feb  |
| [SRC]  | [UP]   | [.SUMMARY]          | Sentiments for summary    |  [D]   | 1    | 2-Feb  |
| [SRC]  | [UP]   | [.FEXC]             | Wrap FEXCDESIGNC          |  [P]   | 2    | 6-Feb  |
| [DOC]  | [UP]   |                     | Add FEXC TODO list        |  [D]   | 1    | 4-Feb  |
| [SRC]  | [BUG]  | [FEXDESIGNC]        | .RENAME,.INCLUDE,.CONVERT |  [D]   | 1    | 6-Feb  |
| [SRC]  | [UP]   | [FEXIMPORTDG]       | Update UI wrap FEXDESIGNC |  [D]   | 1    | 6-Feb  |
| [SRC]  | [UP]   | [FEXGENC]           | Use FEXDESIGNC            |  [D]   | 1    | 6-Feb  |


List of issues with **FEXC** object
================

| Method                   | Description                     | isDone? |
| ------------------------ | ------------------------------- | ------- |
| .FEXC                    | Update documentation            |    0    |
| .UPDATE                  | Update documentation            |    0    |
|                          | Add multiple args               |    0    |
|                          | .DESIGN & .DESIGNINIT           |    0    |
| .REINITIALIZE            | Use defaults                    |    0    |
|                          | FEXDESIGNC.RESET                |    0    |
| .GETVIDEOINFO            | Getter property                 |    0    |
|                          | VideoReader warning             |    0    |
| .VIDEOUTIL<sup>1</sup>   | Make Linux compatible           |    0    |
|                          | Add modification for structural |    0    |
| .FEXPORT                 | Clean code                      |    0    |
|                          | Remove method "data1"           |    0    |
| .DERIVESENTIMENTS        | Make Sentiments a getter func   |    0    |
|                          | Set .thrsemo as structure       |    0    |
|                          | Add two thresold method         |    0    |
|                          | Backup non thresholded emotions |    0    |
| .DOWNSAMPLE              | Fix structural & video          |    0    |
|                          | Gaussian kernel option          |    0    |
| .SETBASELINE             | Make a private property         |    0    |
| .DESCRIPTIVES            | Clean method                    |    0    |
| .MOTIONCORRECT           | Matrix size with structural     |    0    |
|                          | Add translation parameters      |    0    |
| .INTERPOLATE             | Clean Method                    |    0    |
|                          | Matrix size with structural     |    0    |
|                          | Update design & designinit      |    0    |
| .GETMATRIX               | Implement as MATRIX             |    0    |
| .GETBAND                 | Implement                       |    0    |
| .NORMALIZE               | Update documentation            |    0    |
| .VIEWER<sup>2</sup>      | Single vieweer method           |    0    |
| .SHOW                    | Make interactive                |    0    |
|                          | Add sentiments parameters       |    0    |
| .INIT                    | Add INIT to fex_defaults        |    0    |
| .CHECKARGS               | Fix DESIGN & DESIGNINIT         |    P    |
| .FEXEXPORT2VIEWER        | Remove                          |    0    |
| .SHOWANNOTATION          | Make stakable in GET            |    0    |


<sup>**1**</sup> This may be implemented as a class instead.
<sup>**2**</sup> Viewer has more specific updates needed.


List of planned updates
================

* Add a default file for FEXC ............ [SRC][NEW][.FEXC]
* ~~Add summary method~~ ................. [SRC][NEW][.FEXC]
* ~~Summary Sentiments percentage~~ ...... [SRC][UP][.FEXC]
* ~~Video cropping util~~ ................ [SRC][NEW][UTIL]
* Update .gitignore ...................... [GLOB][UP][]
* Design import and edit ................. [SRC][UP][.DESIGN] 
* GETMATRIX method ....................... [SRC][UP][.GETMATRIX]
* Statistical methods<sup>1,2</sup> ...... [SRC][NEW][]
* Fit a response & plot .................. [SRC][NEW][]
* Add catch path in importer ............. [SRC][UP][.FEXC]
* ~~Add demographic info~~ ............... [SRC][NEW][.FEXC]
* Bug with fexc viewer overlay ........... [VIEW][UP][.VIEWER]
* Add saving files part .................. [VIEW][BUG][.VIEWER]
* Add selct file overlay viewer .......... [VIEW][UP][.VIEWER]
* NO overlay movie (??) .................. [VIEW][BUG][.VIEWER]
* Add preproc from the viewer ............ [SRC,VIEW][NEW][.VIEWER]

<sup>1</sup>Rregression, classification, sparse solution and cross validation.
<sup>2</sup>Decide for the stats output.



