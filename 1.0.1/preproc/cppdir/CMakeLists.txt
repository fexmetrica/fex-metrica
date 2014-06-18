cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0015 NEW)
project(FexFacetUtilities)

find_package(OpenCV)

# ----------- START CHANGES HERE --------------------------------------
#
# Path for FACETMain to the main Facet directory
set(FACETMain "/home/filippo/src/FACETSDK-UBUNTU1204-X64-GCC46")
#
# ----------- END CHANGES HERE ----------------------------------------

set(FACETSDK_DIR  "${FACETMain}/FacetSDK")
message("${FACETMain}/FacetSDK")
set(FACETSDK_LIBS "${FACETMain}/FacetSDK/libs")
set(FACETSDK_INCL "${FACETMain}/FacetSDK/include") 
set(FACETSDK_LICENCE "${FACETMain}/facets/License.c") 
set(FACETSDK_LIBEMOTIENT "${FACETMain}/FacetSDK/lib/libemotient.so")

if (OpenCV_FOUND)
include_directories(${FACETSDK_DIR} ${FACETSDK_INCL} ${OpenCV_INCLUDE_DIRS})
link_directories(${FACETSDK_LIBS})

set(EXECUTABLE_OUTPUT_PATH ../bin)

# FexFacet
add_executable(fexfacet fexfacet.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# FexFace
add_executable(fexface fexface.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexface ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# Face Analyzer code
add_executable(fexfacet_face fexfacet_face.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet_face ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# AU Analyzer code
add_executable(fexfacet_aus fexfacet_aus.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet_aus ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# Emotions Analyzer code
add_executable(fexfacet_emotions fexfacet_emotions.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet_emotions ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# All Chanels Analyzer code
add_executable(fexfacet_full fexfacet_full.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet_full ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

# All Chanels Analyzer code with header (testing)
add_executable(fexfacet_fullh fexfacet_fullh.cpp tools.cpp ${FACETSDK_LICENCE})
target_link_libraries(fexfacet_fullh ${FACETSDK_LIBEMOTIENT} ${OpenCV_LIBS})

endif (OpenCV_FOUND)
