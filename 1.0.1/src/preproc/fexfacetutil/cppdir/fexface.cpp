/**
fexface
  Finde face in a vide
 
  Copiright: Filippo Rossi, Institute for Neural Computation,
  University of California, San Diego.
  
  Contact Info: frossi@ucsd.edu.

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
 
const int   REDFRATE = 1;    /** Desired video sampling rate 1 frame per second **/

/**
 * Helper functions.
 */
void printUsage(){
	std::cout << "Usage:" << std::endl;
	std::cout << "   videoanalysis -f MOVIEFILE [-m MINFACESIZEPCT] [-b STARTFRAME:ENDFRAME] [-o OUTPUTFILE]" << std::endl;
}

// Get cmd line Input


/**
PUT IN TOOLS.CPP 
	THE GET CMD OPTION &
	THE TEST FOR OUTPUT &
	HEADER FILE
	PRINTING RESULTS TO A FILE & 
**/


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
int parseVideoArg(int argc, char *argv[], string& videoFile, float& ReducedFramerate){
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

    // Pick N of frames per second
    if (cmdOptionExists(argv, argv + argc, "-r")) {
     char* redfpsarg = getCmdOption(argv, argv + argc, "-r");
     std::istringstream iss(redfpsarg);
     iss >> ReducedFramerate;
    } else {
     ReducedFramerate = REDFRATE;
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
 

/**
Start main functions for face detection
**/
int main (int argc, char *argv[]){
    int retVal;
    
    // Get command line information or set defaults
    string videoFile;
    int   rate;
    
    retVal = parseVideoArg(argc, argv, videoFile,ReducedFrameRate);
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
	std::cout << "Importing vide with OpenCV ... ";
    cv::VideoCapture videoCap;
    videoCap.open(videoFile);
    if (!videoCap.isOpened()) {
        std::cout << "Could not open video file for processing!" << std::endl;
        exit(FacetSDK::NOT_AVAILABLE);
    }
    std::cout << "Video Imported " << float(clock() - begin_time)/ CLOCKS_PER_SEC << std::endl;
    /** This Section needs to be Changed:
    Determine the number of video frames so that all of them will be processed
    This is faulty OpenCV code so the estimate might be wrong **/
    size_t numtotalframes = videoCap.get(CV_CAP_PROP_FRAME_COUNT);
	IncrementFrameUsed = int(videoCap.get(CV_CAP_PROP_FPS) / ReducedFrameRate);
	videoCap.set(CV_CAP_PROP_POS_FRAMES,0);
	// CONSIDER PREALLOCATING
	// frameanalysis.reserve(numtotalframes); // Pre-allocate
	// Print some info
    std::cout << "Total N of frames in the movie: " << numtotalframes << "; ";
    std::cout << "Analyze: " << numtotalframes << " (Grab 1 frame every " << IncrementFrameUsed << ");\n" << std::endl;
	
	// Define Fram & Gray Frame Matrix
    cv::Mat frame, grayFrame;
    size_t framenum(0);
    
    // Initialize frame analyzer
    FacetSDK::FrameAnalyzer frameAnalyzer;
    frameAnalyzer.SetMaxThreads(4);
    retVal = frameAnalyzer.Initialize(FACETSDIR, "FrameAnalyzerConfig.json");
    if (retVal != FacetSDK::SUCCESS) {
        std::cout << "Could not initialize the FrameAnalyzer" << std::endl;
        std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
        exit(retVal);
    }
	
	/** Deactivate chanels for speed **/ 
    frameAnalyzer.SetChannelActive(FacetSDK::ACTION_UNITS, false);
    frameAnalyzer.SetChannelActive(FacetSDK::EMOTIONS, false);
    frameAnalyzer.SetChannelActive(FacetSDK::POSE, false);
    
    /** Compile the file Header **/
    outfilestream << "FrameNumber" << "\t" << "FrameRows" << "\t" << "FrameCols" << "\t";
	outfilestream << "FaceBoxX" << "\t" << "FaceBoxY" << "\t" << "FaceBoxW" << "\t" << "FaceBoxH" << "\t";
    std::vector<FacetSDK::LandmarkName> lmnames = FacetSDK::AllLandmarkNames();
    for (size_t i = 0; i < lmnames.size(); i++) {
        outfilestream << lmnames[i] <<"_x" << "\t" << lmnames[i] <<"_y" << "\t";
    }
    outfilestream << "\n";

    /** Create some objects that will be updated during frame processing **/
    FacetSDK::FrameAnalysis frameanalysis;

    /** Start Main Loop **/
    const clock_t begin_frame = clock();
    while (framenum < numtotalframes) {
		// This skips frames when required
		if (IncrementFrameUsed > 1){
			videoCap.set(CV_CAP_PROP_POS_FRAMES, framenum);
		}
        
		videoCap.grab();
        videoCap.retrieve(frame);
		
        // Convert the image to grayscale (required)
        cvtColorSafe(frame, grayFrame);
		// Try to process frame
        retVal = frameAnalyzer.Analyze(grayFrame.data, grayFrame.rows, grayFrame.cols,frameanalysis);
        outfilestream << framenum+1 << "\t" << grayFrame.rows << "\t" << grayFrame.cols << "\t";
        if (retVal != FacetSDK::SUCCESS) {
            std::cout << "The frame analyzer could not properly analyze a frame" << std::endl;
            std::cout << "Error code = " << FacetSDK::DefineErrorCode(retVal) << std::endl;
        }
        else{
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
		/** Step to the next frame **/
        framenum = framenum + IncrementFrameUsed;
    }
    outfilestream.close();
}

