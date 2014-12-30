cmake_minimum_required(VERSION 3.0)
#cmake_policy(SET CMP0003 NEW)
cmake_policy(SET CMP0015 NEW)
find_package(OpenCV)
if (OpenCV_FOUND)
include_directories(/Users/filippo/Documents/Emotient/Emotient/FACET/FacetSDK/include ${OpenCV_INCLUDE_DIRS})
include_directories(/Users/filippo/Documents/Emotient/Emotient/FACET/FacetSDK/samples)
link_directories(/Users/filippo/Documents/Emotient/Emotient/FACET/FacetSDK/lib)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")

set(OTHER_FILES tools.cpp /Users/filippo/Documents/Emotient/Emotient/FACET/FacetSDK/facets/License.c)

add_executable(video_2_json video_2_json.cpp ${OTHER_FILES})
target_link_libraries(video_2_json emotient ${OpenCV_LIBS})

endif (OpenCV_FOUND)
