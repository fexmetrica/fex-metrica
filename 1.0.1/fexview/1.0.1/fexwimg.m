classdef fexwimg < handle
%
% fexwimg
%
%
%
% ----------------------> Methods:
% 
%   show (simple, ldm, mask, combos); -- method: passive/interactive >> 
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
        % name of the template
        name
        % image
        img
        % fexwhdr object
        hdr
    end
        

%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

    methods
        function self = fexwimg(varargin)
        %
        % -----------------------------------------------------------------
        %
        % Initialization function for the class fexc. fexwimg >> "help fexwimg"
        % for detailed instructions.
        % 
        % -----------------------------------------------------------------
        %
        
        % Initialize arguments and read varargin
        args = struct('name','','img',[],'path','','landmarks',[],'muscles',[],'mask',[]);
        fnames = fieldnames(args);
        [~,inds] = ismember(fnames,varargin(1:2:end));
        for i = 1:length(inds)
            if inds(i) ~= 0
                args.(fnames{i}) = varargin{inds(i)*2};
            end
        end
        
        % Set a name for the template (when empty, the name follows the
        % syntax fexwtpl-dd:mmm:yy:HH:MM:SS).
        self.name = args.name;
        if isempty(self.name)
            self.name = sprintf('fexwtpl%s',datestr(now,'-dd:mmm:yy:HH:MM:SS'));
        end
        
        % Set img field for template image (you can either enter the image
        % directly, or you can indicate the full path to the image).
        if isempty(args.img) && ~isempty(args.path)
            self.img = imread(args.path);
        elseif isa(args.img,'char')
            args.path = args.img; 
            self.img  = imread(args.img);
        else
            self.img = args.img;
        end
        
        % This section sets the hdr fileds:
        self.hdr = fexwhdr(args);

        end
        
% *************************************************************************
% *************************************************************************                    

        function self = drawmask(self)
        %
        % -----------------------------------------------------------------
        %
        % Use UI to draw a mask.
        % 
        % -----------------------------------------------------------------
        % 
        
        % use gui to draw a mask
        xy = fexwdrawmaskui(self.img);
        % convert coordinates to logicals
        self.hdr.mask = xy;
        
        end

% *************************************************************************
% *************************************************************************                    

        function IndsMask = getmask(self)
        %
        % -----------------------------------------------------------------
        %
        % Get matrix of a mask.
        % 
        % -----------------------------------------------------------------
        %        
        
        IndsMask = [];
        try
            dim   = self.hdr.imsize(1:2);
            coord = double(self.hdr.mask);
            IndsMask = poly2mask(coord(:,1),coord(:,2),dim(1),dim(2));
        catch errorId
            warning(errorId.message);
        end
        
        end
        
% *************************************************************************
% *************************************************************************         
        
        function self = test(self,showmarks,musc_names)
        %
        % -----------------------------------------------------------------
        %
        % Display identified muscles and landmarks, to assure that
        % coregistration and identification of muscles was correctly
        % executed.
        % 
        % -----------------------------------------------------------------
        % 

        % Set few defaults
        showmarksVal = true;
        namesVal = fieldnames(self.hdr.muscles);        
        
        % Read arguments: "showmarks"
        if exist('showmarks','var')
            showmarksVal = showmarks;
        end
        % Read arguments: "showmarks"
        if exist('musc_names','var')
           if isa(musc_names,'char'), musc_names = {musc_names}; end
           inds = ismember(musc_names,namesVal);
           namesVal = musc_names(inds == 1);
        end

        % Initialize image
        h0 = figure('Name',namesVal{1},'NumberTitle','off', 'Visible', 'on');
        xlabel('Press any button to continue','fontsize',18,'fontname','Helvetica')
        I1 = rgb2gray(self.img);  %  face image
        indsm = self.getmask();   %  mask (this can be empty)

        % Layer 1: Muscles
        I2 = uint8(zeros(size(I1)));
        I2(self.hdr.muscles.(namesVal{1}).idx) = self.hdr.muscles.(namesVal{1}).texture;
        h1 = imshow(cat(3,zeros(size(I2,1),size(I2,2),2),I2));

        % Layer 2: Face image and transparency
        hold on
        h2 = imshow(I1);
        alpha = zeros(size(I1));
        alpha(self.hdr.muscles.(namesVal{1}).idx) = 1;
        alpha(indsm == 0) = 0;
        set(h2,'AlphaData', 1-.3*(alpha))
        
        % Layer 3: landmarks
        if showmarksVal
            fun = @(a) strsplit(sprintf('%.2d\n',a));
            xy = double(self.hdr.landmarks);
            s = fun(1:size(xy,1));
            text(xy(:,1),xy(:,2),s(1:end-1)','fontsize',16,'EdgeColor','m');
        end        
        hold off
        
        % Loop across several features
        for i = 2:length(namesVal)
            pause
            % Create new data
            I2 = uint8(zeros(size(I1)));
            I2(self.hdr.muscles.(namesVal{i}).idx) = self.hdr.muscles.(namesVal{i}).texture;
            alpha = zeros(size(I1));
            alpha(self.hdr.muscles.(namesVal{i}).idx) = 1;
            alpha(indsm == 0) = 0;
            % Refresh data
            set(h1,'CData',cat(3,zeros(size(I2,1),size(I2,2),2),I2));
            set(h2,'AlphaData', 1-.5*(alpha))
            set(h0,'Name',namesVal{i})
            refreshdata 
        end
        
     
        end
        
% *************************************************************************
% *************************************************************************  
        
    end
    
    
    
    
end

