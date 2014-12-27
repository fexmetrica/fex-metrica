#! /bin/bash

# Move to the directory with c++ code
cd cppdir

# clean installation
# rm -r build
# rm -r bin

if [ ! -d "build"  ]; then
  mkdir build && mkdir bin
fi

# Move to building directory
cd build

# Configure and make files
echo ""
cmake -G "Unix Makefiles" ..
make
