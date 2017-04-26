#!/bin/sh -e

SCRIPTDIR=`dirname \`readlink -f $0\``
ESMVALDIR=`readlink -f $SCRIPTDIR/../tools/ESMValTool`
NAMELISTDIR=`readlink -f $SCRIPTDIR/../mods/namelists`
ESMVAL_SCRATCH=/scratch/$USER/NorESMValTool
ESMVAL_WORKPATH=$ESMVAL_SCRATCH/work

# print help information if input arguments are missing 
if [[ ! $1 || `echo $1 | head -1c` == '-' ]]
then
  echo "Usage: $0 <cmor output folder> <NorESMValTool namelist>"
  echo 
  echo "Example: $0 /projects/NS2345K/noresm/cmorout/ingo/N20TRAERCN_f19_g16_01.2000-2000 $NAMELISTDIR/namelist_MyDiag.xml" 
  echo 
  echo "Note: The cmorized output must be created with NorESMValTool's cmorize.sh script."
  exit
fi

# check if namelist and output folder exist
if [ ! -e $1 ] 
then 
  echo "Error: $1 does not exist. aborting..." 
fi
if [ ! -e $2 ] 
then 
  echo "Error: $2 does not exist. aborting..." 
fi

# copy namelist and customize
CASENAME=`basename $1 | cut -d"." -f1`
MODEL_ID=`echo $CASENAME | sed 's/_/-/g'`
YEAR1=`basename $1 | cut -d"." -f2 | cut -d"-" -f1`
YEARN=`basename $1 | cut -d"." -f2 | cut -d"-" -f2`
NAMELIST=$ESMVAL_WORKPATH/`basename $2 .xml`_`basename $1`.xml 
MODELTAG="CMIP5 ${MODEL_ID} Amon CMORized r1i1p1 $YEAR1 $YEARN $1"  
cat $2 | sed "s%MODELTAG%${MODELTAG}%g" > $NAMELIST 

# run ESMValTool 
cd $ESMVALDIR 
if [ `uname -n | grep norstore | wc -l` -gt 0 ]
then
  . /usr/share/Modules/init/sh
  module load python2/2.7 ncl 
fi
python main.py $NAMELIST 
