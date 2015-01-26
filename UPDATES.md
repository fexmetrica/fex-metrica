Development Notes
===============

This files contains a list of scheduled updates planed on a wakly basis.

Tags Description
===============

Each commitment is preceeded by a set of tags, which are described below:

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


Update Tags
===============

Updates are scheduled on a weekly basis. 


Jan 18 - Jan 24
---------------

| Scope  | Type   | **fexc** method     | Description             | Status | Num  | Date   | 
| ------ | ------ | ------------------- | ----------------------- | ------ | ---- | ------ |
| [DOC]  | [NEW]  | []                  | Add UPDATE.md file      |   [D]  | 1    | 18-Jan |
| [DOC]  | [UP]   | []                  | Add documentation       |   [D]  | 1    | 21-Jan |
| [VIEW] | [UP]   | [.VIEWER]           | Make stackable          |   [P]  | 2    | 18-Jan |
| [VIEW] | [UP]   | [.VIEWER]           | Add analytics tools     |   [W]  |      |        |
| [VIEW] | [UP]   | [.SHOW]             | Make interactive        |   [P]  | 1    | 19-Jan |
| [SRC]  | [UP]   | [.FEXC]             | Add varargin construct  |   [P]  | 1    | 21-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | time for constructor    |   [P]  | 2    | 19-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | nan for constructor     |   [P]  | 1    | 18-Jan |
| [SRC]  | [BUG]  | [.FEXC]             | cell input option       |   [P]  | 1    | 18-Jan |
| [SRC]  | [UP]   | [.FEXC]             | design importer         |   [P]  | 1    | 22-Jan |
| [SRC]  | [BUG]  | [.FEXPORT]          | export to cvs option    |   [W]  | 1    | 18-Jan |
| [SRC]  | [BUG]  | [.DESCRIPTIVES]     | bug in derive stats     |   [P]  | 2    | 20-Jan |
| [SRC]  | [UP]   | [.GETMATRIX]        | matrix for regression   |   [W]  |      |        |
| [SRC]  | [UP]   | [.DERIVESENTIMENTS] | asym 3-pram version     |   [W]  |      |        |
| [OS]   | [UP]   | [FEX_FACERPROC]     | upgrade cpp for Linux   |   [W]  |      |        |
| [OS]   | [UP]   | []                  | .bashrc related issue   |   [P]  | 1    | 18-Jan |
| [OS]   | [BUG]  | [FEXW_SEARCHG]      | "find" issue on Windows |   [P]  | 1    | 18-Jan |


Jan 25 - Jan 31
---------------

| Scope  | Type   | **fexc** method     | Description             | Status | Num  | Date   | 
| ------ | ------ | ------------------- | ----------------------- | ------ | ---- | ------ |
| [SRC]  | [UP]   | [.NORMALIZE]        | Combine with SETBASLINE |   [P]  | 1    | 26-Jan |



List of planned updates for this period -- 

* Design and get matrix;
* Statistical methods^{1,2};
* Fit a response -- plot of response;

* Add catch path in importer;
* Add demographic info;
* Add summary method;

* Bug with fexc viewer overlay;
* Add saving files part;
* Add selct file overlay viewer;
* Prevent overlay from creating a movie;
* Add preproc from the viewer;

^{1} Rregression, classification, sparse solution and cross validation^{1}.
^{2} Decide for the stats output.


Feb 1 - Feb 7
---------------

