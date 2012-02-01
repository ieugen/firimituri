#!/bin/bash
# 
# This script downloades mailing list archives from GMane. It downloades them in
# chunks and saves them as mbox files in a directory that's named after the mailing list.
#
# Required parameters are: 
#   - <gmane mailing list name> (e.g. gmane.org.user-groups.rlug.general)
#   - start 
#   - step 

if [ -n "$1" ]
then 
    MLIST=$1;
else
    echo "Usage: $0 <gmane mailing list> [start] [chunksize]\n";
    exit 1;
fi

if [ -n "$2" ]
then
    START=$2;
    echo "Starting at message $START";
else
    START=1
    echo "WARNING: START not suppied, defaulting to $START";
fi

if [ -n "$3" ]
then
    STEP=$3 
    echo "Downloading $STEP messages at a time";
else
    STEP=5000
    echo "Stepping not suppied, defaulting to $STEP";
fi

echo "Begin downlod from list $MLIST messages: $START -> $STEP";

mkdir "$MLIST";
cd "$MLIST"
for (( i=$START; i<=$300000; i+=$STEP )); do
       s=$(( $i + $STEP ));
    wget --output-document="$s" "http://download.gmane.org/$MLIST/$i/$s";
    FSIZE=`stat -c %s $s`
    if [[ "$FSIZE" -eq "0" ]]
    then
        echo "Done!";
        exit 0;
    fi
done
