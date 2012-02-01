#!/bin/bash
# 
# This script downloades mailing list archives from GMane. It downloades them in
# chunks and saves them as mbox files in a directory that's named after the mailing list.
#
# Required parameters are: 
#   - <gmane mailing list name> (e.g. gmane.org.user-groups.rlug.general)
#   - start 
#   - end 

if [ -n "$1" ]
then 
    MLIST=$1;
else
    echo "Usage: $0 <gmane mailing list> [start] [end]\n";
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
    END=$3 
    echo "Downloading $STEP messages at a time";
else
    END=500000
    echo "Stepping not suppied, defaulting to $STEP";
fi

echo "Begin downlod from list $MLIST messages: $START -> $STEP";

#set the step to 5000, any larger and we might make the server kill the link
STEP=5000

mkdir "$MLIST";
cd "$MLIST"
for (( i=$START; i<=$END; i+=$STEP )); do
       s=$(( $i + $STEP ));
    wget --output-document="$s" "http://download.gmane.org/$MLIST/$i/$s";
    FSIZE=`stat -c %s $s`
    if [[ "$FSIZE" -eq "0" ]]
    then
        echo "Done!";
	rm $s;
        exit 0;
    fi
done
