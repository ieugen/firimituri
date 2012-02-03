#!/bin/bash

# Script that uses gmane.org web interface to download a mailing list archive. 
# The mailing list has to be registered on gmane:)
# You may search for a mailing list using http://search.gmane.org/
# Ex: http://dir.gmane.org/search.php?match=.rlug.
# Tested on 
# 	gmane.org.user-groups.rlug.general
# 	gmane.org.user-groups.rlug.offtopic

if [ -n "$1" ]; then 
    MLIST=$1;
else
    echo "Usage: $0 <gmane mailing list> [STEP] [START] [END]";
	echo;
    exit 1;
fi


if [ -n "$2" ]; then
    START=$2;
    echo "	download from message $START";
else
    START=1;
    echo "	START not suppied, defaulting to $START";
fi

#STEP at around 5000 will make the gmame server kill the export script(@see set_time_limit)
if [ -n "$3" ]; then
	STEP=$3 
	echo "	downloading $STEP messages at a time";
else
	STEP=1500;
	echo "	STEP not suppied, defaulting to $STEP";
fi

if [ -n "$4" ]; then
	END=$4
	echo "	downloading until message $END";
else
	echo "	END not supplied, autodetect from server RSS feed";
	END=`wget --quiet -O - "http://rss.gmane.org/messages/excerpts/$MLIST" | grep '<item rdf:about="http://permalink.gmane.org' | egrep -o "[0-9]+" | sort | uniq | head -n 1`;
	
	#END=500000;
	echo "	END not suppied, autodetected as $END";
fi


echo "Begin download $MLIST, $START -> $END : $STEP";


mkdir "$MLIST";
cd "$MLIST";

POST_OP="split";

# perform a for-loop to get all the messages until we reach the limit
for (( i=$START; i<=$END; i+=$STEP )); do
	s=$(( $i + $STEP ));
	
	FNAME=`printf "archive-%07d-%d" $i $s`;
	
	printf "%02d%%: " $(( 100*$i / $END ));
	wget -nv --output-document="$FNAME" "http://download.gmane.org/$MLIST/$i/$s";
	
	# perform a basic sanity check. Sometimes the gmame script will end with a fatal error because of php's set_time_limit function
	INVALID=`tail -n 2 "$FNAME" | grep "Fatal error"`;
	if [ -n "$INVALID" ]; then
		echo "invalid download $FNAME. a fatal error was encountered. Please retry with a lower STEP";
		exit 2;
	else
		if [ "$POST_OP" = "split" ]; then
			csplit -b "%04d" -f "$FNAME-" -k --quiet -z "$FNAME" "/^From news@gmane.org/" "{*}"
		fi;
	fi;
done
