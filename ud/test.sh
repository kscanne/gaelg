#!/bin/bash
TMPCONLLU=`mktemp`

usage() {
	echo "Usage: bash test.sh [-g|-p]"
	echo "-g to test gold.tsv; -p to test pending additions in pedit.tsv"
	rm -f "${TMPCONLLU}"
	exit 1
}

if [ $# -ne 1 ]
then
	usage
fi

ANSEO=${HOME}/gaeilge/ga2gv/ga2gv/ud

if [ "${1}" = "-p" ]
then
	cat ${ANSEO}/pedit.tsv | perl todist.pl > ${TMPCONLLU}
else
	if [ "${1}" = "-g" ]
	then
		cp ${ANSEO}/gv_cadhan-ud-test.conllu ${TMPCONLLU}
	else
		usage
	fi
fi
cd ${HOME}/seal/temp/udtools
source ${HOME}/gaeilge/claochlu/env/bin/activate
python validate.py --lang=gv "${TMPCONLLU}"
rm -f "${TMPCONLLU}"
