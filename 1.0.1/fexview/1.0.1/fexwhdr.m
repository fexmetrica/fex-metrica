classdef fexwhdr < handle
%
% fexwhdr
%
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 09/10/14.    
    
    
    
    properties
        % name (path to the image)
        path        
        % size
        imsize
        % format
        format
        % list of landmarks
        landmarks
        % parameters for coregistration
        muscles
        % parameters for mask (double ellipses)
        mask
    end
    
    properties (Access = private)
        % metatdata
        metadata
    end
     
%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

    methods
        function self = fexwhdr(varargin)
        %
        % -----------------------------------------------------------------
        %
        % Initialization function for the class fexc. Type >> "help fexc"
        % for detailed instructions.
        % 
        % -----------------------------------------------------------------
        %
        
        % Determine whether varargin is a cell or a structure. If it's a
        % cell, it is converted to a structure.
        if isstruct(varargin{1})
            varargin = varargin{1};
        else
            try
                varargin = cell2struct(varargin(2:2:end)',varargin(1:2:end));
            catch errorID
                warning(errorID.messageID);
                return
            end
        end
        
        % Set args structure & read varargin
        args = struct('path','','img',[],'landmarks',[],'muscles',[],'mask',[]);
        fnames = fieldnames(varargin);
        for i = 1:length(fnames)
            if isfield(args,fnames{i})
                args.(fnames{i}) = varargin.(fnames{i});
            end
        end
        
        % Get size information about the image (the self.path substitution
        % makes sure that you have an absolute path).
        self.path = args.path;
        if ~isempty(args.path)
            info = imfinfo(self.path);
            self.path   = info.Filename;
            self.imsize = [info.Height,info.Width,info.NumberOfSamples];
        else
        % if image is empty, this will be [0,0]
            self.imsize = size(args.img);
        end
        
        % Set metadata (private)
        load('fexwmetadata');
        self.metadata = fexwmetadata;
       
        % Get/Set other information private methods: "setlandmarks,"
        % "setmuscles," and "setmask."
        self.sethdr('landmarks',args.landmarks);
        self.sethdr('muscles',args.muscles);
        self.sethdr('mask',args.mask);

        end

    end

%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************      
    
    methods (Access = private)
        function self = sethdr(self,type,arg)
        %
        % -----------------------------------------------------------------
        %
        % Set landmarks, muscles, and mask < THIS SECTION IS INCOMPLETE.
        % 
        % -----------------------------------------------------------------
        %            
        
        switch type
            case 'landmarks'
            % Specify the landmarks on the template.
                if nargin == 1
                    warning('No landmarks provided.');
                    self.landmarks = [];
                else
                    if strcmp(arg,'ui')
                        warning('Sorry, no gui implemented yet.');
                    else
                    % Add some testing here
                        self.landmarks = arg;
                    end
                end
            case 'muscles'
            % Specify location/texture on muscles: this uses procruster
            % analysis and needs landmarks to be already specified.
                if isempty(self.landmarks)
                    warning('I need landmarks in order to define the muscles');
                    self.muscles = [];
                else
                    if isempty(arg)
                        sourcel = self.metadata.sourceimg.landmarks.Properties.ObsNames;
                        X       = double(self.metadata.sourceimg.landmarks);
                        imgl    = self.landmarks.Properties.ObsNames;
                        [~,ind] = ismember(imgl,sourcel);
                        [~,~,t] = procrustes(double(self.landmarks),X(ind,:));
                        names   = fieldnames(self.metadata.sourceimg.muscles);
                        dim     = self.imsize([1,2]);

                        for imsc = 1:length(names)
                        % Convert the muscles coordinates (and exclude illegal coordinates)
                            [Y_0,X_0] = ind2sub(X(end,[2,1]),self.metadata.sourceimg.muscles.(names{imsc}).idx);
                            mapidx = ceil(t.b*[X_0,Y_0]*t.T + repmat(t.c(1,:),[length(self.metadata.sourceimg.muscles.(names{imsc}).idx),1]));
                            ind1 = mapidx(:,1)>=1 & mapidx(:,2)>=1;
                            ind2 = mapidx(:,1)<=dim(2) & mapidx(:,2)<=dim(1);
                            mapidx = mapidx(ind1 == 1  & ind2 == 1,:);
                            self.muscles.(names{imsc}).idx = sub2ind(dim, mapidx(:,2), mapidx(:,1));
                            self.muscles.(names{imsc}).texture = self.metadata.sourceimg.muscles.(names{imsc}).texture(ind1 == 1 & ind2 == 1,:);
                        end                                                   
                    else
                    % Add some testing here
                        self.muscles = arg;
                    end
                end
            case 'mask'
            % This can be (1) a matrix of the same size of the image, in
            % which case "1" marks pixels in the face, and "nan" or "0"
            % marks out-of-face pixels. Alternatively, (2) mask can be a function
            % handle, defyining a single/double ellipses, which identifies
            % the face in the template.
                if strcmp(arg,'ui')
                    warning('Sorry, no gui implemented yet.');
                    self.mask = [];
                else
                % set mask
                    self.mask = arg;
                end
            otherwise
                error('Unknow property %s.',type);
        end

        end
        
%**************************************************************************
%**************************************************************************        

    end
        
    
    
    
    
end

