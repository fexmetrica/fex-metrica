classdef fexgrabc
% FEXGRABC - Object use for FEXC.GRAB method.
%
% FEXCGRAB specifies the procedures to extract segments of interest from
% the FEXC timeseries data. 
%
% 
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 19-Nov-2015.

properties
% FEX - FEXC object to whicg FEXGREAB procedures is applied.
%
% See also FEXC, GRAB
fex
% X - Table with data. 'SID' variable (i.e. subject identifier) is
% required. Each row is assumed to be a trial. One of the variables must
% contain timestamps.
x;
% TIME - Name of the variable with the timestamp. This is used to identify
% the onset of the segment you are going to select.
time = 'time';
% DURATION - length of the segment from each onset timestamp, expressed in
% seconds.
duration = 6;
% FORMAT - string in {'long','short'}, where 'long' return the enrire
% timeseries segment, while 'short' collapse the segment into one number
% per channel and trial (i.e. row).
format = 'short';
% MODEL - a structure which specifies how the short format is obrained.
% Fields are:
% 
% * name: string between:
%    1) mean;
%    2) median;
%    3) max;
%    4) sum;
%    5) gm (default).
% * param: a vector with [support,std] - this only applies to 'gm' method.
% support is expressed in seconds.
%
% 
model = struct('name','gm','param',[2,.1],'fps',15,'kernel',[]);
% CHANNELS - a string or a cell which is feed directly to GET.
%
% See also FEXC.GET.
channels = 'emotions';

end

% ==================================
% ==================================
methods
function self = fexgrabc(varargin)
% 
% FEXGRABC - constructor function.

% FIXME: Add safety checks:
% CHECK MODEL SPECIFICATION.

if ~isempty(varargin)
    self.x = varargin{1};
    try
        for k = fieldnames(varargin{2})'
            self.(k{1}) = varargin{2}.(k{1});
        end
    catch
        for k = 2:2:length(varargin)
            self.(lower(varargin{k})) = varargin{k+1};
        end
    end
end

end

% *************************************************************************

function self = set(self,varargin)
%
% SET - ...

for k = 1:2:length(varargin)
    self.(lower(varargin{k})) = varargin{k+1};
end

end
    
% *************************************************************************

function Y = grab(self)
%
% GRAB - Main grab function.


% SAFETY checks on grab
% ==================================
if isempty(self.fex)
    error('You need to specify a FEXC object.');
elseif length(unique(self.x.SID)) ~= length(self.fex)
    error('Grab object and FEXC have different dimensions.');
end

% get FPS information & hdr
% ===================================
fs  = self.fex.summary.Fps;
self.model.fps = fs(1);
n  = round(fs(1)*self.duration -1);
hdr = self.fex(1).get(self.channels).Properties.VarNames;

if strcmp(self.model.name,'gm')
    self.model.kernel = normpdf(linspace(-2.5,2.5,self.model.param(1)*fs(1)),0,self.model.param(2))';
    self.model.kernel = self.model.kernel./sum(self.model.kernel);
end

% MAIN LOOP over Trials and participants
% ===================================
Y = zeros(round(size(self.x,1)*(n+1)),round(length(hdr)+2));
q = 1;
for k = 1:length(self.fex)
    clc; fprintf('Object %d of %d ... \n',k,length(self.fex));
    t1 = table2array(self.x(self.x.SID == k,{self.time}));
    t2 = self.fex(k).time.TimeStamps;
    y  = self.fex(k).get(self.channels,'double');
    % n  = fs(k)*self.duration -1;
    for j = 1:length(t1)
        [~,id] = min(abs(t2 - t1(j)));
        Y(q:q+n,1:2) = repmat([k,j],[n+1,1]);
        temp = y(id:min(id+n,size(y,1)),:);
        Y(q:q+length(temp)-1,3:end) = temp;
        q = q+n+1;
    end
end
     
% Apply matrix transformation & convert to table
% ===================================
Y = array2table(self.makemodel(Y),'VariableNames',{'SID','TID',hdr{:}});

    
end
   
    


% *************************************************************************

end
       

% ==================================
% ==================================

methods(Access=private)
% UPDATE -     
% MAKEMODEL - 
function self = update(self,argName,argVal)
% 
% UPDATE - Helper for internal update.

if ismember(fieldnames(self),lower(argName));
    self.(lower(argName)) = argVal;
end

% for k = 1:2:length(varargin)
%     if ismember(fieldnames(self),lower(varargin{k}));
%         self.(varargin{k}) = varargin{k+1};
%     end
% end
 
end
    
% *************************************************************************
function Y = makemodel(self,F)
% 
% MAKEMODEL - Helper for applying model transofrmation 

% Nothing to do when FORMAT is set to 'long'
% ==================================
if strcmpi(self.format,'long')
    Y = F;
    return
end

% Format Y: frames * trials * features
% ===================================
Y = [];
for k = unique(F(:,1))'
    YY = F(F(:,1) == k,:);
    n = size(YY(YY(:,2) == 1),1);
    t = max(YY(:,2));
    f = size(YY,2) - 2;
    YY = reshape(YY(:,3:end),n,t,f);
    
% Interprete Model string for 'short' format
% ===================================
switch self.model.name
    case 'gm'
        for j = 1:size(YY,3)
            YY(:,:,j) = convn(YY(:,:,j),self.model.kernel,'same');
        end
        % YY = reshape(max(YY),n*t,f);
        YY = squeeze(max(YY));
    case {'mean','median','std','var','sum'}
        fun = eval(sprintf('@nan%s',self.model.name));
        YY = squeeze(fun(YY));
        % YY = reshape(fun(YY),n*t,f);
    case {'min','max'}
        fun = eval(sprintf('@%s',self.model.name));
        YY = squeeze(fun(YY));
        % YY = reshape(fun(YY),n*t,f);
    otherwise
        error('Unrecognized short method');
end

Y = cat(1,Y,[k*ones(size(YY,1),1),(1:size(YY,1))',YY]);
end
  
% FIXME: TEST THAT THIS WORKS AS PLANNED
% ===================================
% Q = [];
% ind = unique(F(:,1:2),'rows');
% for k = 1:300 %size(ind,1)
%     Q = cat(1,Q,mean(F(ismember(F(:,1:2),ind(k,:),'rows'),:)));
% end
% test = sum(Q == Y,2);

end
    
    
end
% ==================================
% ==================================



end

