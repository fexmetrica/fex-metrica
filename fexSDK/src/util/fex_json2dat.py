#!/usr/bin/env python

'''
FEX_JSON2DATA - reads a json file generated with FEXFACET.cpp and returns a dataset.

USAGE:
=======

python FEX_JSON2DATA json_file_in [output_file] [write_header]


FEX_JSON2DATA is meant for internal use only.

EXAMPLE:
=======

python fex_json2dat.py ../../test/test.json ../../test/test.csv

Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
University of California, San Diego. email: frossi@ucsd.edu

VERSION: 1.0.1 10-Jan-2014. 
'''


import json,sys
import sys
import numpy as np


def get_all_frames(data,nodes,track_id):
    '''
    Export all frame data from a track
    '''
    X = np.zeros((np.size(data["frames"]),57))
    for i in range(np.size(data["frames"])):
        X[i,:] = get_frame(data["frames"][i],nodes,track_id)
    return X
    
def get_frame(framedata,nodes,track_id):
    '''
    Read data for a frame
    '''
    x = np.zeros((1,57))
    # Add current TimeStamp
    x[0,0] = framedata["timestamp"]
    k = 1
    # Add frame box
    for i in nodes["face-location"]:
        x[0,k] = framedata["face-location"][i]
        k += 1
    # Add demographic evidence
    x[0,k] = framedata["demographic-evidence"]["isMale"]
    k += 1
    # Add AU Evidence data
    for i in nodes["au-evidence"]:
        x[0,k] = framedata["au-evidence"][i]
        k += 1
    # Add emotion Data
    for i in nodes["emotion-evidence"]:
        x[0,k] = framedata["emotion-evidence"][i]
        k += 1
    # Add landmarks
    for i in nodes["landmarks"]:
        x[0,k] = framedata["landmarks"][i]["x"]
        x[0,k+1] = framedata["landmarks"][i]["y"]        
        k += 2
    # Add emotion Pose
    for i in nodes["pose"]:
        x[0,k] = framedata["pose"][i]
        k += 1
    x[0,56] = track_id
    
    return x

def define_nodes():
    '''
    HARDCODE header information for FACET JSON file
    '''
    # Initialize Main Nodes
    nodes = {"timestamp": {},"face-location": {},"demographic-evidence": {"isMale"}, "au-evidence": {},"emotion-evidence": {},"landmarks": {},"pose": {}}
    # Add nodes hdr information
    nodes["au-evidence"] = define_hdr(2)
    nodes["emotion-evidence"] = define_hdr(3)
    nodes["face-location"] = ["height" ,"width","x","y"]
    nodes["landmarks"] = define_hdr(4)
    nodes["pose"] = ["pitch","roll","yaw"]
    return nodes

def define_hdr(num = 0):
    '''
    HARDCODED header for final csv file
    '''
    hdr1 = ["FrameRows","FrameCols","timestamp","FaceBoxH","FaceBoxW","FaceBoxX","FaceBoxY","isMale"]
    hdr2 = ["AU1","AU2","AU4","AU5","AU6","AU7","AU9","AU10","AU12","AU14","AU15","AU17","AU18","AU20","AU23","AU24","AU25","AU26","AU28"]
    hdr3 = ['anger', 'contempt', 'disgust', 'fear', 'joy', 'sadness', 'surprise','confusion','frustration','positive','negative','neutral']
    hdr4 = ["center_mouth" ,"left_eye_lateral" ,"left_eye_medial" ,"left_eye_pupil","nose_tip","right_eye_lateral","right_eye_medial","right_eye_pupil"]
    hdr5 = ["pitch","roll","yaw"]
    # Return required header
    if num == 0:
        hdr4b = []
        for i in hdr4:
            hdr4b.append("%s_x" %i)
            hdr4b.append("%s_y" %i)
        hdr = hdr1 + hdr2 + hdr3 + hdr4b + hdr5 + ['track_id']
    elif num == 1:
        hdr = hdr1
    elif num == 2:
        hdr = hdr2
    elif num == 3:
        hdr = hdr3
    elif num == 4:
        hdr = hdr4
    elif num == 5:
        hdr = hdr5
    return hdr

nodes = define_nodes()

json_data = open(sys.argv[1])
data = json.load(json_data)
json_data.close()

total_frames = np.size(data['output']['frametimes'])
total_tracks = np.size(data['output']['tracks'])

# Add all tracks
track_id = 0
X = get_all_frames(data['output']['tracks'][track_id],nodes,track_id)
for i in np.arange(total_tracks-1):
    X = np.concatenate((X,get_all_frames(data['output']['tracks'][i+1],nodes)),0)
    
# Insert frame size argument
fsize = np.array([data["output"]["resolution"]["height"],data["output"]["resolution"]["width"]])
fsize = np.tile(fsize,(np.size(X,0),1))
X = np.concatenate((fsize,X),1)

# Save json data to csv file
if len(sys.argv) > 2:
    file_name = sys.argv[2]
else:
    file_name = 'fexjsion2datfile.csv'

hdr =','.join(define_hdr())
if len(sys.argv) == 4:
    np.savetxt(file_name, X)
else:
    np.savetxt(file_name, X, delimiter=",",header=hdr,comments="")



