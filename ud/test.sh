#!/bin/bash

# pass "test" or "train"
testone() {
	CONLLU=${HOME}/gaeilge/ga2gv/ga2gv/ud/gv_cadhan-ud-${1}.conllu
	echo "Checking gv_cadhan-ud-${1}.conllu...."
	echo "Sentence count:" `cat ${CONLLU} | egrep '^# sent_id' | wc -l`
	echo "Word count:" `cat ${CONLLU} | egrep '^[0-9]+[^-]' | wc -l`
	python validate.py --lang=gv "${CONLLU}"
}

cd ${HOME}/seal/temp/udtools
source ${HOME}/gaeilge/claochlu/env/bin/activate
testone test
testone train
