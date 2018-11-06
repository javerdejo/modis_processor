#!/bin/bash
# Author: Javie Arellano-Verdejo

# processor root
ROOTPROC="/eris/l2processor"
# configuration files
CONFIG=$ROOTPROC/config

# file exists?
if [ ! -f $CONFIG/prods ]; then
    echo "File prods not found!"
    exit 1
fi

# loads the file contents
PRODS=`cat $CONFIG/prods`

# process the file contents to generate a string with the names of the products
# to be generated
STRING=""
for P in $PRODS; do
  STRING="$STRING $P"
done

# delete the blank spaces at the left and right of the string
STRING=`echo $STRING | xargs echo -n`

# append double quotes at the beginning and the end of the string and shows the
# resulting string
echo \"$STRING\"
