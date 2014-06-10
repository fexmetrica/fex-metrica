#include "tools.hpp"

/**
 * Converts the specified image to grayscale; if the image
 * is already grayscale, then simply return (by reference) the input image.
 * This function is provided because attempting to call cvtColor()
 * on an image that is already grayscale will trigger an exception.
 * \param image the image to convert
 * \param grayImage the image converted to grayscale
 */
void cvtColorSafe (const cv::Mat &image, cv::Mat &grayImage)
{
	if (image.channels() > 1) {
		// Color image, so we need to convert it
		cvtColor(image, grayImage, CV_BGR2GRAY);
	} else {
		// Already grayscale, so no need to convert
		grayImage = image;
	}
}
