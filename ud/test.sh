#!/bin/bash
CONLLU=${HOME}/gaeilge/ga2gv/ga2gv/ud/all.conllu
make all.conllu
echo "Sentence count:" `cat ${CONLLU} | egrep '^# sent_id' | wc -l`
echo "Word count:" `cat ${CONLLU} | egrep '^[0-9]+[^-]' | wc -l`
cd ${HOME}/seal/temp/udtools
source ${HOME}/gaeilge/claochlu/env/bin/activate
python validate.py --lang=gv "${CONLLU}"
