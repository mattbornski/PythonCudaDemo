#!/bin/bash

nvcc -V 1>/dev/null 2>&1
if [ ! "$?" == "0" ] ; then
  echo "Install the CUDA SDK first."
  echo "https://developer.nvidia.com/cuda-downloads"
  echo ""
  echo "If you believe you have installed the CUDA SDK, make sure nvcc is on your PATH"
  exit 1
fi

brew install hg

pip install nose numpy gnumpy

hg clone https://cudamat.googlecode.com/hg/ cudamat
pushd cudamat
make
python test_cudamat.py
if [ ! "$?" == "0" ] ; then
  PYTHON_ARCH=$(lipo -info `which python` | grep -oE "architecture: [0-9a-z_]+" | cut -d: -f2 | tr -d " ")
  echo $PYTHON_ARCH
  
  CUDAMAT_ARCH=$(lipo -info libcudamat.so | grep -oE "architecture: [0-9a-z_]+" | cut -d: -f2 | tr -d " ")
  echo $CUDAMAT_ARCH
  
  if [ ! "$PYTHON_ARCH" == "$CUDAMAT_ARCH" ] ; then
    if [ "$PYTHON_ARCH" == "x86_64" ] ; then
      sed -E -i '' 's/(nvcc .*)$/\1 -m64/' Makefile
    fi
    # TODO else handle other mismatches
    
    make
    python test_cudamat.py
  fi
fi
popd

