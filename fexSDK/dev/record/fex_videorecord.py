#!/usr/bin/env python

'''
fex_videorecord uses python and OpenCV to record a video or a set of frames
from a webcam. You can call fex_videorecord from a terminal, or you can call
the main class "master_of_frames" from another python script. 

USAGE:

    python fex_videorecord()
    python fex_videorecord(filename)
    python fex_videorecord(filename,loop,duration)

INPUT DESCRIPTION:

"filname": is a string with the name of the file to be generated. This is set
    by default to "./movie.avi".

    IMPORTANT: The file extension determines whether you will be saving a video
    or individual frames:
        
            A video is saved for: 'avi','mov','mp4','mvk';
            A frame is saved for: 'png','jpg','jpeg'.
            A .mov is saved when "filename" has no extensino.
            
            For unknown extension, fex_videorecord tries to save a video.

"loop": this affects the way in which the video is coolected. Option for "loop" are:

    -- True (default):
       Starts collect a video, until you pres "ctrl+c".
    
    -- False:
       This initialize VideoCapture, but it doesn't print frames. To save a frame
       you have to iteratively call "capture_vide." This is the suggested option
       when you call "master_of_frames()" from another python script.
       
"duration": A float, indicating seconds of video to be collected. The video 
            is recorded for the duration specified. Default is until the "q" key
            is pressed. By Default, duration is set to infinity. NOTE, duration is
            ignored if loop = False.       


OUTPUT DESCRIPTION:

fex_videorecord will save a video (or a set of frames) in the required directory, using
the name you specified. Additionally, a file named frame_[filename].txt is saved. This
file is a N*5 matrix. Each row is a frame, and the columns are:

     -- Collected: true/false indicates whether the frame was printed without errors;
     -- FrameN:    frame number (base 0);
     -- TimeTime:  time at which frame k was collected, using time.time()
     -- RosTime:   time at which frame k was collected, using get_rostime();
     -- FrameRate: estimated framerate.

NOTE: You need to have roscore running in order to compute RosTime. If roscore is not
running or rospy is not installed, RosTime is 'Nan'.

SETTING UP CAMERA RECORDING OPTIONS

There are many options in OpneCV you can specify for the video. I hardcoded them.
You can add/change option in in the "CV_CAP SETTING BOX" at line 171. 

Below, I provide a list CV_CAP properties. Note that not all of them are implemented in
Python, and that the camera you are using may not support others.
        
    0  =  CV_CAP_PROP_POS_MSEC Current position of the video file in milliseconds.
    1  =  CV_CAP_PROP_POS_FRAMES 0-based index of the frame to be decoded/captured next.
    2  =  CV_CAP_PROP_POS_AVI_RATIO Relative position of the video file
    3  =  CV_CAP_PROP_FRAME_WIDTH Width of the frames in the video stream.
    4  =  CV_CAP_PROP_FRAME_HEIGHT Height of the frames in the video stream.
    5  =  CV_CAP_PROP_FPS Frame rate.
    6  =  CV_CAP_PROP_FOURCC 4-character code of codec.
    7  =  CV_CAP_PROP_FRAME_COUNT Number of frames in the video file.
    8  =  CV_CAP_PROP_FORMAT Format of the Mat objects returned by retrieve() .
    9  =  CV_CAP_PROP_MODE Backend-specific value indicating the current capture mode.
    10 =  CV_CAP_PROP_BRIGHTNESS Brightness of the image (only for cameras).
    11 =  CV_CAP_PROP_CONTRAST Contrast of the image (only for cameras).
    12 =  CV_CAP_PROP_SATURATION Saturation of the image (only for cameras).
    13 =  CV_CAP_PROP_HUE Hue of the image (only for cameras).
    14 =  CV_CAP_PROP_GAIN Gain of the image (only for cameras).
    15 =  CV_CAP_PROP_EXPOSURE Exposure (only for cameras).
    16 =  CV_CAP_PROP_CONVERT_RGB Boolean flags indicating whether images should be converted to RGB.
    17 =  CV_CAP_PROP_WHITE_BALANCE Currently unsupported
    18 =  CV_CAP_PROP_RECTIFICATION Rectification flag for stereo cameras (note: only supported by DC1394 v 2.x backend currently)
     
See also: http://stackoverflow.com/questions/11420748/setting-camera-parameters-in-opencv-python

--------------------------------------------------------------------------------------

"fex_videorecord.py" is part of "fex-metrica" Copyright (C) 2014 Filippo Rossi,
University of California, San Diego. Contact: frossi@ucsd.edu.

Code available at: https://github.com;
fex-metrica version 1.0.1
last updated: 06/18/2014

'''


import os,sys,time
from cv2 import *
import numpy as np
try: 
    import rospy
except error:
    print "Rospy not found...Timpestamps computed with time.time() only."


class master_of_frames():
    def __init__(self,filename='movie.mp4',loop = True, duration = -1, with_ros = False):
        
        # Inintialize information. Note that if loop is false, frames are grabbed 
        # when self.capture_video() is called. Instead, if loop is set to True the
        # master of frame will capture a video using self.capture_video_loop(). This 
        # second routine is usefull if you want to run master of frame independently.

        # Read Arguments
        self.with_ros   = with_ros
        self.start_loop = loop
        self.duration   = float(duration)
        self.t          = 0 

        # Interpret "filename": path, filename and extension
        path, name = os.path.split(filename)
        name, extension  = os.path.splitext(name.lower())
        
        # Get/Set path
        if not path:
            self.location = '.'
        else:
            self.location = path
        # Get/Set extension   
        if not extension:
            self.extension = '.mp4'
        else:
            self.extension = extension
        
        # Change file name based on extension
        if not name:
            if self.extension in ['.jpg','.jpeg','.png']:
                self.name = "frame"
            else:
                self.name = "movie"
        elif name == "movie" and self.extension in ['.jpg','.jpeg','.png']:
            self.name = "frame"
        else:
            self.name = name
            
        
        # Assign video log name and video file name
        cnt = ""
        if self.extension in ['.jpg','.jpeg','.png']:
            cnt = "_%8d"
        self.video_name = self.location + '/' + self.name + cnt + self.extension
        self.log_frame  = self.location + '/' +  "frame_" + self.name + ".txt"
        print "Files Name : "
        print self.video_name 
        print self.log_frame
        
        
        # Run with/without Ros for timestamps
        if self.with_ros:
            try:
                rospy.init_node('Timer')
            except error:
                self.with_ros = False
                print 'rospy was not found or roscore was not initialized'

###########################################################################################
################################ CV_CAP SETTINGS BOX ######################################
###########################################################################################
                                                                                       ####                                                                              
        # You can select a different camera by changing '-1'                           ####
        self.camcapture = VideoCapture(-1)                                             ####
        # Video FrameRate                                                              ####
        self.FPS = 30                                                                  ####
        # Codecs for the video.                                                        ####
        # Find a list here: http://www.fourcc.org/codecs.php                           ####
        # and here: http://ffmpeg.org/doxygen/trunk/isom_8c-source.html                ####
        # also run >> ffmpeg -encoders                                                 ####
        fourcc = cv.CV_FOURCC('y', 'u', 'v', '2')                                      ####
        # Frame size                                                                   ####
        self.camcapture.set(cv.CV_CAP_PROP_FRAME_WIDTH,640)                            ####
        self.camcapture.set(cv.CV_CAP_PROP_FRAME_HEIGHT,480)                           ####
                                                                                       ####
###########################################################################################
################################ CV_CAP SETTINGS BOX ######################################
###########################################################################################

        # Print some infotmation   
        print "Cmera capture is open: " + str(self.camcapture.isOpened())
        print "Burning first 5 frames"
        for i in range(5):
            flag, frame = self.camcapture.read()
        if flag:
            width = np.size(frame, 1)
            height =np.size(frame, 0)
            print 'y: ' + str(width) + ' x: ' + str(height)
        else:
            print "no Frame"
            width  = 720
            height = 480

        # Initialize the video writer
        self.writer = VideoWriter(self.video_name,fourcc,self.FPS,(width, height),True) 
        
        # Initialize Capturing framework
        self.recording = True  
        self.videoinfo = videologger(self.log_frame, self.name)
        self.videoinfo.header()  
        
        # Inintialize time.time() timer
        self.first_time = time.time()
        # Decide whether to run capture video or capture video loop
        if self.start_loop:        
            self.capture_vide_loop()           
    
    def capture_video(self):
        # This capture a frame only when called.
        if self.recording == True: 
            if self.t == 1 and self.with_ros:
                self.t_0  =  rospy.get_rostime()
            flag, frame = self.camcapture.read()
            if flag:
                self.writer.write(frame)
            # use/don't use ros
            if self.with_ros:
                t = str(self.t_0.now())
            else:
                t = "Nan"
            msg = str(flag) + '\t' + str(self.t) + '\t' +  str(time.time())  + '\t' + t + '\t' + self.get_framerate()
            self.videoinfo.writer(msg)
            self.t += 1
        else:
            print "stop capturing"
            self.camcapture.release()
            self.videoinfo.closefile()
# You may want to kill roscore now.
#            if not rospy.is_shutdown():
#                rospy.signal_shutdown("Terminated Recording")


    def capture_vide_loop(self):
        # Starts the video loop for self.duration sec.
        print "Capturing!"
        self.recording = True
        if self.with_ros:
            self.t_0  =  rospy.get_rostime()
        while self.recording:
            try:
                flag, frame = self.camcapture.read()
                if flag:
                    self.writer.write(frame)
                if self.with_ros:
                    t = str(self.t_0.now())
                else:
                    t = "Nan"
                msg = str(flag) + '\t' + str(self.t) + '\t' +  str(time.time())  + '\t' + t + '\t' + self.get_framerate()
                self.videoinfo.writer(msg)
                self.t += 1
                print 'Frame rate = ' + self.get_framerate()
                print 'Time Elapsed = ' + str((time.time()-self.first_time)) + ' (Duration = ' + str(self.duration) + ')'
                if self.duration > 0 and (time.time()-self.first_time) > self.duration:
                    self.recording = False
            except KeyboardInterrupt, e:
                self.recording = False
        self.videoinfo.closefile()
        self.camcapture.release()
# You may want to kill roscore now.
#            if not rospy.is_shutdown():
#                rospy.signal_shutdown("Terminated Recording")
          
    def pubblish_frame(self):
        # Retunr current frame number
        return str(self.t)

    def get_framerate(self):
        # compute frame rate with time.time()
        framerate  = str(int(self.t/(time.time()-self.first_time)))
        return framerate
    
    def kill_process(self):
        # This is used to interrupt recording from another script.
        # NOTE THAT THIS ONLY APPLIES TO INPUT ARGUMENT LOOP = FALSE
        self.recording = False
        self.capture_video()
        
class videologger():
    def __init__(self, file, subject):
        self.subjectname = subject
        self.file = open(file,"w")
        self.file.write(str(time.asctime(time.localtime(time.time()))) + " Subject: " + str(self.subjectname) + '\n\n')
    def close(self):
        self.file.close()
    def writer(self, data):
        self.file.write(data + '\n')
    def header(self):
        self.file.write('Collected \t Frame \t TimeTime \t RosTime \t FrameRate\n')
    def closefile(self):
        self.file.close()

if __name__ == "__main__":
    if len(sys.argv) == 1:
        h = master_of_frames()
    elif len(sys.argv) == 2:
        h = master_of_frames(sys.argv[1])
    elif len(sys.argv) == 3:
        h = master_of_frames(sys.argv[1],sys.argv[2])
    elif len(sys.argv) == 4:
        h = master_of_frames(sys.argv[1],sys.argv[2],sys.argv[3])
    else:
        h = master_of_frames(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])


