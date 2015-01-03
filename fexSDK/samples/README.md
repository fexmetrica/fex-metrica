
FexMetrica Examples Folder
===========

This folder contains an examplification of some of the tools from **fex-metrica**.


===========
Files and Design Description
===========

The example works on a simple dataset with two videos in the directory [data](data). This directory contains two short videos:

* [video_001.mp4](data/video_001.mp4);
* [video_002.mp4](data/video_002.mp4).

Additionally, the directory contains three files per each video:

1. [time_video_001.txt](data/time_video_001.txt);
2. [facet_video_001.txt](data/facet_video_001.json).
3. [data_video_001.txt](data/design_video_001.txt);


The first file contains a timestamp for each of the frames acquired for [video_001.mp4](data/video_001.mp4). Note that this is useful when videos are not collected with a constant frame-rate, such as those used here. The file named [facet_video_001.txt](data/facet_video_001.json) is a .json file generated using the [Emotient SDK](http://www.emotient.com), and contains the timeseries of facial expressions used for the analysis.

The last file, [data_video_001.txt](data/design_video_001.txt), comprises the information about the task perfomed during video reocording.


| SID | Run | Trial | Stage | Expression | Action | Time | Condition | Joy | Duration |Onset
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---
| 101 | 1 | 1 | 1 | 0 | A | 1420259850.28 | 30.0 | 1.0 | 1.30049140542 | 1.98848602129
| 101 | 1 | 1 | 2 | 1 | A | 1420259851.02 | 30.0 | 1.0 | 1.30049140542 | 1.98848602129


**SID** indicates subject identification number;
**Run** indicates the video number;
**Trial** indicates the trial in from the task (there are 10 trials per video);
**Stage** indicates the stage within each trial from 1 to 3. 