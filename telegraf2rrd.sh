#!/bin/bash

# https://github.com/filipsPL/telegraf2rrd

# topics to observe, separated by the pipe "|" character
# will be used in grep, so almost anything is fine here
topics_to_search="/iot/home/temp|/iot/home/pressure|/comp/cpu/temp|/comp/system/load"

insert_to_db() {

    # location of the databases
    dbDir="/var/rrd_dbases"
    mkdir -p "$dbDir"

    # Set variables
    DBNAME="$dbDir/$1.rrd"
    DSNAME="value"
    INTERVAL=60 # in seconds
    VALUE=$2
    START=$3
    HB=600

    # Create RRD database if it doesn't exist
    if [ ! -e "$DBNAME" ]; then
        rrdtool create "$DBNAME" \
            --start now-1y --step $INTERVAL \
            DS:$DSNAME:GAUGE:$HB:U:U \
            RRA:AVERAGE:0.5:1:10d \
            RRA:AVERAGE:0.5:30m:30d \
            RRA:AVERAGE:0.5:1h:90d \
            RRA:AVERAGE:0.5:3h:18M \
            RRA:AVERAGE:0.5:6h:10y

    fi

    # Insert value into RRD database
    rrdtool update "$DBNAME" "$START":"$VALUE"
}

# handle the input stream from telegraf

while read input_data; do

    if echo "$input_data" | grep -qE "$topics_to_search"; then

        # input data format is similar to this:
        # 1679910810,text,text,text,/iot/home/temp,21.23

        # Extract the first value
        ts=$(echo "$input_data" | cut -d ',' -f 1)

        # Extract the last value
        value=$(echo "$input_data" | rev | cut -d ',' -f 1 | rev)

        # Extract the one-but-last value
        topic=$(echo "$input_data" | rev | cut -d ',' -f 2 | rev)
        measurement=$(echo "$topic" | sed -e 's/\//_/g')

        insert_to_db "$measurement" "$value" "$ts"

    fi

done

exit 0
