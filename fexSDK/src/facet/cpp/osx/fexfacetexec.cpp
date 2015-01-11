/**
 * \file video_2_json.cpp
 *
 * \brief Demo program reads in a video and produces a JSON output representing all faces found in the video.
 *
 * Usage:
 *		video_2_json -f <VIDEONAME> -o <OUTPUTNAME>
 *      - VIDEONAME is a required argument. Must be a string file name containing the video.
 *      - OUTPUTNAME is a required argument. Must be a string file name to write the output JSON to.
 *
 * Output:
 *		JSON file containing a listing of all tracks(each track is a single face over time), with all frames in
 *			which it appeared and the Emotient channel output for each frame. Note that this is in track-order.
 *
 * Copyright © 2014 Emotient, Inc. All rights reserved.
 * Use, publication or distribution of Emotient content is prohibited without the prior written consent of Emotient.
 * Any permitted activity or inactivity is subject to Emotient's Terms of Use.
 */

#include <iomanip>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sstream>
#include <fstream>
#include <time.h>
#include <opencv2/opencv.hpp>
#include <emotient.hpp>
#include <json/json.h>
#include "config.hpp"
#include "tools.hpp"

const int FILE_NOT_FOUND = -3;              ///< The specified file could not be found.
const int INITIALIZATION_ERROR = -5;        ///< Could not initialize the object.

using namespace std;
using namespace cv;
using namespace EMOTIENT;

const float MILLIS_PER_SEC = 1000.0;
const float DEFAULT_IMAGE_SCALE_FACTOR = 1.;
const int DEFAULT_MAX_FRAMES = 100000;
const int DEFAULT_MIN_SIZE = 50;
const int DEFAULT_NUM_TRACKS = 10;

//Prepare the video to be played
int
InitVideo(cv::VideoCapture& videoCap, double& startVideoTime, double& endVideoTime, double& latestVideoTime){
    if( !videoCap.isOpened() ){
        return INITIALIZATION_ERROR;
    } else {
        videoCap.set(CV_CAP_PROP_POS_AVI_RATIO, 1);  // Determine length of movie by finding end
        endVideoTime = videoCap.get(CV_CAP_PROP_POS_MSEC) / MILLIS_PER_SEC;
        videoCap.set(CV_CAP_PROP_POS_AVI_RATIO, 0);  // rewind to start of video
        startVideoTime = videoCap.get(CV_CAP_PROP_POS_MSEC) / MILLIS_PER_SEC;
        latestVideoTime = startVideoTime;
        videoCap.set(CV_CAP_PROP_POS_FRAMES, 0); // start at frame 0 of video
        return FacetSDK::SUCCESS;
    }
}

bool
PrepNextFrame(const double& endVideoTime, const int resize, cv::VideoCapture& videoCap, cv::Mat& frame, size_t& frameNumber, double& latestVideoTime){
    bool retVal(true);
    retVal = videoCap.grab();
    if(retVal){
        retVal = videoCap.retrieve(frame);
        if(retVal){
            frameNumber += 1;
            cv::resize(frame, frame, cv::Size(frame.cols/resize, frame.rows/resize));
            double videoTime = videoCap.get(CV_CAP_PROP_POS_MSEC) / MILLIS_PER_SEC;
            if (videoTime < latestVideoTime) {
                retVal = false;  // we've started over again (this sometimes happens with VideoCap); break
            } else if (videoTime > endVideoTime) {
                retVal = false;  // reachedend of video
            }
            latestVideoTime = videoTime;
        }
    }
    return retVal;
}

/**
 * Helper function to extract a command-line argument
 */
char* getCmdOption(char ** begin, char ** end, const std::string & option){
    char ** itr = std::find(begin, end, option);
    return (itr != end && ++itr != end) ? *itr : 0;
}

/**
 * Helper function to check whether a command-line argument was passed. Used for optional output file.
 */
bool cmdOptionExists(char** begin, char** end, const std::string& option){
    return std::find(begin, end, option) != end;
}

/**
 * Check and parse command line arguments
 */
int parseVideoArg(int argc, char *argv[], string& videoFile, int& maxFrames, int& minSize, int& resize, string& outputfile){
    int retVal(FacetSDK::SUCCESS);

    // Check that proper arguments were passed to command-line
    if(argc < 2){
        return(FacetSDK::EMPTY_INPUT);
    }

    // Get the *required* video filepath
    char* videoarg = getCmdOption(argv, argv + argc, "-f");
    if(videoarg == 0){
        std::cerr << "ERROR: -f input video file name REQUIRED" << std::endl;
        return(FacetSDK::EMPTY_INPUT);
    }
    videoFile = videoarg;
    
    // Get the *required* output filepath
    char* outputfilearg = getCmdOption(argv, argv + argc, "-o");
    if(outputfilearg == 0){
        std::cerr << "ERROR: -o output file name REQUIRED" << std::endl;
        return(FacetSDK::EMPTY_INPUT);
    }
    outputfile = outputfilearg;
    
    // Set the optional max number of frames to process
    maxFrames = DEFAULT_MAX_FRAMES;
    if (cmdOptionExists(argv, argv + argc, "-m")) {
        char* maxFramesArg = getCmdOption(argv, argv + argc, "-m");
        std::istringstream iss(maxFramesArg);
        iss >> maxFrames;
    }
    
    // Set the optional minimum facebox size in pixels
    minSize = DEFAULT_MIN_SIZE;
    if (cmdOptionExists(argv, argv + argc, "-s")) {
        char* minSizeArg = getCmdOption(argv, argv + argc, "-s");
        std::istringstream iss(minSizeArg);
        iss >> minSize;
    }

    // Set the optional image resize scale factor, an integer - divide the size by this.
    resize = DEFAULT_IMAGE_SCALE_FACTOR;
    if (cmdOptionExists(argv, argv + argc, "-r")) {
        char* resizeArg = getCmdOption(argv, argv + argc, "-r");
        std::istringstream iss(resizeArg);
        iss >> resize;
    }
    
    return retVal;
}

int SerializeTracksToJSON(const std::string& outputFileName,
                        std::vector<EMOTIENT::FacetSDK::VideoAnalysisPtr> &tracks,
                        std::vector<double> &frameTimes,
                        int &width,
                        int &height) {
    int retVal(0);
    EMOTIENT::FacetSDK::VideoAnalysisPtr track;
    std::ofstream fid(outputFileName.c_str());
    if(!fid){
        std::cout << "ERROR -- WriteFile could not open JSON file " << outputFileName << std::endl;
        exit(-1);
    }
    
    Json::Value root;
    Json::Value &joutput = root["output"];
    
    // First insert frametimes vector
    Json::Value &jframetimes = joutput["frametimes"];
    for (size_t i(0); i < frameTimes.size(); ++i) {
        jframetimes.append(frameTimes[i]);
    }
    
    // Now insert a resolution dict
    joutput["resolution"]["height"] = height;
    joutput["resolution"]["width"] = width;
    
    // Next build and insert tracks vector
    Json::Value &jtracks = joutput["tracks"];
    for(size_t tracknum(0); tracknum < tracks.size(); ++tracknum){
        Json::Value jtrack;
        Json::Value &jframes = jtrack["frames"];
        std::vector<float> frameTimesVec;
        std::vector<bool> isFacePresentVec;
        std::vector<FacetSDK::Rectangle> faceLocationsVec;
        std::map< FacetSDK::EmotionName, std::vector<float> > emotionEvidenceMap;
        std::map< FacetSDK::ActionUnitEnum, std::vector<float> > actionunitMap;
        std::map< FacetSDK::DemographicName, std::vector<float> > demographicEvidenceMap;
        std::map< FacetSDK::LandmarkName, std::vector<FacetSDK::Point> > landmarkPointsMap;
        std::map< FacetSDK::PoseDimension, std::vector<float> > poseMap;

        // Pull out all the frames per track
        track = tracks[tracknum];
        track->FrameTimes(frameTimesVec);
        track->IsFacePresent(isFacePresentVec);
        track->FaceLocations(faceLocationsVec);

        // Grab the names of all channels
        std::vector<FacetSDK::EmotionName> allEmotions(FacetSDK::AllEmotionNames());
        std::vector<FacetSDK::ActionUnitEnum> allActionUnits(FacetSDK::AllActionUnits());        
        std::vector<FacetSDK::LandmarkName> allLandmarks(FacetSDK::AllLandmarkNames());
        std::vector<FacetSDK::DemographicName> allDemographics(FacetSDK::AllDemographicNames());
        std::vector<FacetSDK::PoseDimension> allPoseDimensions(FacetSDK::AllPoseDimensions());

        // Store evidence for each emotion
        for(std::vector<FacetSDK::EmotionName>::const_iterator emotion = allEmotions.begin(); emotion != allEmotions.end(); ++emotion) {
        	track->EmotionEvidence(*emotion,emotionEvidenceMap[*emotion]);
        }
        
        // Store evidence for each AU
        for(std::vector<FacetSDK::ActionUnitEnum>::const_iterator au = allActionUnits.begin(); au != allActionUnits.end(); ++au) {
        	track->ActionUnitEvidence(*au,actionunitMap[*au]);
        }

        // Store evidence for each demographic
        for(std::vector<FacetSDK::DemographicName>::const_iterator demographic = allDemographics.begin(); demographic != allDemographics.end(); ++demographic) {
        	track->DemographicEvidence(*demographic, demographicEvidenceMap[*demographic]);
        }

        // Store evidence for each landmark
        for(std::vector<FacetSDK::LandmarkName>::const_iterator landmark = allLandmarks.begin(); landmark != allLandmarks.end(); ++landmark) {
        	track->LandmarkLocations(*landmark, landmarkPointsMap[*landmark]);
        }

        // Store each pose dimension
        for(std::vector<FacetSDK::PoseDimension>::const_iterator poseDimension = allPoseDimensions.begin(); poseDimension != allPoseDimensions.end(); ++poseDimension) {
			track->Pose(*poseDimension, poseMap[*poseDimension]);
        }
        
        // Add frames into frames slot of track dictionary
        for (size_t framenum(0); framenum < isFacePresentVec.size(); ++framenum) {
            bool isFacePresent = isFacePresentVec[framenum];
            // add frame to JSON if frame contains one or more faces
            if (isFacePresent == true) {
                Json::Value jframe;
                jframe["timestamp"] = frameTimesVec[framenum];
                jframe["face-location"]["x"] = faceLocationsVec[framenum].x;
                jframe["face-location"]["y"] = faceLocationsVec[framenum].y;
                jframe["face-location"]["width"] = faceLocationsVec[framenum].width;
                jframe["face-location"]["height"] = faceLocationsVec[framenum].height;
                jframe["demographic-evidence"]["isMale"] = demographicEvidenceMap[FacetSDK::IS_MALE][framenum];
                // Store pose data in JSON
                for (std::map< FacetSDK::PoseDimension, std::vector<float> >::iterator it = poseMap.begin();
                     it != poseMap.end(); ++it) {
                    std::string posenamestr = FacetSDK::PoseDimensionToString(it->first);
                	jframe["pose"][posenamestr] = it->second[framenum];
                }
                // Store emotion data in JSON
                for (std::map< FacetSDK::EmotionName, std::vector<float> >::iterator it = emotionEvidenceMap.begin();
                     it != emotionEvidenceMap.end(); ++it) {
                    std::string emonamestr = FacetSDK::EmotionNameToString(it->first);
                    jframe["emotion-evidence"][emonamestr] = it->second[framenum];;
                }
                // Store AUs
                for (std::map< FacetSDK::ActionUnitEnum, std::vector<float> >::iterator it = actionunitMap.begin();
                     it != actionunitMap.end(); ++it) {
                    std::string aunamestr = FacetSDK::ActionUnitToString(it->first);
                    jframe["au-evidence"][aunamestr] = it->second[framenum];;
                }
                
                // Store landmark data in JSON
                for (std::map< FacetSDK::LandmarkName, std::vector<FacetSDK::Point> >::iterator it = landmarkPointsMap.begin();
                     it != landmarkPointsMap.end(); ++it) {
                    std::string landmarknamestr = FacetSDK::LandmarkNameToString(it->first);
                    jframe["landmarks"][landmarknamestr]["x"] = it->second[framenum].x;
                    jframe["landmarks"][landmarknamestr]["y"] = it->second[framenum].y;
                }
                jframes.append(jframe);
            }
        }
        
        // Add a track to the tracks
        jtracks.append(jtrack);
    }
    
    if( root.size() == 0)
        fid << "{}" ;
    else
        fid << root;
    fid.close();
    return retVal;
}

/**
 * Application entry point
 * @param argc is number of arguments
 * @param argv is array of pointers to argument strings
 */
int main(int argc, char* argv[]) {
#ifdef _WIN32
	FacetSDK::InitializeLicensing(FACET);  // Necessary only with Windows; call before any other FACET call
#endif
    int retVal(0);
    string videoFile(""), outputfile("");
    int maxFrames, minSize, resize;
    if( FacetSDK::SUCCESS != (retVal = parseVideoArg(argc, argv, videoFile, maxFrames, minSize, resize, outputfile))){
        return retVal;
    }
    
    // Load the video into OpenCV's capture object and exit if it fails
    cv::VideoCapture videoCap;
    videoCap.open(videoFile);
    if (!videoCap.isOpened()) {
        std::cout << "Could not open video file for processing" << std::endl;
        retVal = -7;
    } else {

        double startVideoTime(0), endVideoTime(0), latestVideoTime(0);
        InitVideo(videoCap, startVideoTime, endVideoTime, latestVideoTime);
        
        // Prepare the tracking manager
        FacetSDK::SpatialTrackingManagerPtr tracker;
        
        if (FacetSDK::TrackerFactory::GetSpatialTracker(tracker, FACETSDIR, "TrackerConfig.json") != FacetSDK::SUCCESS) {
            std::cout << "Could not load tracker params" << std::endl;
            retVal = -8;
        } else {
            // Always enable background subtraction
            tracker->SetBackgroundModelActive(true);
            tracker->SetChannelActive(FacetSDK::ACTION_UNITS, true);
            tracker->SetChannelActive(FacetSDK::LANDMARKS, true);
                
            // Now start running on frames to create the graph
            tracker->SetMaxThreads(cv::getNumberOfCPUs());
            tracker->SetMinFaceSize(minSize);
            cv::Mat frame, grayFrame;
            size_t frameNumber(0);
            std::vector<double> frameTimes;
            while (PrepNextFrame(endVideoTime, resize, videoCap, frame, frameNumber, latestVideoTime) && (int)frameNumber < maxFrames)
            {
                //add frame to tracker
            	cvtColorSafe(frame, grayFrame);
                tracker->AddFrame(grayFrame.data,grayFrame.rows,grayFrame.cols, FacetSDK::TrackerMetaData(latestVideoTime));
                frameTimes.push_back(latestVideoTime);
                std::cout<<"."<<std::flush;
            }
            std::cout<<std::endl;

            // do the tracking and get the results
            std::vector<EMOTIENT::FacetSDK::VideoAnalysisPtr> tracks;
            retVal = tracker->CreateTracks(tracks);
            if (retVal == 0) {
                // Serialize the tracks to JSON
                SerializeTracksToJSON(outputfile, tracks, frameTimes, grayFrame.cols, grayFrame.rows);
            } else {
                std::cerr << "Tracker failed to CreateTracks with error code " << retVal << std::endl;
            }
        }
    }
    exit(retVal);
}
