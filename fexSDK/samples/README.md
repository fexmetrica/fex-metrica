===========
WARNING
===========

The facial expression data used in this example were computed using FACET SDK (v4.0.5) -- namely the SDK associated with [Emotient Analytics](http://www.emotient.com/products/emotient-analytics/). The current online version of the software is 4.1.1. There are few differences of in the output, notably:

* The online version comprises AU 43 (Eyes Closed);
* The current online version does not output facial landmarks;

Due to the lack of landmarks in the output from Emotient Analytics, some of the viewer options currently do not work. This will be fixed soon. For the sake of this example, use the "_facet.csv". For comparison, I included the output of the online version (i.e. "data/contempt_ea.csv").

===========
Example
===========

This folder contains an example of some of the tools from **fex-metrica**. The code can be run from the file [exemple1.m](exemple1.m). I am assuming that **fex-metrica** was already installed (if not, follow the direction [here](../../README.md).

**NOTE**: The facial expression processing output was extracted using FacetSDK -- i.e. the SDK version of [Emotient Analytics](http://www.emotient.com/products/emotient-analytics/). 


Dataset
===========

There are sets of files in the [data folder](data), one for each of these videos:

* contempt;
* disgust;
* smile.mov. 

Each video is associated with three files: .mov, facet.csv, and ea.csv. The "facet.csv" files contain the output from version 4.0.5 of FACET SDK. The "ea.csv" files contain the output from version 4.1.1 from [Emotient Analytic Website](http://www.emotient.com/products/emotient-analytics/).  


Signal Description
=============

This section is adapted from [Emotient Documentation](https://support.emotient.com/customer/portal/articles/1759399-how-to-interpret-the-csv-files).


The files that end with "facet.csv", which were computed with SDK v4.0.5 contains the following variable types:


| Type              | Number | Score Description                         |
| ----------------- | ------ | ----------------------------------------- |
| Frame size        |   2    | pixels (rows and columns)                 |
| Time Information  |   1    | Frame time of acquisition (sec.)          |
| Face box          |   4    | hight, width, x, y (from top-left)        |
| Gender            |   1    | evidence (positive = male)                |
| Action Units      |  19    | evidence (positive = present)             |
| Basic Emotions    |   7    | evidence (positive = present)             |
| Advanced Emotions |   7    | evidence (positive = present)             |
| Overal sentiments |   3    | evidence (positive = present)             |
| Landmarks (x,y)   |  16    | pixel count from  top-left                |
| Pose              |   3    | degrees from frontal                      |
| Track             |   1    | scalar for face identified (-1 = no face) |

===============

**Evidence**: These scores indicate the ration in log_{10} for a feature being present versus absent, that is: LikeRatio(f_present/f_absent).

===============

**Action Units**: These features (AU) were described by Paul Eckman in the Facial Action Coding System, which is a taxonomy of human movements. There are 44 AUs. The AUs included in the "facet.csv" files are: AU1, AU2, AU4-AU7, AU9-AU10, AU12, AU14, AU15, AU17, AU18, AU20, AU23-AU26, AU28. Image and examples for AUs can be find [here](http://www.cs.cmu.edu/~face/facs.htm).

===============

**Emotions**: Emotions can be described as combinations of AUs. There are multiple combinations of AUs that describe specific emotions. One example from EMFACS-7 is:


| Emotion	 |  Action Units    |
| ---------- | ---------------- |
| Happiness	 |  6+12            |
| Sadness	 |  1+4+15          |
| Surprise	 |  1+2+5B+26       |
| Fear	     |  1+2+4+5+7+20+26 |
| Anger	     |  4+5+7+23        |
| Disgust	 |  9+15+16         |
| Contempt	 |  R12A+R14A       |

===============

**Overall Sentiments**: Evidence of positive, negative, and neutral sentiments. 

===============

**Pose**: There are three pose features, all indicating degrees from frontal in a specific plan:

* Roll: in-plane-rotation, with ositive values indicate counter clockwise;
* Pitch: up & down, with positive values indicating down;
* Yaw: side-to-side rotation, with positive indicating turning toward the right side of the image. 

================

**Tracks**: The track score is a scalar, which indicate each of the face tracked. Importantly, track does not imply facial identy, rather it means that the same face was tracked over time. Therefore, ther can be multiple track for the same person. The csv files raws are ordered by track rather than by timestamps, so a file would tipically look like:


| Track | TimeStamp |
| ----- | --------- |
|  0    |  0.06     |
|  0    |  0.20     |
|  0    |   ...     |
|  1    |  0.06     |  
|  1    |  0.27     |
| ...   |  ...      |
| ...   |  ...      |
|  K    |  2.00     |
| ...   |  ...      |
| -1    |  0.13     |
| -1    |  ...      |
 
The value -1 indicates that no face was found in the frame.

===========
FexMetrica Postprocessing
===========


**Fex-metrica** is meant to be used after you download the data from Emotient Analytics website or, in this case, an SDK -- if you have the SDK, you can call it from Matlab directly. The postprocessing of the facial expression time series discussed below can be run using this code:

```Matlab
% Use this data
vid = {'data/contempt.mov','data/disgust.mov','data/smile.mov'};
vid = {'data/contempt_facet.csv','data/disgust_facet.csv','data/smile_facet.csv'};

% Construction
fex_init;
fexobj = fexc('video',vid,'data',dat,'outdir',[pwd '/output']);

% False Positive Detection
fexobj.falsepositive('method','position','threshold',3);

% Temporal Processing
fexobj.interpolate('fps',30,'rule',15);
fexobj.temporalfilt('lp',0.5);

% Normalization
fexobj.rectification(-2.5);
fexobj.setbaseline('mean','-global');

% Sentiment Derivation / Constraining
fexobj.derivesentiments(0.25,0);

% Export resulting data
fexobj.fexport;

```

The sections below elaborare on each of the above steps, that is:

* Construction;
* False positive detection;
* Temporal operations;
* Normalization;
* Sentiments derivation;
* Export resulting matrix.

Construct a FEXC object
----------

A **fexc** object is the main class used for the analysis. The constructor requires the movie files and the .csv files. Assuming that you are working from this directory:


```Matlab
% Initialize fex-metrica
fex_init; 

% Construct the object
videos = cellstr(ls('data/*facet.mov'));
data   = cellstr(ls('data/*facet.csv'));

fexobj = fexc('video',{'contempt.mov','disgust.mov','smile.mov'},...
        'data',{'contempt.csv','disgust.csv','smile.csv'},'outdir',...
        [pwd '/output']);

```

=========

Alternatively, you can use the "ui" option and select the data using the UI:


```Matlab
fex_init;
fexobj = fexc('ui');
```

![alt text](https://github.com/filipporss/fex-metrica/blob/master/fexSDK/samples/docs/constimg.png "Fexc Constructor UI")

The UI let you select:

1. Video files;
2. Files with the facial expressions timeseries;
3. Outout directory.

If you have the movies, but not the files with facial expressions, the UI gives you the option to analyze the data by pressing the FACET button. For this option to work, you need to have a local copy of the Facet SDK installed.


Object Description
=============


Spatial Processing
===========

This section of the code is meant to get rid of outliers, and false positive -- that is, patches of pixels that are recognized as a face, but that do not containa  face. One conservative options is to do it in 2 steps:

1. Use face-box position to exclude frames;
2. Use coregistration error.

```Matlab
fexobj.falsepositive('method','position','threshold',2);
fexobj.coregister('fp',true,'threshold',2);
```

**Note** that when you call a method from a FEXC object which contain data from multiple videos, the method is applied to all videos, unless you use indices (e.g. >> fexobj(1).coregister).

The method FALSEPOSITIVE with 'method' set to 'position' finds multi-variate outliers of face location in a frame. The argument 'threshold' let you specify how many standard deviations away from the mean an outlier is. Note that this approach is advised if and only if the person in a video don't move around too much.

The method COREGISTER uses procrustes analysis to register a face box and the associated face landmarks to a standardized face in the current video. This procedure can be used to identify "false positive." In particular, the sum of square error from the coregistration is z-scored, and then frames with error larger than the specified threshold are discarded.

An additional correction can be done with the method **motioncorrect**, which uses pose information (pitch, roll and yaw) to regress out changes in signal due to motion of the subject in the video. You can run the following code for motion correction:

```Matlab
fexobj.motioncorrect('thrs',0.50,'normalize','-whiten');
```
All FUNCTIONAL features are regressed against the POSE features. The "thrs" argument indicates that only pose componets with |r| > 0.50 will be used in the regression model. The 'normalization' argument set to '-whiten' makes the pose variables independent and zero-mean.


Temporal Processing
===========

Temporal processing of facial expression data include several methods:

**interpolate** - Interpolate timeseries & manages NaNs.  
**downsample** - Reduced functional sampling rate to desired fps.
**smooth** - Smooth time series using standard or costume kernel.
**temporalfilt** - Apply low, high, or bandpass filter to FEXC.functional.



```Matlab
    [...]
```

Normalization
===========


These methods normalize the timeseries. The method SETBASELINE sets a baseline for each timeseries independetly. You can use statistics such as 'mean', 'median', 'q75' (i.e. 75th quantile). The facial expression time series **X** will be set to **X**-*fun*(**X**).

```Matlab
fexobj.setbaseline('mean');
```

You can call SETBASELINE with the flag '-global' that is: 

```Matlab
fexobj.setbaseline('mean','-global');
```

In this case, the statistics selected for normalization (i.e. 'mean') is computed over all videos in the FEXC object. By default, the descriptive statistics is computed video-wise.

==========

The second step in normalization is "rectification," which involve setting all facial expressions values lower than a threshold *t* to *t*:

```Matlab
fexobj.rectification(-1);
```

In this example, the threshold is set to *t=-1*.


Sentiments
===========

The [FACET SDK](http://www.emotient.com) output directly aggreagte scores for positive, negative and neutral sentiments. However, **fex-metrica** uses max-pooling to offer another aggregate measure of positive, negative and neutral sentiments. You can use the method **derivesentiments**, and the output is contained in the property **sentiments**.

```Matlab
fexobj.derivesentiments(0.00);
```

For each frame, the method **derivesentiments** gets a global negative score **N** (the maximum value between anger, contempt, disgust, sadness and fear). Additionally, it also computes a global positive score **P** (frame-wise maximum between joy and surprise). Each frame is then tagged as positive, negative or neutral based on the following formula:

S_{f} = argmax(P_{f},N_{f}*,\xi)

The variable "$\xi$" (set to 0.00 in the example above) is a margin used to define neutral frames. A frame is considered neutral if: max(P_{f},N_{f}) <= $\xi$. Scores for positive and negative frames are set, respectively, to **P**, **N**  or $\xi$, based on which sentiment is more expressed.


Visualization
===========

There are three main visualization methods associated with **fexc** objects:

1. SHOW method: display emotions timeseries and methods;
2. VIEWER method: shows video along with emotion timeseries;
3. VIEWER method with 'overlay' option: shows heat maps of emotions.


Show
----

The SHOW method generates an image with time-series for 7 basic emotions, 2 advanced emotions (frustration and confusion) and sentiments. Note that sentiments are not the naive sentiments classifier chanels; instead they are computed using max-pooling with the DERIVESENTIMENTS method.

```Matlab
fexobj(1).show();
```

Viewer - Video and time series
----

The VIEWER method called without arguments displays the video and associated timeseries. The tools menu item allows you to focus on the face, and add visualize morphological property for the face displaied in each video.


![alt text](https://github.com/filipporss/fex-metrica/blob/master/fexSDK/samples/docs/viewer1.png "Fexc Viewer")


The UI opened by the method VIEWER has several functionality that can be accessed from the "Tools" menu. Additionally, there are short-keys associated with the UI. For a detailed description look at the help menu:

```Matlab
help fexw_streamerui
```

Viewer - Overlay display
----

[...]


Save Files and Images
===========

...




