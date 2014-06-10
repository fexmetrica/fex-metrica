#! /bin/bash

# Move to the directory with c++ code
cd cppdir

# clean installation
rm -r build
rm -r bin

# Move to building directory
mkdir build && mkdir bin
cd build

# Configure and make files
echo ""
cmake -G "Unix Makefiles" ..
make
