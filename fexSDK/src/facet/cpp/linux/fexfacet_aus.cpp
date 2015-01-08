
/* This code was adapted from the sample files provided in the Emotient SDK
and it is meant to work within the toolbox fex-metrica.
fexfacet_aus output the following variables: 

(1) File information (filename; file_width; file_hight);
(2) Landmarks locations (TopLeft_X; TopLeft_Y; Width; Height;
    left_eye_lateral_X; left_eye_lateral_Y; left_eye_pupil_X; left_eye_pupil_Y;
    left_eye_medial_X; left_eye_medial_Y; right_eye_medial_X;right_eye_medial_Y;
    right_eye_pupil_X; right_eye_pupil_Yl; right_eye_lateral_X; right_eye_lateral_Y
    nose_tip_X; nose_tip_Y);
(3) Pose information (Roll; Pitch; Yaw);
(4) Action Units (AU1; AU2; AU4; AU5; AU6; AU7; AU9; AU10; AU12; AU14;
    AU15; AU17; AU18; AU20; AU23; AU24; AU25; AU26; AU28).

-- version 06/01/2014

Code adapted by 
Filippo Rossi, Institute for Neural Computation,
University of California San Diego.
Contact info: frossi@ucsd.edu */


#include <opencv2/opencv.hpp>
#include <iostream>
#include "config.hpp"
#include "tools.hpp"
#include "emotient.hpp"

int main ()
{
    using namespace EMOTIENT;

    int retVal;
    // Initialize the frame analysis engine
    FacetSDK::FrameAnalyzer frameAnalyzer;
    frameAnalyzer.SetMaxThreads(4);
    retVal = frameAnalyzer.Initialize(FACETSDIR, "FrameAnalyzerConfig.json");
    
    if (retVal != FacetSDK::SUCCESS) {
        std::cout << "Could not initialize the FrameAnalyzer" << std::endl;
        std::cout << "Check that FACETSDIR is pointing to the correct location relative to the working directory." << std::endl;
        std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
        exit(retVal);
    }


    while (std::cin.good()) {
        std::string filename;
        std::cin >> filename;
        cv::Mat frame = cv::imread(filename);
        if(frame.rows == 0 || frame.cols == 0){
            std::cout << "file " << filename << " could not be opened as an image." << std::endl;
        }
        else {
            // Convert the image to grayscale (required)
            cv::Mat grayFrame;
            cvtColorSafe(frame, grayFrame);
            std::cout << filename << "\t" << grayFrame.rows << "\t" << grayFrame.cols << "\t";
            FacetSDK::FrameAnalysis frameAnalysis;
            frameAnalyzer.Analyze(grayFrame.data, grayFrame.rows, grayFrame.cols, frameAnalysis);
            if (frameAnalysis.NumFaces() > 0) {
                // Analyze the largest face
                FacetSDK::Face face;
                frameAnalysis.LargestFace(face);
                FacetSDK::Rectangle faceLocation;
                face.FaceLocation(faceLocation);
                // Print out detected face box coordinates for largest face
                std::cout << faceLocation.x << "\t" << faceLocation.y <<
                         "\t" << faceLocation.width << "\t" << faceLocation.height << "\t";
            //Landmarks
            if (frameAnalyzer.IsChannelAvailable(FacetSDK::LANDMARKS)) {
                    std::vector<FacetSDK::LandmarkName> lmnames = FacetSDK::AllLandmarkNames();
                    for (size_t i = 0; i < lmnames.size(); i++) {
                        std::cout << face.LandmarkLocation(lmnames[i]).x <<"\t";
                        std::cout << face.LandmarkLocation(lmnames[i]).y <<"\t";
                    }
                }
            //Head Pose
            if (frameAnalyzer.IsChannelAvailable(FacetSDK::POSE)) {
                    std::cout << face.PoseValue(FacetSDK::ROLL) <<"\t";
                    std::cout << face.PoseValue(FacetSDK::PITCH) <<"\t";
                    std::cout << face.PoseValue(FacetSDK::YAW);
                }

            // Action Units
            if (frameAnalyzer.IsChannelAvailable(FacetSDK::ACTION_UNITS)) {
                std::vector<FacetSDK::ActionUnit> auNames = FacetSDK::AllActionUnits();
                for (size_t i = 0; i < auNames.size(); i++) {
                    std::cout << "\t" << face.ActionUnitValue(auNames[i]);
                }
            }
            
            std::cout << std::endl;
            }
            else {
            std::cout << nan << std::endl;
        }
        }
    }
}
