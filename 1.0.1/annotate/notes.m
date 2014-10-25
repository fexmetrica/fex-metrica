%% Notes on streaming a video

close all
videoFReader = vision.VideoFileReader('test.mov','AudioOutputPort',true);
videoPlayer = vision.VideoPlayer();
flag = true;
while flag
    try 
        [videoFrame,Audio] = step(videoFReader);
        step(videoPlayer, videoFrame);
    catch
        flag = false;
    end
end
release(videoPlayer);
release(videoFReader);

%% Test the example

fexObj = importdata('/Users/filippo/Documents/code/GitHub/fex-metrica/1.0.1/examples/data/E002/fexObj.mat');
note = fexnotes(fexObj);


