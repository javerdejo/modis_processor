#/bin/bash
# Author: Javier Arellano-Verdejo

# Enviroment variables

# processor root
ROOTPROC="/eris/l2processor"
# base directory where the bz2 files from NASA are stored
BASE_DIR=$ROOTPROC/data/bz2
# proeccesor binary files
PROCESSOR=$ROOTPROC/bin
# configuration files
CONFIG=$ROOTPROC/config
# logs all processed files
LOG='./processed.log'

# Process all files containded in the blade
echo "Batch v1.309.18"

# downloads the files from NASA servers
#$PROCESSOR/download_data.sh -d $CONFIG/download

# for all files with jep termination
TO_PROC_LIST=`ls $BASE_DIR/*.jep`

# for each file
for FILE in $TO_PROC_LIST; do
  FILENAME=`basename $FILE`
  FILENAME=${FILENAME:0:29}
  echo "Processing $FILENAME"

  # decompress and get the file name after decompression
  cp $BASE_DIR/$FILENAME .
  bzip2 -d $FILENAME
  FILENAME=${FILENAME:0:25}

  # get mision
  MISSION=${FILENAME:6:1}
  case $MISSION in
    P)
      MISSION='-m a'
      ;;
    A)
      MISSION='-m t'
      ;;
    *)
      echo "Error file name format"
      exit -1
  esac

  # process the file
  $PROCESSOR/jep.sh $MISSION -f $FILENAME
  echo "$FILENAME" >> $LOG
  rm -f $FILE
  rm -f *PDS
done

# Proccess ended
echo "All files has been processed"
