
FexMetrica Examples Folder
===========

This folder contains an examplification of some of the tools from **fex-metrica**.

===========
Design Description
===========


We used an artificial dataset from a single participant who played the Ultimatum Game for 100 trials. The participant played the role of the "Responder," and saw offers of $10:$90, $20:$80, $30:$70, $40:$60, $50:$50 (10 trial per each video).

In Each trial the participant sees the following:


       Fixation    Offer     Decision
       -------    -------    ------- 
      |       |  |       |  |       |
      |   +   |  |  $10  |  |  A/R? |
      |       |  |       |  |       |
       -------    -------    -------
        4 sec      6 sec     t<6 sec
 

The participant is asked to make specific expressions during the "Offer" window. In particular, the data was set up in such a way that:

1. The expression of happines is positively correlated with the ammount offered;
2. The expression of disgust is negatively correlated with teh amount offerd.


===========
List of Files
===========

The example works on a simple dataset with two videos in the directory [data](data). This directory contains two short videos:

* [video_001.mp4](data/video_001.mp4);
* [video_002.mp4](data/video_002.mp4).

Additionally, the directory contains three files per each video:

1. [time_video_001.txt](data/time_video_001.txt);
2. [facet_video_001.txt](data/facet_video_001.json).
3. [data_video_001.txt](data/design_video_001.txt);


The first file contains a timestamp for each of the frames acquired for [video_001.mp4](data/video_001.mp4). Note that this is useful when videos are not collected with a constant frame-rate, such as those used here. The file named [facet_video_001.txt](data/facet_video_001.json) is a .json file generated using the [Emotient SDK](http://www.emotient.com), and contains the timeseries of facial expressions used for the analysis.

The last file, [data_video_001.txt](data/design_video_001.txt), comprises the information about the task perfomed during video reocording. The file contains the following variables:

| Varable Name | Description |
| --- | --- |
| **SID** | Subject identification numbe |
| **Run** | Video number |
| **Trial** | 1-10 trial number per video |
| **Stage** | 1-3 stage id per trial |
| **Expression** | Participant is asked to make an expression |
| **Action** | Particopant's Action (A or R) |
| **Time** | Time stamp for the row |
| **Condition** | 10,20,...,50 indicates condition |
| **Joy** | Type of facial expression requested |
| **Duration** | Duration for facial expression |
| **Onset** | Onset of facial expression |
