#!/bin/bash
wget -c http://www.repository.voxforge1.org/downloads/Russian/Trunk/AcousticModels/AcousticModels.tgz
if [[ ! -e AcousticModels ]]
then 
tar zxvf AcousticModels.tgz
fi
mkdir -p cmusphinx
cd cmusphinx
if [[ ! -e pocketsphinx ]]
then
  git clone https://github.com/cmusphinx/pocketsphinx 
fi
if [[ ! -e sphinxbase ]]
then
  git clone https://github.com/cmusphinx/sphinxbase
fi
if [[ ! -e sphinxtrain ]]
then
  git clone https://github.com/cmusphinx/sphinxtrain
fi
cd sphinxbase
./autogen.sh
make
cd ../sphinxtrain
./autogen.sh
make
cd ../pocketsphinx
./autogen.sh
make
