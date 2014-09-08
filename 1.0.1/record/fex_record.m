function fex_record(varargin)


%warning('off','all'); %.... diable warining msg ...;
% % vid = videoinput('winvideo',1, 'YUY2_320x240');
% vid = videoinput('macvideo', 1);
% set(vid, 'FramesPerTrigger', Inf);
% set(vid, 'ReturnedColorspace', 'rgb');
% % vid.FrameRate =30;
% vid.FrameGrabInterval = 1;  % distance between captured frames 
% start(vid)
% 
% % aviObject = avifile('myVideo.avi');   % Create a new AVI file
% writerObj = VideoWriter('test.m4v','MPEG-4');
% for iFrame = 1:50                    % Capture 100 frames
%   % ...
%   % You would capture a single image I from your webcam here
%   % ...
% 
%   I=getsnapshot(vid);
% %imshow(I);
%   F = im2frame(I);                    % Convert I to a movie frame
%   writerObj = addframe(aviObject,F);  % Add the frame to the AVI file
% end
% aviObject = close(aviObject);         % Close the AVI file
% stop(vid);


vid = videoinput('macvideo', 1);
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb');
vid.FrameGrabInterval = 1;  % distance between captured frames 
start(vid);

writerObj = VideoWriter('test.m4v','MPEG-4');
% open(writerObj);

for i = 1:50
    I=getsnapshot(vid);
    F = im2frame(I); 
    writeVideo(VideoWriter,F);
end

close(writerObj);
stop(vid);
 