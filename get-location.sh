#!/usr/bin/env bash

GETLOCATION=../get-location/
FILE=$(echo $1 | rev | cut -d'/' -f 1 | rev)
FOLDER=../api-location-$FILE
mkdir -p $FOLDER
cd $FOLDER

rm location
touch location

cat $1 | cut -c 20- | awk '$0="https://api.github.com/users/"$0' > url

cat url | while read -r line; do
    NAME=$(echo $line | cut -f5 -d'/')
    RAW=rawfetch-$NAME
    #echo $line
    echo $NAME
    if [ ! -f $RAW ];then
        curl --silent -H "Accept: application/vnd.github.v3+json" $line > $RAW
        bash ${GETLOCATION}github-valid.sh $RAW "bash get-location.sh $FILE" || exit 1
    fi
    cat $RAW | grep -m 1 location | cut -c 15- | sed 's/,//' >> location
done

paste $1 $location > ../location-$FILE
