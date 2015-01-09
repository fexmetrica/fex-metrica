cmake_minimum_required(VERSION 3.0)
cmake_policy(SET CMP0015 NEW)
find_package(OpenCV)

set(FACETMAIN "/Users/filippo/src/emotient/Dec2014/FACET/FacetSDK")

if (OpenCV_FOUND)

set(EXECUTABLE_OUTPUT_PATH ..)

include_directories("${FACETMAIN}/include" ${OpenCV_INCLUDE_DIRS})
include_directories("${FACETMAIN}/samples")
link_directories("${FACETMAIN}/lib")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")

set(OTHER_FILES tools.cpp "${FACETMAIN}/facets/License.c")

add_executable(fexfacetexec fexfacetexec.cpp ${OTHER_FILES})
target_link_libraries(fexfacetexec emotient ${OpenCV_LIBS})

endif (OpenCV_FOUND)
