
FexMetrica Examples Folder
===========

This folder contains an examplification of some of the tools from **fex-metrica**. The code can be run from the file [fexemple1.m](fexemple1.m).


File Description
===========

This directory is organized as follow:

    
    data/                   directory for data
        contempt.csv        csv file for contempt movie
        contempt.json       js file for contempt movie
        contempt.mov        movie with contempt expression
        disgust.csv         csv file for disgust movie
        disgust.json        js file for disgust movie
        disgust.mov         movie with disgust expression
        smile.csv           csv file for smile movie
        smile.json          js file for smile movie
        smile.mov           movie with smile expression
    fexemple1.m             main script for example
    README.md               this file        
    


Generate a FEXC object
===========

A **fexc** object is the main class used for the analysis, and can be generated in several ways. The easiest way is to use the "ui" option. The UI let you select:

1. Video files;
2. Files with the facial expressions timeseries;
3. Outout directory.


```Matlab
fex_init;
fexobj = fexc('ui');
```

Note that Calling FEX_INIT adds **fex-metrica** to Matlab search path.

If you have the movies, but not the files with facial expressions, the UI gives you the option to analyze the data by pressing the FACET button. For this option to work, you need to have a local copy of the Facet SDK installed. Additionallty, you need to run [fexinstall](../../fexinstall.m).


![alt text](https://github.com/filipporss/fex-metrica/blob/master/fexSDK/samples/docs/constimg.png "Fexc Constructor UI")

===========

An alternative way to create a **fexc** object is to use "varargin" input structure:

```Matlab
vlist  = fexwsearchg(); % Select the .mov files with the ui;
dlist  = fexwsearchg(); % Select either .json or .csv files with the ui.
fexobj = fexc('video',vlist,'data',dlist,'outdir',[pwd '/output']);
```

The function **fexwsearchg** opens a ui that allows you to select a set of files. If you enter the files manually, they can be either a char object or a cell.


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

$S_{f} = argmax(P_{f},N_{f}*,\xi)$

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


**Note** that visualization methods require indices (this limitation will be removed).


Save Files and Images
===========

...




