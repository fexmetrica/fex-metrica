classdef fexckf < handle
% 
% FEXCKF - Canonical response function estimator.
%
%   hrf = FEXCKF();
%   hrf = FEXCKF(data);
%   hrf = FEXCKF(data,ArgName,ArgVal,...)
%
%   When called without any imput argument, the resulting FEXCKF object is
%   empty. Values for properties can be added using SET, or data can be
%   simulated using the method SIMULATE.
%  
%   DATA is a table with three variables:
%       time    - vector with time for each of the timeseries;
%       group   - vector with indices for grouping variable;
%       varname - name of the time series channel fit.     
%
%   Example:
%       % Simulate data and fit model.
%       hrf = fexckf().simulate;
%       hrf.estimate();
%
%   See also FEXC, NLMEFITSA
%
%   Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
%   University of California, San Diego. email: frossi@ucsd.edu
%
%   VERSION: 1.0.1 05-Nov-2015.
    
properties
% NAME - string with name of the chanel used. This is the variable name
% from the data imput.
name 
% DATA - Table or matrix with 'Group','time' and emotion scores.
%
% See also FEXC.
data
% MODEL: Table with model parameters and description. This includes initial
% values for the parameters and indicator for random effects.
model
% ====== these next one will be private

% CKF - Functional shape for the canonical response function.
ckf
% OPTIMOPT - Optimization option
optimopt
% SIMSET - simulation options
simset
% b0
b0
end

methods
function self = fexckf(varargin)
% 
% FEXCKF - Initialization function.
%
%   hrf = FEXCKF();
%   hrf = FEXCKF(data);
%   hrf = FEXCKF(data,ArgName,ArgVal,...)
%
% See also INIT, SET_UP.

% Initialize and read imput argument
% ====================================
self.init();
if ~isempty(varargin)
    self = self.set_up(varargin(:));
end


end
% ========================================================================  

function self = simulate(self,varargin)
%
% SIMULATE -- generate a sample dataset and estimate.
%
% Note that data is overwriten when you call simulate. Parameters for the
% simulation are:
%
% t
% n
% g
% par
% vcm
% eta
% eps

% Time vector
% ==========================
t = linspace(0,self.simset.t(1),self.simset.t(2))';

% Model parameters & random effects
% ==========================
bfix = repmat(self.simset.par,[self.simset.g,1]);
% FIXME: Random effect, so that the boundaries conditions are maintained
bref   = abs(mvnrnd(bfix,self.simset.eta,self.simset.g));
self.simset.bref = bref;
% self.simparam();
% bref = self.simset.bref;

% i.i.d. error values
% ==========================
N   = self.simset.n*self.simset.g;
eps = normrnd(self.simset.eps(1),self.simset.eps(2),self.simset.t(2),N);


% Loop for trial simulation
% ===========================
Y = []; k = 1; SD = [];
for i = 1:self.simset.g
    sd = [];
    s = repmat(i,[length(t),1]);
    for j = 1:self.simset.n
        sy  = self.ckf(bref(i,:),t) + eps(:,k);
        sy = sy./sum(sy);
        sd  = cat(1,sd,sy'); 
        Y   = cat(1,Y,[t,s,sy]);
        k   = k + 1;        
    end
    SD = cat(1,SD,mean(sd));
end

% Overwrite data information
% ============================
self.data = array2table(Y,'VariableNames',{'time','group','SimVar'});
self.name = 'SimVar';
self.simset.sd = SD;



end
    
% ========================================================================  

function self = estimate(self,varargin)
%
% ESTIMATE -- 
bnds = self.optimopt.bounds;
fprintf('Finding initial parameters ....\n');
self.b0 = fmincon(@self.rmseval,self.model.Parameters',[],[],[],[],bnds(1,:),bnds(2,:));
% FIXME: 
% param 1 shoukd be looped -- 0 - 1
% scale (p3 and p5) should be constraint;
% RP is shape1, shape2, scale12.
% Kill trailing zeros (??) 

fprintf('Multilevel estimation ... \n');
opt = statset('Display','iter');
tic;
% FIXME: too slow, and won't work on real data
[beta,pre,stats,b] = nlmefitsa(self.data.time,self.data.(self.name),self.data.group,[],@self.ckfun,self.b0,...
                     'REParamsSelect',[2,4],'Options',opt,'LogLikMethod','is', 'ComputeStdErrors', true, 'OptimFun', 'fminunc');
toc
fprintf('Done!\n');

    


end 
% ========================================================================  

function h = show1(self)
%
% SHOW1 - Show random effects -- averaged by simulation (??)

if isempty(self.simset.sd)
    error('No data ... ');
end

% Set up figure
% ==================================
h = figure('units','pixels','Position',[0 0 600 300],'Color',[0,0,0], 'Visible', 'on');
hold on, box off, axis tight
plot(self.simset.sd','LineWidth',2)
set(gca,'Color',[0,0,0],'XColor',[0,0,0],'YColor',[0,0,0],'LineWidth',2,'fontsize',14,'fontname','Times');

xx = get(gca,'XTick'); 
tx = xx./(self.simset.t(2)/self.simset.t(1));
set(gca,'XTickLabel',tx);
    
    
    
    
end



% ========================================================================  
end


% ========================================================================  
% ========================================================================  

methods(Access=private)

function self = init(self) 
%
% INIT - Internal helper function for object initialization.


% Initialize general information
% =================================
self.name = 'Var1';
self.data = [];

% Initialize kernel
% =================================
self.ckf = @(b,x)(b(1)*(gampdf(x(:),max(b(2),.001),max(b(3),.001)) - (1-b(1))*gampdf(x(:),max(b(4),0.001),max(b(5),0.001))))./...
    sum(b(1)*(gampdf(x(:),max(b(2),.001),max(b(3),.001)) - (1-b(1))*gampdf(x(:),max(b(4),0.001),max(b(5),0.001))));

% Initialize parameters
% =================================
bnot = [0.5,12,0.15,10,0.15; zeros(1,5); zeros(1,5)];
self.model = array2table(bnot','VariableNames',{'Parameters','StdError','isRandom'},'RowNames',{'c','k1','th1','k2','th2'});
desc = {'Gammas weights [0,1]';'Shape G1';'Scale G1';'Shape G2';'Scale G2'};
self.model.description = desc;

% Initialize optimization option
% =================================
bnds = [0,.001,.001,.001,.001; 1,100,100,100,100];
self.optimopt = struct('norm',1,'interp','ppca','cluster',0,'bounds',bnds);
    
% Initialize simulation parameters
% =================================
self.simset = struct('t',[6,150],'n',50,'g',5,'par',[0.5,12,0.15,10,0.15],...
              'eta',1*eye(5),'eps',[0,.01],'bref',[],'sd',[]);
self.simset.eta(1,1) = 0;
self.simset.eta(3,3) = 0;
self.simset.eta(5,5) = 0;

  
end
% ========================================================================  
    
function self = set_up(self,args)
%
% SET_UP - Internal helper function for reading parameters

if isa(args{1},'table') && size(args{1},2) == 3
    self.name = setdiff(lower(args{1}.Properties.VariableNames),{'time','group'});
    self.X = args{1};
else
    error('First argument is a table with variables: group, time, and variable name');
end
     



end
% ========================================================================  
    
function self = simparam(self)
%
% SIMPARAM - Helper function for parameters simulation

% Force column vectors
m = self.simset.par(:);
s = diag(self.simset.eta); s = s(:);

% Calculate the covariance structure
sd  = repmat(s',numel(s), 1);
sa  = repmat(s, 1 ,numel(s));
vcm = log(eye(length(m)).* sqrt(exp(sd.^2)-1).*sqrt(exp(sa.^2)-1) + 1 );

% The Simulation
self.simset.bref = exp(mvnrnd(m,vcm,self.simset.g));


end
% ========================================================================  

function yh = ckfun(self,b,x)
%
% CKFUN - Prediction handle for estimation

% FIXME b(1):
if b(1) < 0
    b(1) = 0;
elseif b(1) > 1;
    b(1) = 1;
end
    
yh = self.ckf(b,x);
yh(isnan(yh)) = 0;

end


% ========================================================================  

function ll = rmseval(self,param)
%
% MSQ_VAL - mean squared error computation

ll = mean(sqrt((self.ckf(param,self.data.time) - self.data.(self.name)).^2));
    
    
end
    
    
% ========================================================================      
end






end

