/**
 file fexcrop.cpp
 This function uses the Emotient SDK, and OpenCv to read a
 prespecified number of frames in a video (e.g. 1 per second), 
 at a reduce quality factor (reduction 0.00-100.00%), and finds
 the largest face in the video. The function saves the face
 coordinates for the selected frames, and it can generate an 
 high quality video output using only the cropped area. 
 
  Copiright: Filippo Rossi, Institute for Neural Computation,
  University of California, San Diego.
  
  Contact Info: frossi@ucsd.edu.




Videofile -i string withe the path to a file (i.e. a video) or the 
pattern to a file, s.a. "path_to_file/img%8d.jpg";


Framerate (Do you want to skip any frame?) -r int
Chanels   -w:c string ('face','emotions','aus','all')
Outputfile -o string

IMPORTANT: COMPUTE CROPPING MULTIPLICATIVE FACTOR!!!!

**/


#include <opencv2/opencv.hpp>
#include <iostream>
#include <algorithm>
#include <fstream>
#include <time.h>
#include "emotient.hpp"
#include "tools.hpp"
#include "config.hpp"
 
using namespace std;
using namespace EMOTIENT;
 
const float QSCALE    = 0.00; /**< Quality scaling factor: 0.00 = best quality; 1.00 = worst**/
const int   SAMPLRATE = 1;    /** < Desired video sampling rate 1 = all available frames**/
const int   CHANELS   = 1; /** Chanels to be used **/
const float MINFACESIZEPCT = .05; /**< The minimum facebox size to search, as percentage of image width */

/** Start Utilities Functions ++++++++++++++++++++++++++++++++++++++++++++ **/

/**
 * Helper function to alert the user how the application should be called from the command-line.
 */
void printUsage(){
	std::cout << "Usage:" << std::endl;
	std::cout << "   videoanalysis -f MOVIEFILE [-m MINFACESIZEPCT] [-b STARTFRAME:ENDFRAME] [-o OUTPUTFILE]" << std::endl;
	std::cout << "   - The required -f MOVIEFILE argument must be an absolute path to an opencv supported video file." << std::endl;
    std::cout << "   - The optional [-m MINFACESIZEPCT] argument is a floating point percentage between 0 and 1." << std::endl;
    std::cout << "     (defaults to .05)" << std::endl;
    std::cout << "   - The optional [-b STARTFRAME:ENDFRAME] argument specifies start:end frames for baselining intensity." << std::endl;
    std::cout << "     (if not specified, does not output intensity at all)" << std::endl;
    std::cout << "   - The optional [-o OUTPUTFILE] argymebt specifies an output CSV file." << std::endl;
	std::cout << std::endl;
	std::cout << "Output:" << std::endl;
    std::cout << "   - Prints to screen the average emotion outputs at regular intervals while processing the video." << std::endl;
	std::cout << "   - Prints a CSV-formatted set of video analyzed emotion outputs to screen (or to file if OUTPUTFILE is specified.)" << std::endl;
}

// Get cmd line Input
char* getCmdOption(char ** begin, char ** end, const std::string & option){
    char ** itr = std::find(begin, end, option);
    if (itr != end && ++itr != end)
    {
        return *itr;
    }
    return 0;
}

/** CMD LINE **/
bool cmdOptionExists(char** begin, char** end, const std::string& option)
{
    return std::find(begin, end, option) != end;
}


 // Check cmd line Imput
int parseVideoArg(int argc, char *argv[], string& videoFile, float& QualityScale, int& ChanelsList, float&minFaceSizePct){
    int retVal(FacetSDK::SUCCESS);

    // Check that the video input file was passed
    if(argc < 2){
     return(FacetSDK::EMPTY_INPUT);
    }

    // Get the video filepath
    char* videoarg = getCmdOption(argv, argv + argc, "-v");
    if(videoarg == 0){
     return(FacetSDK::EMPTY_INPUT);
    }
    videoFile = videoarg;

    // Set quality scaling -- Not currently in use
    if (cmdOptionExists(argv, argv + argc, "-q")) {
     char* qscalearg = getCmdOption(argv, argv + argc, "-q");
     std::istringstream iss(qscalearg);
     iss >> QualityScale;
    } else {
     QualityScale = QSCALE;
    }

    // Get chanels list
    if (cmdOptionExists(argv, argv + argc, "-c")) {
     char* chanelarg = getCmdOption(argv, argv + argc, "-c");
     std::istringstream iss(chanelarg);
     iss >> ChanelsList;
    } else {
     ChanelsList = CHANELS;
    }
    
    
    // Set the minimum facebox size
    if (cmdOptionExists(argv, argv + argc, "-m")) {
        char* minsizearg = getCmdOption(argv, argv + argc, "-m");
        std::istringstream iss(minsizearg);
        iss >> minFaceSizePct;
    } else {
        minFaceSizePct = MINFACESIZEPCT;
    }
    
    
     return retVal;
 }
 
 /** Get Output File **/
void parseOutputArg(int argc, char *argv[], string& outfile){
    bool outfilepassed = cmdOptionExists(argv, argv + argc, "-o");
    if (outfilepassed) {
        char* outputarg = getCmdOption(argv, argv + argc, "-o");
        outfile = outputarg;
    } else outfile = "";
}
 

int main (int argc, char *argv[]){
    int retVal;
    
    // Get command line information or set defaults
    string videoFile;
    float QualityScale(QSCALE);
    int   ChanelsList;
    float minFaceSizePct(MINFACESIZEPCT);
    
    retVal = parseVideoArg(argc, argv, videoFile, QualityScale, ChanelsList,minFaceSizePct);
    if (retVal != FacetSDK::SUCCESS) {
        printUsage();
        exit(retVal);
    }
    
    // Create the output stream either as a file or STDOUT depending on argument
    string outFile;
    parseOutputArg(argc, argv, outFile);
    std::ofstream outfilestream;
    if(!outFile.empty()){
        char* outputarg = getCmdOption(argv, argv + argc, "-o");
        outfilestream.open(outputarg, ios::out);
    }
    ostream& outstream = (!outFile.empty() ? outfilestream : std::cout);
    
    // Start Clock
    const clock_t begin_time = clock();

    // Load the video into OpenCV's capture object and exit if it fails
    cv::VideoCapture videoCap;
    videoCap.open(videoFile);
    if (!videoCap.isOpened()) {
        std::cout << "Could not open video file for processing!" << std::endl;
        exit(FacetSDK::NOT_AVAILABLE);
    }
    /** Determine the minimum-size facebox to search based on user-configured minFaceSizePct **/
    float imageWidth = videoCap.get(CV_CAP_PROP_FRAME_WIDTH);
    float minFaceWidth = minFaceSizePct * imageWidth;
    
    cv::Mat frame, grayFrame;
    size_t framenum(0);
    
    // Initialize frame analyzer
    FacetSDK::FrameAnalyzer frameAnalyzer;
    frameAnalyzer.SetMaxThreads(8);
    retVal = frameAnalyzer.Initialize(FACETSDIR, "FrameAnalyzerConfig.json");
    if (retVal != FacetSDK::SUCCESS) {
        std::cout << "Could not initialize the FrameAnalyzer" << std::endl;
        std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
        exit(retVal);
    }
    retVal = frameAnalyzer.SetMinFaceDetectionWidth(minFaceWidth);
    std::cout << "min face size = " << minFaceWidth << std::endl;

    /** Activate or deactivate chanels for the analysis 
        1 = All features -- no deactivation required
        2 = All emotions -- deactivate action Units
        3 = Action units only
        4 = Facial landmarks and pose (deactivate all)
    **/
    
    if (ChanelsList == 2){
        frameAnalyzer.SetChannelActive(FacetSDK::ACTION_UNITS, false);
    }
    else if (ChanelsList == 3){
        std::cout << "Deactivating Emotions" << std::endl;
        frameAnalyzer.SetChannelActive(FacetSDK::PRIMARY_EMOTIONS, false);
        frameAnalyzer.SetChannelActive(FacetSDK::SENTIMENTS, false);
        frameAnalyzer.SetChannelActive(FacetSDK::ADVANCED_EMOTIONS, false);
    }
    else if (ChanelsList == 4){
        std::cout << "Deactivating All" << std::endl;
        frameAnalyzer.SetChannelActive(FacetSDK::ACTION_UNITS, false);
        frameAnalyzer.SetChannelActive(FacetSDK::PRIMARY_EMOTIONS, false);
        frameAnalyzer.SetChannelActive(FacetSDK::SENTIMENTS, false);
        frameAnalyzer.SetChannelActive(FacetSDK::ADVANCED_EMOTIONS, false);
    }
    else{
        std::cout << "Using All" << std::endl;
    }
    
    
    /** Compile the file Header **/
    outfilestream << "FrameNumber" << "\t" << "FrameRows" << "\t" << "FrameCols" << "\t";
	outfilestream << "FaceBoxX" << "\t" << "FaceBoxY" << "\t" << "FaceBoxW" << "\t" << "FaceBoxH" << "\t";
    std::vector<FacetSDK::LandmarkName> lmnames = FacetSDK::AllLandmarkNames();
    for (size_t i = 0; i < lmnames.size(); i++) {
        outfilestream << lmnames[i] <<"_x" << "\t" << lmnames[i] <<"_y" << "\t";
    }
    outfilestream << "Roll" << "\t" << "Pitch" << "\t" << "Yaw" << "\t";
    if (frameAnalyzer.IsChannelActive(FacetSDK::PRIMARY_EMOTIONS)) {
        std::vector<FacetSDK::EmotionName> emotionNames = FacetSDK::AllPrimaryEmotionNames();
        for (size_t i = 0; i < emotionNames.size(); i++) {
            outfilestream << emotionNames[i] << "\t";
        }
     }
    if (frameAnalyzer.IsChannelActive(FacetSDK::SENTIMENTS)) {
       std::vector<FacetSDK::EmotionName> SentNames = FacetSDK::AllSentimentEmotionNames();
       for (size_t i = 0; i < SentNames.size(); i++) {
           outfilestream << SentNames[i] << "\t";
       }
    }
    if (frameAnalyzer.IsChannelActive(FacetSDK::ADVANCED_EMOTIONS)) {
        std::vector<FacetSDK::EmotionName> AdveEmoNames = FacetSDK::AllAdvancedEmotionNames();
        for (size_t i = 0; i < AdveEmoNames.size(); i++) {
            outfilestream << AdveEmoNames[i] << "\t";
        }
     }
    if (frameAnalyzer.IsChannelActive(FacetSDK::ACTION_UNITS)) {
        std::vector<FacetSDK::ActionUnit> auNames = FacetSDK::AllActionUnits();
        for (size_t i = 0; i < auNames.size(); i++) {
            outfilestream << auNames[i] << "\t";
        }
     }
    outfilestream << "\n";


    /** Create some objects that will be updated during frame processing **/
    FacetSDK::FrameAnalysis frameanalysis;
    
    
    /** This Section needs to be Changed:
    Determine the number of video frames so that all of them will be processed
    This is faulty OpenCV code so the estimate might be wrong **/
    size_t numtotalframes = videoCap.get(CV_CAP_PROP_FRAME_COUNT);
//    frameanalysis.reserve(numtotalframes); // Pre-allocate
    std::cout << "Total n of frames: " << numtotalframes << std::endl;


    /** Start Main Loop **/
    const clock_t begin_frame = clock();
    videoCap.set(CV_CAP_PROP_POS_FRAMES, 0); // start at frame 0 of video
//    while (videoCap.grab() && videoCap.retrieve(frame)) {
    while (framenum < numtotalframes) {
        videoCap.grab();
        videoCap.retrieve(frame);
        // Process frame
        // Convert the image to grayscale (required)
        cvtColorSafe(frame, grayFrame);
        retVal = frameAnalyzer.Analyze(grayFrame.data, grayFrame.rows, grayFrame.cols,frameanalysis);
        if (retVal != FacetSDK::SUCCESS) {
            std::cout << "The frame analyzer could not properly analyze a frame" << std::endl;
            std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
//            exit(retVal);
        }
        else{
        // Print resuts to a file
            // Frame Number and image size
            outfilestream << framenum+1 << "\t" << grayFrame.rows << "\t" << grayFrame.cols << "\t";
            if (frameanalysis.NumFaces() > 0) {
                // Analyze the largest face
                FacetSDK::Face face;
                frameanalysis.LargestFace(face);
                FacetSDK::Rectangle faceLocation;
                face.FaceLocation(faceLocation);
                // Print out detected face box coordinates for largest face
                outfilestream << faceLocation.x << "\t" << faceLocation.y <<"\t" << faceLocation.width << "\t" << faceLocation.height << "\t";
                // Add Landmarks Score
                std::vector<FacetSDK::LandmarkName> lmnames = FacetSDK::AllLandmarkNames();
                for (size_t i = 0; i < lmnames.size(); i++) {
                    outfilestream << face.LandmarkLocation(lmnames[i]).x <<"\t";
                    outfilestream << face.LandmarkLocation(lmnames[i]).y <<"\t";
                }
                // Add Head Pose Information
                if (frameAnalyzer.IsChannelActive(FacetSDK::POSE)) {
                    outfilestream << face.PoseValue(FacetSDK::ROLL) <<"\t";
                    outfilestream << face.PoseValue(FacetSDK::PITCH) <<"\t";
                    outfilestream << face.PoseValue(FacetSDK::YAW);
                }
                // Add Primary Emotions if the Chanel is Available
                if (frameAnalyzer.IsChannelActive(FacetSDK::PRIMARY_EMOTIONS)) {
                    std::vector<FacetSDK::EmotionName> emotionNames = FacetSDK::AllPrimaryEmotionNames();
                    for (size_t i = 0; i < emotionNames.size(); i++) {
                        outfilestream << "\t" << face.EmotionValue(emotionNames[i]);
                    }
                }
                // Add Sentiments
                if (frameAnalyzer.IsChannelActive(FacetSDK::SENTIMENTS)) {
                    std::vector<FacetSDK::EmotionName> SentNames = FacetSDK::AllSentimentEmotionNames();
                    for (size_t i = 0; i < SentNames.size(); i++) {
                        outfilestream <<  "\t" << face.EmotionValue(SentNames[i]);
                    }
                }
                // Advance Emotions
                if (frameAnalyzer.IsChannelActive(FacetSDK::ADVANCED_EMOTIONS)) {
                    std::vector<FacetSDK::EmotionName> AdveEmoNames = FacetSDK::AllAdvancedEmotionNames();
                    for (size_t i = 0; i < AdveEmoNames.size(); i++) {
                        outfilestream << "\t" << face.EmotionValue(AdveEmoNames[i]);
                    }
                }
                // Action Units
                if (frameAnalyzer.IsChannelActive(FacetSDK::ACTION_UNITS)) {
                    std::vector<FacetSDK::ActionUnit> auNames = FacetSDK::AllActionUnits();
                    for (size_t i = 0; i < auNames.size(); i++) {
                        outfilestream << "\t" << face.ActionUnitValue(auNames[i]);
                    }
                }
            }
            else{
                outfilestream << "Nan";
            }
            outfilestream << "\n";
        }

        /** Print out progress at regular intervals **/
        if ((framenum+1) % 10 == 0) {
            int pctComplete = 100.0 * framenum / numtotalframes; // update progress
            std::cout << "Percent complete: " << pctComplete << '%'<< "\t";
            std::cout << "Time Elapsed: " << float( clock () - begin_time ) /  CLOCKS_PER_SEC << "\t";
            std::cout << "Frames per second: " << int(framenum/ ((clock () - begin_frame)/  CLOCKS_PER_SEC)) << std::endl;
        }
        framenum++;
    }
    outfilestream.close();
}

