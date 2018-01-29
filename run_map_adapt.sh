SRCDIR=ru-RU
DSTDIR=ru-RU-adapt
DICT=./msu_ru_nsh.dic
FILEIDS=speech.fileids
TRANSCRIPTION=speech.transcription
SPHINX_FE=$HOME/cmusphinx/sphinxbase/src/sphinx_fe/sphinx_fe

rm -rf $DSTDIR
mkdir $DSTDIR
if [[ "$(file $SRCDIR/mdef)" =~ "text" ]] 
then cp $SRCDIR/mdef $SRCDIR/mdef.txt
else pocketsphinx_mdef_convert -text $SRCDIR/mdef $SRCDIR/mdef.txt
fi

sed 's/[.]wav$//g' $FILEIDS > "${FILEIDS}_"

$SPHINX_FE -argfile $SRCDIR/feat.params \
          -samprate 16000 -c "${FILEIDS}_" \
          -di . -do . -ei wav -eo wav.mfc -mswav yes
/usr/lib/sphinxtrain/bw \
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
/usr/lib/sphinxtrain/map_adapt \
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
