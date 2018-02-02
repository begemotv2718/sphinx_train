#!/bin/bash
# Take input file with newline separated phrases to pronounce, pronounce phrases interactively. Resulting files are: speech.fileids, speech.transcription and a wav files in ./wav/ directory. 
# The output of this script is ready to pass to the next script map_adapt.sh

# Скрипт для интерактивной записи набора фраз для адаптации модели.


OUTFILE_FILES='speech.fileids'
OUTFILE_PHRASES='speech.transcription'
WAV_DIRNAME='./wav/'
mkdir -p $WAV_DIRNAME


ASK_FILE_RESULT=''

get_file_name(){
  number=$1
  fname=$(printf "record%03d.wav" $number)
  echo "$WAV_DIRNAME/$fname"
}

list_file(){
  exec 3<$1
  i=0
  echo -ne "$i\000"
  echo -ne "<-Exit\000"
  while read -u 3
  do
    ((i++))
    echo -ne "$i\000"
    if [[ -e $(get_file_name $i) ]]
    then
      echo -ne "*"
    fi
    echo -ne "$REPLY\000"
  done
  exec 3<&-
}

ask_file(){
  eval `resize`
  tmpfile=`mktemp`
  list_file $1 | xargs -0 whiptail --title "Phrases" --menu "Choose phrase to pronounce" $LINES $COLUMNS $((LINES-8)) 2>$tmpfile
  ASK_FILE_RESULT=`cat $tmpfile`
  rm -rf $tmpfile 
}

rm -rf $OUTFILE_FILES
rm -rf $OUTFILE_PHRASES
while true
do
  ask_file $1
  if [[ $ASK_FILE_RESULT == '0' ]]
  then
    i=0
    while read
    do
      ((i++))
      if [[ -e `get_file_name $i` ]]
      then
        echo "<s> $REPLY </s>" >> $OUTFILE_PHRASES
        get_file_name $i >> $OUTFILE_FILES
      fi
    done < $1
    exit 0
  else
    if [[ -e $(get_file_name $ASK_FILE_RESULT) ]]
    then
      play `get_file_name $ASK_FILE_RESULT`
      whiptail --yesno "Do you want to keep this file?" 10 40
      stat=$?
      if [[ $stat != 0 ]]
      then 
        rm `get_file_name $ASK_FILE_RESULT`
      fi
    else
      rec `get_file_name $ASK_FILE_RESULT` channels 1 rate 16k silence 1 0.1 3% 1 3.0 3%
    fi
  fi
  sleep 1
done
