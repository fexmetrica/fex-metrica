
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


===========
Analysis
===========


===========
Dataset Construction
===========

The induction method works as follow. For each "Offer" window, the participant is asked to make an expression of disgust or happiness, based on this distribution:

| Offer   |  H    |  D |
| ------- | ----- | ----- |
| $10:$90 |  0.1  |  0.9 |
| $20:$80 |  0.3  |  0.7 |
| $30:$70 |  0.5  |  0.5 |
| $40:$60 |  0.7  |  0.3 |
| $50:$50 |  0.9  |  0.1 |

Additionally, within each level (Happiness, or Disgust), we sampled from the following normal distribution for the duration (in seconds) of the expression produced:

|Offer   |      H       |      D       |
|------- |  ----------- |  ----------- |
|$10:$90 |  N(3.0,0.25) |  N(0.5,0.25) |
|$10:$90 |  N(2.0,0.25) |  N(0.5,0.25) |
|$10:$90 |  N(1.0,0.25) |  N(1.0,0.25) |
|$10:$90 |  N(0.5,0.25) |  N(2.0,0.25) |
|$10:$90 |  N(0.5,0.25) |  N(3.0,0.25) |


All distribution were truncated, s.t.:

1. if t<0.0 sec, t = 0;
2. if t>6.0 sec, t = 6;

Finally, the onset of the emotion was sampled from an uniformal distribution between 0.00 and 2.0 seconds from "Offer" window onset. This is the code used to construct the stimuli set:

```Matlab

% Distribution over emotions
P  = linspace(.1,.9,5);
% Distribution over duration
mu = [.5,.5,1:3]; mu = [mu', fliplr(mu)'];
% Stimuli matrix
Stim = [];
% loop over offers
for i = 1:5
    nh = binornd(20,P(i)); nd = 20 - nh;
    % Set Durations;
    H = normrnd(mu(i,1),0.25,nh,1);
    D = normrnd(mu(i,2),0.25,nd,1);
    temp = [repmat(i*10,[20,1]),...          % Offer
          cat(1,ones(nh,1),zeros(nd,1)),...  % Emotion type (1 = happiness)
          cat(1,H,D)];                       % Durations
    Stim = cat(1,Stim,temp); 
end
% Force bounds on duration: [0.00, 6.00]
Stim(Stim(:,3) < 0) = 0;
Stim(Stim(:,3) > 6) = 6;
% Add delay in sec for emo onset    
Stim = cat(2,Stim,rand(100,1)*2);
Stim = mat2dataset(Stim,'VarNames',{'offer','happiness','duration','onset'});
export(Stim,'file','stimuli_set.txt','Delimiter','\t')

```
