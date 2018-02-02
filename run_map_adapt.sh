#!/bin/bash
SRCDIR=AcousticModels/model_parameters/msu_ru_nsh.cd_cont_1000_8gau_16000/
DSTDIR=AcousticModels/ru-RU-adapt
DICT=AcousticModels/etc/msu_ru_nsh.dic
FILEIDS=speech.fileids
TRANSCRIPTION=speech.transcription

rm -rf $DSTDIR
mkdir $DSTDIR
if [[ "$(file $SRCDIR/mdef)" =~ "text" ]] 
then 
  cp $SRCDIR/mdef $SRCDIR/mdef.txt
else
  cmusphinx/pocketsphinx/src/programs/pocketsphinx_mdef_convert -text $SRCDIR/mdef $SRCDIR/mdef.txt
fi

sed 's/[.]wav$//g' $FILEIDS > "${FILEIDS}_"

cmusphinx/sphinxbase/src/sphinx_fe/sphinx_fe -argfile $SRCDIR/feat.params \
          -samprate 16000 -c "${FILEIDS}_" \
          -di . -do . -ei wav -eo wav.mfc -mswav yes
cmusphinx/sphinxtrain/src/programs/bw/bw \
 -hmmdir $SRCDIR \
 -moddeffn $SRCDIR/mdef.txt \
 -ts2cbfn .cont. \
 $(grep '^-feat' $SRCDIR/feat.params)  \
 $(grep '^-svspec' $SRCDIR/feat.params)  \
 $(grep '^-cmn' $SRCDIR/feat.params)  \
 $(grep '^-agc' $SRCDIR/feat.params)  \
 -dictfn $DICT \
 -ctlfn $FILEIDS \
 -lsnfn $TRANSCRIPTION \
 -accumdir .
cmusphinx/sphinxtrain/src/programs/map_adapt/map_adapt \
    -moddeffn $SRCDIR/mdef.txt \
    -ts2cbfn .cont. \
    -meanfn $SRCDIR/means \
    -varfn $SRCDIR/variances \
    -mixwfn $SRCDIR/mixture_weights \
    -tmatfn $SRCDIR/transition_matrices \
    -accumdir . \
    -mapmeanfn $DSTDIR/means \
    -mapvarfn $DSTDIR/variances \
    -mapmixwfn $DSTDIR/mixture_weights \
    -maptmatfn $DSTDIR/transition_matrices
