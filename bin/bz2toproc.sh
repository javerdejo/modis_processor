#/bin/bash
# Author: Javier Arellano-Verdejo

# Enviroment variables

# base directory where the pass information is stored
BASE_DIR='/eris/l2processor/data/bz2'

# prepare all files to be proccessed
echo "bz2toproc v1.303.18"

FILE_LIST=`ls $BASE_DIR/*bz2 -1`
# for each file into the directory
for FILE in $FILE_LIST; do
  touch $FILE.jep
done
