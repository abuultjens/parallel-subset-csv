#!/bin/bash


SMALL=${1}
LARGE=${2}
OUTFILE=${3}

N_SPLIT=25

# generate random prefix for all tmp files
RAND_1=`echo $((1 + RANDOM % 100))`
RAND_2=`echo $((100 + RANDOM % 200))`
RAND_3=`echo $((200 + RANDOM % 300))`
RAND=`echo "${RAND_1}${RAND_2}${RAND_3}"`

# get list of index
cut -f 1 -d ',' ${SMALL} | tail -n +2 > ${RAND}_INDEX.csv

# write header to outfile
head -1 ${LARGE} > ${OUTFILE}

FOFN=${RAND}_INDEX.csv

# make dir for tmp files
mkdir ${RAND}

# get number of taxa in fofn
N_TAXA=`wc -l ${FOFN} | awk '{print $1}'`

# split fofn
split -d -l ${N_SPLIT} ${FOFN} ${RAND}/FOFN_${RAND}_

# make group fofn
ls ${RAND}/FOFN_${RAND}_* > ${RAND}/${RAND}_FOFN.txt

# loop through groups
for GROUP in $(cat ${RAND}/${RAND}_FOFN.txt); do

	FILE=`echo ${GROUP}`

	# loop through isolates in group
	for TAXA in $(cat ${FILE}); do
		grep ^"${TAXA}," ${LARGE} > ${RAND}_${TAXA}_tmp.csv &
	done

	wait

done

# cat and write all lines to outfile
for TAXA in $(cat ${RAND}_INDEX.csv); do
	cat ${RAND}_${TAXA}_tmp.csv >> ${OUTFILE}
	rm ${RAND}_${TAXA}_tmp.csv	
done

# rm tmp files		
rm *${RAND}*
rm -r ${RAND}


