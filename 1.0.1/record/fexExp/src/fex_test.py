#!/usr/bin/env python


# Code for fex-test: simulated Ultimatum Game where
# participants are asked to show happiness or disgust 

import pygtk, gtk, gobject, glib
import time,os,sys
from numpy import loadtxt, shape, arange, random
from threading import Thread, activeCount
import subprocess, signal
from cv2 import *

# Safely enter thread
gtk.gdk.threads_init()

class FexMaster:
    # Habdle events in the experiment
    def __init__(self,subj_nam = 101):
        # Initialize flags
        self.sid = subj_nam
        self.stage   = 0  
        self.wnumb   = 0 
        self.run     = 1
        self.ntraial = 1 
        self.expression = 0
        self.decision = "None"
        
        # Initialize object
        self.home = os.path.dirname(os.path.realpath(__file__))
        # Unzip include/img
        if not os.path.exists(self.home + "/../include/img"):
            print "Extracting images"
            os.chdir("%s/../include" %self.home)
            os.system("unzip img.zip")
            os.chdir(self.home)
            
        design = loadtxt("%s/../include/design.txt" %(self.home),skiprows = 1)
        idx = arange(shape(design)[0])
        random.shuffle(idx)
        self.design = design[idx,:]
        
        # Get Monitor geometry
        monitor = gtk.gdk.Screen()
        self.cml = monitor.get_monitor_geometry(0)
        self.cml[2] = int(.85*self.cml[2])
        self.cml[3] = int(.85*self.cml[3])

        # Add back full screen
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.modify_bg(gtk.STATE_NORMAL,gtk.gdk.Color(0,0,0))
        self.window.move(self.cml[0],self.cml[1])
        
        # Add triggers & "esc" routine
        accelgroup = gtk.AccelGroup()
        key, modifier = gtk.accelerator_parse('Escape')
        accelgroup.connect_group(key, modifier, gtk.ACCEL_VISIBLE, gtk.main_quit)
        self.window.add_accel_group(accelgroup)
        self.listener = self.window.connect('key_press_event', self.TriggerMaster)

        # import first screen
        self.image = gtk.Image()
        pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/r001.jpg")       
        scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
        self.image.set_from_pixbuf(scaled_buf)

        # Main Box
        self.main_box = gtk.VBox(False, 0)
        self.window.add(self.main_box)

        # Text Box
        self.text_box = gtk.HBox(False, 8)
        self.label = gtk.Label()
        self.text_box.pack_start(self.label, True, True, 10)
        self.label.set_markup('<span size="20000" weight="bold" color ="white"></span>')
        self.main_box.add(self.text_box)
        
        # Image Box
        self.image_box = gtk.HBox(False, 8)
        self.image_box.add(self.image)
        self.main_box.add(self.image_box)

        # Display
#        self.window.add(self.image)
        self.window.show_all()
        self.window.fullscreen()
        
    def baseline(self):
    # Collect video baseline
        frame_n = 1
        video   = VideoGrabber(self.sid,self.run,"b")
        while frame_n < 451:
            video.FrameGrab()
            frame_n += 1
            waitKey(66)
        video.VideoKill()
        self.stage   = 1
        self.decision = "None"
        pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/f001.jpg")       
        scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
        self.image.set_from_pixbuf(scaled_buf)
        self.t_init = time.time()
        self.log = logger(self.sid,self.run)
        self.video  = VideoGrabber(self.sid,self.run)
        # Enter Video Collecting Thread
        self.VideoThread = Thread(target=self.video.VideoGrab, args=([]))
        self.VideoThread.start()
        self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
        glib.idle_add(self.stage_one)

    def stage_zero(self):     
        if self.ntraial == 26 or self.ntraial == 51 or self.ntraial == 76:
            print "I am here"
            self.stage = 0
            self.run +=1
            self.video.VideoKill()
            self.log.close()
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/r002.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
        elif self.ntraial == 101:
            self.stage = -1
            self.video.VideoKill()
            self.log.close()
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/r003.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
        else:
            self.stage = 1
            self.decision = "None"
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            glib.idle_add(self.stage_one)

    def stage_one(self):
    # Main trial master 
        if time.time()-self.t_init <= 4:
            glib.idle_add(self.stage_one)
        else:
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/em003.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            self.t_init  = time.time()
            self.t_exp   = 0
            self.stage   = 2
            self.expression = 1
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            # Add text for the offer amount
            self.label.set_markup('<span size="20000" weight="bold" color ="white">Offer: $%d </span>' %self.design[self.ntraial-1,0])
            glib.idle_add(self.stage_two)   

    def stage_two(self):
        if time.time()-self.t_init > self.design[self.ntraial-1,3] and self.expression == 1:
        # Onset of emotion image
            self.expression = 2
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/em00" + str(int(self.design[self.ntraial-1,1])) + ".jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            self.t_exp = time.time()
            glib.idle_add(self.stage_two)           
        elif time.time() - self.t_exp > self.design[self.ntraial-1,2] and self.expression == 2:
        # Offset of emotion
            self.expression = 3
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/em003.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            #print self.design[self.ntraial,:]
            glib.idle_add(self.stage_two)
        elif time.time()-self.t_init > 6:
            self.label.set_markup('<span size="20000" weight="bold" color ="white"></span>')
            self.expression = 0
            self.t_init  = time.time()
            self.stage   = 3
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/d001.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            #print self.design[self.ntraial,:]
            glib.idle_add(self.stage_three)
        else:
            glib.idle_add(self.stage_two)
        
    def stage_three(self):
    # decision window.  
        if time.time()-self.t_init <= 6 and self.stage == 3:
            glib.idle_add(self.stage_three)
        elif time.time()-self.t_init > 6 and self.stage == 3:
            self.stage    = 1
            self.ntraial += 1
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/f001.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            self.t_init  = time.time()
            glib.idle_add(self.stage_zero)

    def TriggerMaster(self,widget,event):
        # Trigger reading code
        keyname = gtk.gdk.keyval_name(event.keyval)
        print "Key %s (%d) was pressed" % (keyname, event.keyval)
        if (keyname == 'space' or keyname == 'Return') and self.stage == 0:
            self.wnumb +=1
            if self.wnumb > 5:
                print "Starting baseline"
                self.stage = 1
                pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/b001.jpg")
                scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
                self.image.set_from_pixbuf(scaled_buf)
                glib.idle_add(self.baseline)
            else:
                pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/i00" + str(self.wnumb) + ".jpg")       
                scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
                self.image.set_from_pixbuf(scaled_buf)
        elif (keyname == 'Right' or keyname == 'Left') and self.stage == 3:
            self.decision = keyname
            self.log.writer(self.sid,self.run,self.ntraial,self.stage,self.expression,self.decision,time.time(),self.design[self.ntraial-1,:])
            self.stage = 1
            self.ntraial += 1
            pixbuf = gtk.gdk.pixbuf_new_from_file(self.home + "/../include/img/f001.jpg")       
            scaled_buf = pixbuf.scale_simple(self.cml[2],self.cml[3],gtk.gdk.INTERP_BILINEAR)
            self.image.set_from_pixbuf(scaled_buf)
            self.t_init = time.time()
            glib.idle_add(self.stage_zero)          

            
class VideoGrabber:
    def __init__(self,name = 101,run = 1,prefix = ''):
        # Codecs for the video:
        # Find a list here: http://www.fourcc.org/codecs.php
        # and here: http://ffmpeg.org/doxygen/trunk/isom_8c-source.html
        # also run >> ffmpeg -encoders
        
        # Generate a data repository
        self.recording = False
        self.framen    = 1
        path = os.path.dirname(os.path.realpath(__file__))
        video_dir = '%s/../data/%s' %(path, str(name))
        if not os.path.exists('%s/%03d' %(video_dir,run)):
            os.makedirs('%s/%03d' %(video_dir,run))
                
        # Set up video writer (This is done framewise)
        self.video_files = '%s/%03d/%svideo%03d' %(video_dir,run,prefix,run)
        self.FPS = 15 
        fourcc = cv.CV_FOURCC('m', 'p', '4', 'v')
        self.camcapture = VideoCapture(0)
        # width  = int(self.camcapture.get(cv.CV_CAP_PROP_FRAME_WIDTH))
        # height = int(self.camcapture.get(cv.CV_CAP_PROP_FRAME_HEIGHT))
        self.camcapture.set(cv.CV_CAP_PROP_FRAME_WIDTH, 568)
        self.camcapture.set(cv.CV_CAP_PROP_FRAME_HEIGHT,426) #640,426
        width  = 568
        height = 426
        self.writer = VideoWriter(self.video_files + ".mov",fourcc,self.FPS,(width, height),True) 
        #self.writer = VideoWriter(video_files + "%8d.jpg",fourcc,self.FPS,(width, height),True) 
            
    def FrameGrab(self):
        flag, frame = self.camcapture.read()
        if flag:
            self.writer.write(frame)
        else:
            print "Failed to collect frame"
        return flag
        
    def VideoGrab(self):
        # Starts the video loop for self.duration sec.
        if self.framen == 1:
            self.videoinfo = open(self.video_files + "_info.txt","w")
            self.videoinfo.write("Frame" + "\t" + "Acquired" + "\t" + "Time" + "\n")
            self.recording = True
        while self.recording:
            flag, frame = self.camcapture.read()
            if flag:
                self.writer.write(frame)  
            msg = str(self.framen) + '\t' + str(flag) + '\t' + str(time.time())  + '\n'
            try:
                self.videoinfo.write(msg)
            except:
                print "No log file is open."
            self.framen += 1
        self.videoinfo.close()
        
    def FrameLog(self):
    # Capture a frame
        print ""
        
    def FrameReport(self):
    # Report video information
        print ""
    
    def VideoKill(self):
    # Kill the video
        if self.recording:
            self.recording = False
        self.camcapture.release()
     
    def FrameMarry(self):
    # Kill the video
        print ""

class GtkThreadSafe:
    def __enter__(self):
        gtk.gdk.threads_enter()
        
    def __exit__(self, _type, value, traceback):
        gtk.gdk.threads_leave()

# logger for trials       
class logger():
    def __init__(self,name,run):
        home = os.path.dirname(os.path.realpath(__file__))
        self.file = open(home + "/../data/" + str(name) + "/" + str(name) +  "_run_" + str(run) + ".txt", 'w')
        self.header()
    def close(self):
        self.file.close()
    def writer(self,sid,run,trial,stage,exp,dec,time,design):
        data = "%s \t %s \t %s \t %s \t %s \t %s \t %s \t" %(str(sid),str(run),str(trial),str(stage),str(exp),str(dec),str(time))
        for i in range(4):
            data = data + str(design[i]) + '\t'
        self.file.write(data + '\n')
    def header(self):
        #Change header between Ultimatum and Anger Game
        self.file.write('SID \t Run \t Trial \t Stage \t Expression \t Decision \t Time \t Offer \t Joy \t Duration \t Onset\n')

if __name__ == "__main__":
    if len(sys.argv) == 2:
        g = FexMaster(sys.argv[1])
    else:
        g = FexMaster()
    gtk.main()