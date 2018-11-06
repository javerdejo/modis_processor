# Author: Javier Arellano-Verdejo
FILEIN=$1
FILEOUT=`echo $FILEIN | cut -d . -f 1`
/opt/seadas-7.5.1/bin/gpt.sh  /eris/l2processor/config/reprojection.xml -Ssource=${FILEIN} -f HDF5 -t ${FILEOUT}_reprojected.h5
