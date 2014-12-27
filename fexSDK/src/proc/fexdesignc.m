classdef fexdesignc
%
% desObj = fexdesignc;
% desObj = fexdesignc(fexobj,design);
% desObj = fexdesignc(fexobj,design,ArgName1,ArgVal1,...);
%
%
% Design object -- this class uses fex objects and data provided by the
% user to create a matrix suitable for classification, regression, and,
% more in general, statistical analysis.
%
%
% *************************************************************************
%
% INITIALIZATION
%
%
%
%
%
% *************************************************************************
%
% METHODS
%
% 1. Methods for design manipulation
% 
% "add": add observations to the design or add variables to the design;
% "remove": remove observations or variables to the design;
% "inspect": show image of the design matrix;
% "table":   make a table from the design;
% "descriptive": compute descriptive and basic stats for the design.
%
% 2. Methods for features generation
%
% "wavelets": generate a banck of complex morelet wavelets to extract
%             features.
% "kernel":   generate a kernel function to convolve the facial expression
%             time-series with. 
% "activation": generate activation features.
% "normalize": normalize the timeseries.
% 
% 3. Method for exporting model
%
% "minit":     initialize model structure;
% "mselect"    select model features;
% "mexport"    export model.
%
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 08/05/14.



    properties
        % data for the design
        data 
        % list of problems
        issues
    end
       
    properties (Access = protected)
        % workigng version of design
        designinit
        % fexObj
        fex
        % space for kernels
        kernelspace
        % space for models
        modelspace
    end


%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%************************************************************************** 
    
    
    methods
        function self = fexdesignc(fexobj,design,varargin)
        %
        % Init function which constructs the class fexdesignc. See the
        % main documentations for detailed instructions.
        %
        % -----------------------------------------------------------------
        
        % Handle arguments in 
        if nargin == 0
            fexobj = fex_lsg;
            design = fex_lsg;
        elseif nargin == 1
            design = fex_lsg;
        end
        
        % Parse the fexobj argument
        if isempty(fexobj)
            fexobj = fex_lsg;
        end
        
        % Parse the design arguent
        if isempty(design)
            design = fex_lsg;
        end
        
        % Handle varargin
        args = sruct('fexID',[],'nhdr',{''},'order','horiz');
        args = parsevararg(args,varargin);
   
        % Import the fexObj
        self.fex = parsefexobj(fexobj);
        
        % Import the Design
        self.designinit = parsedesign(design,args.nhdr,args.fexID);
       
        % Modify design shape
        % ... ... 
        self.data = cell(length(self.designinit),1);
        self.issues    = {};
        for i = 1:length(self.data)
            try
                self.data{i} = convertdesign(i,args.order);
            catch errorID
                warning('Conversion error: %s',errorID.message);
                self.issues = cat(1,self.issues,sprintf('ID %.2d:%s',i,errorID.message));
            end
        end
        
        end
        
% *************************************************************************        
        
        function self = add(self,varargin)
        %
        % -----------------------------------------------------------------        
        % 
        % Add data.
        %
        % -----------------------------------------------------------------        
        %
        
        
        
        
        end

% *************************************************************************        
        
    end
    

%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************     
    
    methods (Access = private)
        
        function args = parsvararg(args,varargs)
        %
        % -----------------------------------------------------------------               
        % 
        % Helper function to parse variable arguments in.
        %
        % -----------------------------------------------------------------
        %  
        nf = field.names(args);
        for i = 1:length(nf);
            [~,ind] = find(strcmp(varargs,nf{i}));
            if ~ isempty(ind)
                args.(nf{i}) = varargs{ind+1};
            end
        end
        
        end
    
% *************************************************************************        
        
        function fexobj = parsefexobj(fexobj)
        %
        % -----------------------------------------------------------------        
        % 
        % Helper function to parse variable fexobj
        %
        % -----------------------------------------------------------------        
        %
        if isa(fexobj,'char')
            fx = load(fexobj);
            nm = fieldnames(fx);
            fexobj = fx.(nm{1});
        elseif isa(fexobj,'cell')
            fext = [];
            for i = 1:lenght(fexobj)
                fx = load(fexobj);
                nm = fieldnames(fx);
                fext = cat(1,fext,fx.(nm{1}));
            end
            fexobj = fext;
        end
        fprintf('Imported fexobj.\n');
        end
        
% *************************************************************************
        
        function designinit = parsfexobj(design,nhdr,fexID)
        %
        %
        % -----------------------------------------------------------------        
        % 
        % Helper function to parse variable design
        %
        % -----------------------------------------------------------------        
        %
        switch class(design)
            case 'cell'
            % "design" is a cell of dataset, filepaths or doubles.   
                if isa(design{1},'dataset')
                % cell of dataset -- 
                    designinit = design;
                elseif isa(design{1},'char')
                % cell of paths -- 
                    designinit = cellfun(@(matd)set(matd,'VarNames',nhdr),design,'UniformOutput',0);
                elseif isa(design{1},'double')
                % cell of matrices --                     
                    designinit = cellfun(@(matd)mat2dataset(matd,'VarNames',nhdr),design,'UniformOutput',0);
                end
            case 'struct'
            % "design" is a structure
                nf  = fieldnames(design);
                ind = sum(ismember(nf,{'data','colheader','textdata'}));
                fld = intersect(nf,{'colheader','textdata'});
                if ind == 0
                    warning('Required fields: ''data'' and ''colheader''.');
                    error('The structure for design was mispecified');
                elseif ind == 2
                    % reset the header.
                    nhdr = design.(fld{1});
                end
                % now handle the .data field
                if isa(design.data,'cell')
                % .data is a cell of doubles or a cell of datasets
                    if isa(design.data{1},'double')
                       designinit = cellfun(@(matd)mat2dataset(matd,'VarNames',nhdr),design.data,'UniformOutput',0);
                    elseif isa(design.data{1},'dataset')
                        designinit = cellfun(@(matd)set(matd,'VarNames',nhdr),design.data,'UniformOutput',0);
                    end                    
                elseif ismember(class(design.data),{'dataset','double'})
                % .data is a dataset or a matrix                    
                    designinit = fununstuck(design.data,fexID,nhdr);
                else
                    error('I wasn''t able to parse the "design" argument.');
                end
            case {'dataset','char','double'};
            % When design is a unique dataset, a path of a double
                if isa(design,'char') 
                    design = dataset('File',design);
                elseif isa(design,'double') 
                    design = mat2dataset(design,'VarNames',nhrd);
                elseif isa(design,'dataset') && ~isempty(nhrd)
                    design = set(design,'VarNames',nhrd);
                end
                designinit = fununstuck(design,fexID,nhdr);
            otherwise
                warning('Coulden''t parse the data for the design.');
                return
        end

        
        end

% *************************************************************************        

        function ustk = fununstuck(X,K,names)
        %    
        % -----------------------------------------------------------------        
        % 
        % Helper function to unstack matrices or datasets.
        %
        % "X" can be either a dataset or a matrix.
        %
        % "K" is the unstuck variable. It can be a string (name of the
        % variable if 'X' is a dataset, or name of the unstacking variables
        % in 'names' when 'X' is a matrix). Alternatively, K can be an
        % integer: namely the number of the column used as criterionn for
        % unstacking. Finally K can be a vector, and it's going to be the
        % unstacking criterion directly. Note that if K is a vector, its
        % length must match that of X.
        %
        % "names" is a cell of string used as header for X. Note that
        % length(names) == size(X,2).
        %
        % Note that the class of the output is the same of the class of
        % "X", unless names is provided. If names is provided, the output
        % is a dataset with VarNames "names" regardless of the original
        % class of "X."
        %
        % -----------------------------------------------------------------        
        %
        if nargin < 2
            error('I need an unstacking criterion.');
        elseif nargin == 3
        % About to make a dataset
            if isa(X,'dataset')
                X = set(X,'VarNames',names);
            elseif isa(X,'double')
                X = mat2dataset(X,'VarNames',names);
            else
                error('"X" must be a dataset or a matrix.');
            end
        end                
 
        % get unstacking variable in usable format 
        if nargin < 2
            error('I need an unstacking criterion.');
        elseif isa(K,'char')
            K = X.(K);
        elseif isa(K,'double')
            if length(K) == 1
                K = double(X(:,K));
            elseif length(K) ~= size(X,1)
                error('The unstack criterion vector has the wrong size.');
            end
        else
            error('I could''t parse the unstracking argument "K."');
        end
                 
        % Unstack the matrix
        ustk = cell(length(K),1);
        uk   = unique(K(~isnan(K))); 
        for i = 1:length(uk)
          ustk{i}  = X(K == uk(i),:);
        end

        end
        
% *************************************************************************        

        function desmat = convertdesign(self,instance,order)
        %
        %
        % -----------------------------------------------------------------        
        % 
        % Helper function to convert the design matrix
        %
        % -----------------------------------------------------------------        
        %
        
        fprintf('Converting the design, instace: %d.\n',instance);
        fextime = self.fex(instance).time.TimeStamps;
        temp    = self.designinit{instance};
        if ismember(order,{'horiz','horizontal','h'})
        % Orizonatal organization: collect neede information before the
        % loop
            tsep   = mode(diff(fextime));
            vnames = temp.Properties.VarNames;
            temp   = double(temp);
            inds   = find(cellfun(@(str)strcmp('stage',str(1:5)),vnames));
            if length(inds) == 1
            % when you only have one timestamp
                inds = cat(2,inds,size(temp,2)+1);
                temp = cat(2,temp,[temp(2:end-1,ind(1))-tsep;nan]);
            end
            for i   = 1:size(temp,1);
                t   = temp(i,inds(1):sep:inds(end))';
                
                
                ndt = cat(1,ndt,[t,repmat(temp(i,:),[length(t),1])]);
            end          
        end
            
        % THIS PART NEEDS THE RATE OF CHANGE ARGUMENT
        nidx = dsearchn(temp.TimeStamps,fextime);
        desmat = temp(nidx,:);

        
        
        end
    
% *************************************************************************

    end
    
end

