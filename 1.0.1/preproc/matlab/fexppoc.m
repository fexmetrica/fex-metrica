classdef fexppoc
%
% Obj = fexppoc('video', videofile);
% Obj = fexppoc('video', videofile, 'ArgNam1',ArgVal1,...);
%
% "fexppoc" creates a fex preprocessing opbjec for a video, and analyze
% the video using the Emotient SDK (http://www.emotient.com). You can use
% "fex_ppo2.m" to esily generate this object. For examples and further help
% see "fexfacet_example.m", and the manual provided in "README".
%
% ARGUMENTS:
%
% 'video'   a string with the absolute path to one video file. USE
%           fex_ppo2 to select file with a GUI, and select multiple file at
%           the same time.
%
%
% OPTIONAL ARGUMENTS:
%
% 'outdir'  a string with the absolutre path to the directory where
%           result file will be saved.
% 'chanels' a string indicating the type of variables which will be
%           outputed by the Emotient SDK. Options include:
%
%           - 'face': landmarks and pose only;
%           - 'emotions': landmarks, pose,emotions and sentiments;
%           - 'aus': landmarks, pose, action units;
%           - 'all': landmarks, pose, action units, emotions and sentiments
%                   [default].
%
% LIST OF PUBLIC PROPERTIES:
%
% 'video'   a string with the absolute path to a video file;
% 'outdir'  a string with the absolutre path to the directory where
%           result file will be saved.
% 'chanels' a string indicating the type of variables which will be
%           outputed by the Emotient SDK.
%
%           >> help fexppoc.video2frame
%
% 'videoInfo': a vector with information about the current video, s.t.:
%
%               videoInfo(1) = FrameRate
%               videoInfo(2) = Duration
%               videoInfo(3) = NumberOfFrames
%               videoInfo(4) = Width
%               videoInfo(5) = Height
%
% LIST OF DEPENDENT PROPERTIES:
%
% 'framefile': absolute path to a .txt file containing the frames that will
%              be analized using the Emotient SDK
% 'facetfile': absolute path to a file within 'outdir' containing 
%              output from the Emotient SDK.
% 'facetcmd':  string with the comand line used to lunch the Emotient SDK
%              executable files in ../cppdir/bin.
%
% LIST OF PUBLIC METHODS:
%
% 'video2frame': generates the comand to cut video into frames -- see help
%                for details, i.e.:
%
%                >> help(fexppoc.video2frame)
%
% 'getvideoInfo': retrieve information for videoInfo.
% 'step':        perprocess the video (calls cut_frames & run_facet) -- see
%                help for details.
% 'cut_frames':  execute comand generated from "video2frame".   
% 'run_facet' :  execute comand "facetcmd."
% 'clean'     :  delete the directory where frames .jpg files where
%                temporary stored. -- see help for details.
% 'tellstatus':  print the stage in the analysis of the video.
%
%
%_______________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 06/14/14.

%**************************************************************************
%**************************************************************************
%************************** PROPERTIES ************************************
%**************************************************************************
%**************************************************************************

    % Public properties
    properties
        % enter a subject ID                !!!!!!TODOD
        subjectID
        % absolut path to video file
        video
        % Information about the video
        videoInfo
        % outpu directory for facet file
        outdir
        % chanels used by facet
        chanels
        % file that will contain the preprocess output
        facetfile
        % command to cat the video into frames
        framecmd
    end
    
    % Protected properties
    properties (Access = protected)
        % status of preprocessing 
        status
        % location of fexfacet executables
        facetbin
        % temporary directory for frames
        framedir
        % minimum face size
        minfacesize
    end
    
    % Dependent properties
    properties (Dependent)
        % file that will contain the frames
        framefile
        % comand issued to facet
        facetcmd
    end

%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

    methods
        function self = fexppoc(varargin)
        %
        % Init function which constructs the class fexppoc. See the
        % OPTIONAL ARGUMENT section in the main documentations for more
        % details.
        % -----------------------------------------------------------------
            % video file
            [test,val] = ismember('video',varargin);
            if test
               self.video  = varargin{val+1};
            else
                self.video = '';
            end
            
            % output directory
            [test,val] = ismember('outdir',varargin);
            if test
               self.outdir  = varargin{val+1};
            else
                self.outdir = sprintf('%s/%.0f',pwd,now*100);
            end
            if ~exist(self.outdir,'dir')
                mkdir(self.outdir);
            end
            
            % chanels
            [test,val] = ismember('chanels',varargin);
            if test
               self.chanels  = varargin{val+1};
            else
                self.chanels = 'all';
            end
            
            % Initialize private fields -- status and facetbin
            self.status    = 0;
            self.facetbin  = sprintf('%s/bin',fileparts(which('fexfacet_face.cpp')));
            
            % Initialize private property: temp folder for frames
            k = 1;
            name = sprintf('temp_%.2d',k);
            while exist(sprintf('%s/%s',self.outdir,name),'dir')
                k = k + 1;
                name = sprintf('temp_%.2d',k);
            end
            self.framedir = sprintf('%s/%s',self.outdir,name);
            % make the directory only when needed
            % I am not sure I want to make the directory here!!!
%             mkdir(self.framedir);
            
            % Initialize cat video comand
%             self = self.video2frame();
            self.framecmd = '';

            % Initialize VideoInfo
            self.videoInfo = [];
            
            % get facet file name
            self.facetfile = self.facetfilename();
            
            % Set minimum face size
            self.minfacesize = 0.05;
            
            
        end
        
        function self = getvideoInfo(self)
        % Get information about the video
            vidObj = VideoReader(self.video);
            self.videoInfo = [vidObj.FrameRate,vidObj.Duration,...
                              vidObj.NumberOfFrames,...
                              vidObj.Width,vidObj.Height];
        end
        
        function self = setminfacewidth(self,val)
            % set minimum face width
            if ~exist('val','var')
                warning('No minimum width value was entered.\n');
            else
                self.minfacesize = val;
            end
        end
            
        
        
        function self = step(self)
        %     
        % Main function for advancing preprocessing. This functions
        % cats a video into frame and saves the Emoteint SDK output
        % for the required method calls "cut_frames" and
        % "run_facet."
        % -----------------------------------------------------------------
%             if self.status == 0
%                 h = waitbar(0,'Initialization ...');
%                 fprintf('Catting video into frames ....\n');
%                 waitbar(.25,h,'Video 2 Frames');
%                 self.cut_frames();
%                 fprintf('Processing frames with the Emotient SDK ....\n');
%                 waitbar(.5,h,'Emotient SDK');
%                 self.run_facet();
%                 waitbar(1,h,'Completed');
%                 fprintf('Step completed.\n')
%                 close(h)
%             end
            fprintf('Processing frames with the Emotient SDK ....\n');
            self.run_facet();
            self.status = 2;
        end
            
        
        function self = cut_frames(self)
        %
        % This methods cuts "video" into .jpg files using ffmpeg, avconv or
        % matlab. The frames are saved in a directory labeled "temp_k" in
        % the output directory (i.e. "outdir"). It also generated a file
        % with a list of the frame which will be processd by teh Emotient
        % SDK. The file is located in the "temp_k" directory, and it is
        % namedn "framefile."
        %
        % Methods and parameters for cutting frames are habdled by the
        % method "video2frame."
        % -----------------------------------------------------------------
            if ~exist(self.framedir,'dir');
                mkdir(self.framedir);
            end
            if ischar(self.framecmd)
                % avconv or ffmpeg
                unix(sprintf('source ~/.bashrc && %s',self.framecmd));
            else
                % matlab
                vidObj = VideoReader(self.video);
                parfor iframe = 1:self.videoInfo(3)-1 % Drop last frame
                    I = self.framecmd{1}(vidObj,iframe);
                    imwrite(I,sprintf('%s/img_%.8d.jpg',self.framedir,iframe),'Quality',self.framecmd{2});
                end
            end
            % export frames to frame file:
            unix(sprintf('find %s -name "*.jpg" | sort > %s',self.framedir,self.framefile));
            % update status
            self.status = 1;
        end

    
        function self = run_facet(self)
        % Run the selected Emotient SDK executable ("chanels"), and save a
        % file in the "outdir" folder
        % -----------------------------------------------------------------
        
        % CHANGE THIS: don't overide and don't repite
        if self.status == 2
            warning('You are about to delete an existing fexfile!')
        end
            desc = ''; %FIX THIS 
            unix(sprintf('source ~/.bashrc && %s',self.facetcmd));
            test  = strfind(desc,'cannot execute');
            if isempty(test)
%                 self.filehead();
                self.status = 2;
            else
                warning('Cannot run executable file.')
                self.facetfile();
            end
            self.status = 2;

        end
        
        
        function self = video2frame(self,varargin)
        %
        % self.video2frame(); self.video2frame('VarName1',VarVal1,..);
        %
        % video2frame determines how to cute "video" into .jpg files.
        % Optional arguments include:
        %
        % 'method': a string or a function handle. When it is a string,
        %           method can be either "ffmpeg" (default on Mac),
        %           "avconv" (default on Linux), or "matlab" (default on
        %           PC). Based on the string, "video" will be divided into
        %           frames using ffmpeg, avconv, or matlab. Optional
        %           arguments for "ffmpeg" and "avconv" methods can be
        %           specified using:
        %           
        %               >> self.video2fram(...,'optarg','syting',...);
        %
        %           Instead, in order to specify optional arguments for
        %           matlab, you need to pass the handle to a function
        %           instead of a string. Internally, video cutting in
        %           matlab is done as follow:
        %
        %               >> vidObj = VideoReader(self.video);
        %               >> parfor k = 1:numFrames
        %               >>    img = func_h(vidObj,k);
        %               >>    imwrite(img,filename,'Quality',qscale);
        %               >> end
        %
        %           You can set method to be handle to "func_h." The inner
        %           part of "func_h" is always "read(vidObj,k)," however, you
        %           can add operations, such as converting rgb frames to
        %           black and white:
        %
        %               >> method = @(vidObj,k)rgb2gray(read(vidObj,k));
        %
        %           See matlab documentation for image operations.
        %           NOTE, matlab method is slower than ffmpeg and avconv.
        %           You can open a pool of matlab worksers before executing
        %           this comand:
        %
        %               >> matlabpool
        %               >> Obj  = Obj.video2frame();
        %               >> Obj.step();
        %
        % 'qscale', a double between 0.0 and 1.0, which indicates the
        %       quality scaling. 0.0 (default) indicates no quality scaling
        %       (i.e. best resolution), while 1.0 indicate max quality
        %       scaling (i.e. worst resolution).
        %
        % 'optargs', a string with optional arguments for methods "ffmpeg"
        %       and "avconv." Suppose you are using "ffmpeg" method and you
        %       want to  transpose each frame and convert them to
        %       black/white you cans set:
        %
        %       >> optargs = '-vf transpose=1 -pix_fmt gray'
        % 
        %       For a brief documenmtation of avconv see this: >>
        %       http://manpages.ubuntu.com/manpages/precise/man1/avconv.1.html;
        %       
        %       For ffmpeg documentation see this: >>
        %       https://ffmpeg.org/index.html;
        %
        %------------------------------------------------------------------
            
            % Set defaults arguments
            if ismac
                arg.method  = 'ffmpeg';
                arg.qscale  = 0.0;
                arg.optargs = '';
            elseif ~ismac && isunix
                arg.method  = 'avconv';
                arg.qscale  = 0.0;
                arg.optargs = '';
            else
                % The code is not meant for windows, however, you should be
                % able to set up the object, and cut videos into frame on a
                % PC. then you are on your own in terms of using the
                % Emotient SDK.
                arg.method = 'matlab';
                arg.qsacale = 0.0;
                arg.optargs = '';
            end       
            % Read optional arguments when provided
            if ~isempty(varargin)
               for i = 1:2:length(varargin)
                   if ismember(varargin{i},fieldnames(arg))
                       arg.(varargin{i}) = varargin{i+1};
                   else
                       % Make sure that a proper option is slected.
                       warning('Unrecognized option: %s. Ignored.',varargin{i});
                   end
               end
            end
            % make sure that qscale is in the proper format
            if strcmp(arg.method,'ffmpeg')
                % 0.0 best, 1.0 worst
                arg.qscale = arg.qscale;
            elseif strcmp(arg.method,'avconv')
                % 2 best, 31.0 worst
                arg.qscale = 1 + 30*arg.qscale;
            else
                % 0.0 worst, 100 best
                arg.qscale = round(100-(arg.qscale*100));
            end
            % Combine the comand for ffmpeg or avconv
            if ismember(arg.method,{'ffmpeg','avconv'})
                cmd = sprintf('%s -i %s -qscale:v %.1f -r %.4f %s -loglevel fatal %s/img_%s.jpg',...
                arg.method,...                  % Select method
                self.video,...                  % Input file
                arg.qscale,...                  % Quality scaling factor (0 = no scaling);
                self.videoInfo(1),...           % Framerate
                arg.optargs,...                 % String with extra parameters
                self.framedir,...               % output directory
                '%8d');                         % output file numbering         
            elseif strcmp('matlab',arg.method);
                cmd{1} = @(V,k) read(V,k);
                cmd{2} = arg.qscale;
            elseif ishandle(arg.method)
                cmd{1} = arg.method;
                cmd{2} = arg.qscale;
            end
            self.framecmd =  cmd;
        end
           
        function clean(self,varargin)
        % Delete the directory with the frames (Note that if the
        % directory is not called 'temo_XX,' meaning that it wasn't
        % generated by fexppoc, clean asks for confirmaton.
        % 
        % The optional argument '-loglevel' can be set to 'quiet',
        % 'dead', or 'panic.'
        %
        %------------------------------------------------------------------
            if isempty(self.framedir)
                % when frames were not generated, there is nothing to
                % clean
                warning('Nothing to clean ... exiting\n');
                return
            end
        
        
            %Read optional arguments
            exe_clean = 'Yes';
            if isempty(varargin)
                loglevel = 'panic';
            elseif ismember(varargin{end},{'quiet','dead','panic'})
                loglevel = varargin{end};
            else
                warning('Loglevel argument not recognized.')
                loglevel = 'panic';
            end
            
            % Test for directory name
            [~,dir_test] = fileparts(self.framedir);
            test = strcmp('temp_',dir_test(1:5));
            
            if test == 0 && ~strcmp(loglevel,'dead')
                % loglevel is forced to panic when the directory with the
                % frames was not created by fexppoc.
                loglevel = 'panic';
            end
            
            if strcmp(loglevel,'panic')
                exe_clean = questdlg(sprintf('Remove the directory:\n%s?',self.framedir), ...
                        'Yes', ...
                        'No');
            end
            
            % finally delete directory
            if strcmp(exe_clean,'Yes')
                unix(sprintf('rm -r %s',self.framedir));
            end

        end
        
        function tellstatus(self)
        % Print preprocessing status for specific video.
        %
        %------------------------------------------------------------------

            str0 = sprintf('\nVideo name:\n\t%s.\n',self.video);
            switch self.status
                case 0
                    str1 = 'None';
                    str2 = 'None';
                case 1
                    str1 = 'Completed';
                    str2 = 'None';
                case 2
                    str1 = 'Completed';
                    str2 = 'Completed';
            end
            fprintf('%s\tFrame processing: %s.\n\tFacet processing: %s.\n\n',str0,str1,str2)
        end 
        
        function data = results(self)
        % import the facet out as dataset
        %
        %------------------------------------------------------------------
            if self.status == 2
                data = dataset('File',self.facetfile);
            else
                warning('The file with video results need to be genereated.');
            end
        end
        
  
    end
    
%**************************************************************************
%**************************************************************************
%************************** GETTER FUNCTIONS ******************************
%**************************************************************************
%**************************************************************************

    methods        
        function framefile = get.framefile(self)
        % Getter functions for framefile
            framefile = sprintf('%s/%s',self.framedir,'frame_file.txt');
        end
        
        % Getter function for facetcmd 
        function facetcmd = get.facetcmd(self)
            binf = sprintf('%s/fexfacet',self.facetbin);
            switch self.chanels
                case {'all','All','a'}
                    chid = 1;
                case {'face','Face','f'}
                    chid = 4;
                case {'emotions','Emotions','emo','e'}
                    chid = 2;
                case {'au','AU','ActionUnits','aus','AUs'}
                    chid = 3;
                otherwise
                    warning('Unknown chanels name: %s. Using all chanels.',self.chanels);
                    chid = 1;
            end
            facetcmd  = sprintf('%s -v %s -c %d -m %.2f -o %s',...
                binf,self.video,chid,self.minfacesize,self.facetfile);
        end
    end
    
    
    
%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************
    
    
    methods (Access = private) 
%         function filehead(self)
%         % Add header to fexfacet file and save.
%             data = importdata(self.facetfile);
%             load('fexfacethdr.mat');
%             ndata = mat2dataset(data.data,'VarNames',fexfacethdr.(lower(self.chanels)),...
%                         'ObsNames',data.textdata(1:end-1,1));
%             export(ndata,'File',self.facetfile);                
%         end
        
        
        function ffn = facetfilename(self)
        % functions for facetfile name
            [~,f,~] = fileparts(self.video);
            k = 1;
            name = sprintf('%s/facet_%s_%.2d.txt',self.outdir,f,k);
            while exist(name,'file')
                d = importdata(name);
                if isempty(d)
                    unix(sprintf('rm %s',name));
                else
                    k = k + 1;
                    name = sprintf('%s/facet_%s_%.2d.txt',self.outdir,f,k);
                end
            end
            ffn = name;   
        end
        
        
    end

end