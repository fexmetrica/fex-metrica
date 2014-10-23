%% Example preprocessing using fex-metrica
%
%
% This scriprt describes some of the steps for preprocessing facial
% expression timeseries computed using the system from Emotient Inc.
%
% There isn't a "canonical" way to run these analyses; however, facial
% expression timseries bear some resemblance with other timeseries analyzed
% in neuroscience; therfore we can use aspects of the preprocessing
% pipeline from the analysis of fMRI data and electrophysiology data.
% Specifically, we combined a set of algorithms from these fields into the
% "fex-metrica" toolbox. This script shows how to use these tools.
%
% In the following, we analyze data from one participant. The original
% video (not included), was preprocessed using the Emotient Inc., SDK (-v
% 3.2). Information on the dataset are presented in section (1.0). Section
% (1.1)-(1.4) show postprocessing steps. Section (2) exemplifies some
% features extraction procedure, and how to export a matrix suited for
% regression or classification. Finally, section (3) shows how to display
% the results using fexView.
%
% ________________________________________________________
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University of
% California, San Diego.
%
% Contact information: frossi@ucsd.edu
%
% 
% Version: 10/23/2014

%% (1.0) Dataset description
%
%
% We used an artificial dataset (see Appendix A) from a single participant
% who played the Ultimatum Game for 100 trials. The participant played the
% role of the "Responder," and saw offers of $10:$90, $20:$80, $30:$70,
% $40:$60, $50:$50 (20 times each, in random order. Only 75 trialas
% included).
%
% In Each trial the participant sees the following:
%
%
%       Fixation    Offer     Decision
%       -------    -------    ------- 
%      |       |  |       |  |       |
%      |   +   |  |  $10  |  |  A/R? |
%      |       |  |       |  |       |
%       -------    -------    -------
%        4 sec      6 sec     t<6 sec
% 
%
% We asked the participant to make specific expressions during the "Offer"
% window. In particular, the data was set up in such a way that:
%
%   (1) The expression of happines is positively correlated with the
%       ammount offered;
%   (2) The expression of disgust is negatively correlated with teh amount
%       offerd.
%
% See the "Artificial data constructuion" section below for more information.
%
% The video was collected at an approximate rate of 15 frames per second,
% and it was processed using the Emotient SDK (version 3.2).
%
% -------------------------------------------------------------------------

% Add the FexMetrica Toolbox
addpath(genpath('~/Documents/code/GitHub/fex-metrica/1.0.1/'))





%% (1.1) Preprocessing: False Positive
%% (1.2) Preprocessing: Interpolation
%% (1.3) Preprocessing: Baseline Normalization (?)
%% (1.4) Preprocessing: Filtering


%% (2.1) Wavelet features extraction
%% (2.2) Window Selection
%% (2.3) Export data


%% (3.1) Statistical testing
%% (3.2) Classification


%% (4.1) Display Results





%% Appendix A: Data Construction Details and Code
%
% **Artificial data constructuion -----------------------------------------
%
% The induction method works as follow. For each "Offer" window, the
% participant is asked to make an expression of disgust or happiness, based
% on this distribution:
%
%        Offer     H      D
%       -------  -----  -----
%       $10:$90   0.1    0.9
%       $20:$80   0.3    0.7
%       $30:$70   0.5    0.5
%       $40:$60   0.7    0.3
%       $50:$50   0.9    0.1
%
% Additionally, within each level (Happiness, or Disgust), we sampled from
% the following normal distribution for the duration (in seconds) of the
% expression produced:
%
%        Offer         H             D
%       -------   -----------   -----------
%       $10:$90   N(3.0,0.25)   N(0.5,0.25)
%       $10:$90   N(2.0,0.25)   N(0.5,0.25)
%       $10:$90   N(1.0,0.25)   N(1.0,0.25)
%       $10:$90   N(0.5,0.25)   N(2.0,0.25)
%       $10:$90   N(0.5,0.25)   N(3.0,0.25)
%
% All distribution were truncated, s.t.:
%   
%      >> if t<0.0 sec, t = 0;
%      >> if t>6.0 sec, t = 6;
%
% Finally, the onset of the emotion was sampled from an uniformal
% distribution between 0.00 and 2.0 seconds from "Offer" window onset. 
%
% This is the code used to construct the stimuli set:
% 
% -----------------------------------------------------------| Code Starts
% % Distribution over emotions
% P  = linspace(.1,.9,5);
% % Distribution over duration
% mu = [.5,.5,1:3]; mu = [mu', fliplr(mu)'];
% % Stimuli matrix
% Stim = [];
% % loop over offers
% for i = 1:5
%     % Number of Happy and Disgust trials
%     nh = binornd(20,P(i)); nd = 20 - nh;
%     
%     % Set Durations;
%     H = normrnd(mu(i,1),0.25,nh,1);
%     D = normrnd(mu(i,2),0.25,nd,1);
%     
%     % Combine data
%     temp = [repmat(i*10,[20,1]),...         % Offer
%         cat(1,ones(nh,1),zeros(nd,1)),...   % Emotion type (1 = happiness)
%         cat(1,H,D)];                        % Durations
%     
%     % Experiment data
%     Stim = cat(1,Stim,temp); 
% end
% % Force bounds on duration: [0.00, 6.00]
% Stim(Stim(:,3) < 0) = 0;
% Stim(Stim(:,3) > 6) = 6;
% % Add delay in sec for emo onset    
% Stim = cat(2,Stim,rand(100,1)*2);
% 
% Stim = mat2dataset(Stim,'VarNames',{'offer','happiness','duration','onset'});
% export(Stim,'file','stimuli_set.txt','Delimiter','\t')
% -----------------------------------------------------------| Code ends
