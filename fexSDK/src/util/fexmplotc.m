classdef fexmplotc
%
% FEXMPLOTC - Plot timeseries class.
    
properties
data = [];
type = 'all'
directory = pwd;
end

    
methods
function self = fexplotc(varargin)
% 
% FEXPLOTC - constructor

fn = {'data','type','directory'};
for i = 1:length(varargin)
    self.(fn{i}) = varargin{i};
end


end


function self = make(self,spec)
%
% MAKE - Generate the images

if ~exist('spec','var')
    spec = self.type;
else
    self.type = spec;
end
    






end

end
 
methods(Access=private)
% format_data
% plot_generation
% save_plots
    
    
    
end


end

