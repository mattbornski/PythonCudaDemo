#!/bin/bash

pushd `dirname $0`/cudamat
python -c "import gnumpy"
popd