#! /bin/bash
# Author: Javier Arellano-Verdejo
# jep <fred-file> <a|t>

# configuration variables
JEP=/eris/l2processor
JEPDATA=$JEP/data
BIN=$JEP/bin
RTSTPS=$JEP/rt-stps
SEADAS=$JEP/seadas

# define logname name
DT=`date '+%Y_%m_%d'`
LOGNAME=${JEP}/log/jep.${DT}.log
touch $LOGNAME

# set variables for seadas
export OCSSWROOT=$SEADAS
source $SEADAS/OCSSW_bash.env

# Load parameters
OPTS=`getopt -q -o m:f:h -l "mission:,fred:,help" -- $@`

if [ $? -ne 0 ]
then
    echo "Try '$0 --help' for more information."
    exit 101
fi

eval set -- "$OPTS"
while true ; do
  case $1 in
    -m|--mission)
      MISSION=$2
      if [ "$MISSION" != "a"  ] && [ "$MISSION" != "t" ]; then
        echo "Try '$0 --help' for more information."
        exit 102
      fi
      shift 2 ;;
    -f|--fred)
      FILE=$2
      if [ ! -f $FILE ]; then
        echo "file $FILE does not exists"
        exit 103
      fi
      shift 2 ;;
    -h|--help)
      echo "Usage: $0 -m|--mission [a|t] -f|--fred [fred_file]"
      echo ""
      echo "   -m MISSION, --mission=MISSION: Mission type, 'a' for aqua or 't' for terra"
      echo "   -f FILE, --fred=FRED: Fred-type file name"
      echo ""
      echo "example:"
      echo "   $0 -m a -f AQUA.00001"
      echo "   $0 --mission=t --fred=TERRA.00001"
      exit 104 ;;
    --)
      shift
      break ;;
  esac
done

case $MISSION in
  "a") L0CONFIG="$JEP/config/aqua.xml" ;;
  "t") L0CONFIG="$JEP/config/terra.xml" ;;
esac

echo "JEP processor v1.303.18"
echo "Processing $FILE"

FILE=`basename ${FILE}`
DIRNAME=${FILE}.proc
RAWNAME=${FILE}.raw

rm -rf $DIRNAME
mkdir $DIRNAME
if [ ! -d  $DIRNAME ] ; then
	echo "Creating $DIRNAME failed - exit"
  exit 201
fi

# cleans fred header
#echo "Restoring raw file"
#$BIN/restore_raw $FILE $DIRNAME/$RAWNAME  > /dev/null 2>&1
#if [ $? -ne 0 ]; then
#  echo "Error cleaning FRED-Header"
#  exit 202
#fi
cp $FILE $DIRNAME

# creates PDS file or L0 data
#echo "Creating L0 files ..."
#cp $FILE $DIRNAME
cd $DIRNAME
PWD=`pwd`

#$RTSTPS/bin/batch.sh $L0CONFIG $RAWNAME
#if [ $? -ne 0 ]; then
#  echo "Error while creating the PDS file"
#  exit 203
#fi

# Creates a MODIS L1A file from an input L0 file.
echo "Creating L1A file ..."
L0DATA=`ls -S -1 *PDS | head -n 1`
$SEADAS/scripts/modis_L1A.py -m $MISSION $L0DATA
if [ $? -ne 0 ]; then
  echo "Error while creating the L1A file"
  exit 204
fi
rm -f $JEPDATA/level0/$L0DATA
mv $L0DATA $JEPDATA/level0

# Creates a GEO file from L1A input file
echo "Creating GEO file ..."
L1ADATA=`ls *L1A_LAC | cut -d . -f1`
$SEADAS/scripts/modis_GEO.py --threshold=50 -r ${L1ADATA}.L1A_LAC
if [ $? -ne 0 ]; then
  echo "Error while creating the GEO file"
  exit 205
fi

# Creates a MODIS Level 1B file
echo "Creating L1B file ..."
$SEADAS/scripts/modis_L1B.py ${L1ADATA}.L1A_LAC ${L1ADATA}.GEO  > /dev/null 2>&1
L1BDATA=`ls *L1B_LAC | cut -d . -f1`
if [ $? -ne 0 ]; then
  echo "Error while creating the L1B file"
  exit 206
fi

rm -rf mkdir $JEPDATA/level1/${L1BDATA}
echo ${L1BDATA} >> $LOGNAME
mkdir $JEPDATA/level1/${L1BDATA}
if [ $? -ne 0 ]; then
  echo "Error copying L1B files to $JEPDATA/level1/${L1BDATA}"
  exit 207
fi

# Creates a MODIS Level 2 file
echo "Creating L2 file ..."
mkdir $JEPDATA/level2/${L1BDATA}
# loads the products list to be generated
PROD=`$BIN/listprod.sh`
l2gen ifile=${L1BDATA}.L1B_LAC geofile=${L1ADATA}.GEO ofile=${L1BDATA}.L2_LAC_OC suite=OC l2prod="$PROD"
#l2gen ifile=${L1BDATA}.L1B_LAC geofile=${L1ADATA}.GEO ofile=${L1BDATA}.L2_LAC_OC suite=OC l2prod="chlor_a ipar nflh rhos rhos_nnn rhot_nnn sst sst4"

if [ $? -ne 0 ]; then
  echo "Error generating L2 file"
  exit 208
fi

echo "Reprojecting L2 file ..."
$BIN/reproject.sh ${L1BDATA}.L2_LAC_OC
if [ $? -ne 0 ]; then
  echo "Error reprojecting L2 file"
  exit 208
fi

# moving files to final directories
mv ${L1BDATA}.L1B_LAC $JEPDATA/level1/${L1BDATA}
mv ${L1ADATA}.GEO $JEPDATA/level1/${L1BDATA}
mv ${L1BDATA}.L2_LAC_OC $JEPDATA/level2/${L1BDATA}
mv ${L1BDATA}_reprojected.h5 $JEPDATA/level2/${L1BDATA}

echo "All files for ${L1BDATA} has been generated"

# Delete temporary files
rm -rf ../$DIRNAME
