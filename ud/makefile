GA2GV=${HOME}/gaeilge/ga2gv/ga2gv
DIST=${HOME}/seal/UD_Manx-Cadhan

# NEVER EDIT THIS MANUALLY; make fixes in gold.tsv...
gv_cadhan-ud-test.conllu: gold.tsv todist.pl
	rm -f $@
	cat gold.tsv | perl todist.pl > $@
	cp -f $@ $(DIST)
	chmod 644 $(DIST)/$@
	chmod 400 $@

pedit.tsv: tagged.tsv draftparse.pl renumber.pl
	cat tagged.tsv | perl renumber.pl | perl draftparse.pl > $@

tagged.tsv: edit.tsv renumber.pl stemmer.pl
	cat edit.tsv | perl renumber.pl | perl stemmer.pl > $@

append: FORCE
	cat pedit.tsv >> gold.tsv 
	make gold-corpus.txt
	make gv_cadhan-ud-test.conllu

gold-corpus.txt: gold.tsv
	egrep '^# text' gold.tsv | sed 's/^# text = //' > $@

edit.tsv: draft.tsv disambig.pl
	cat draft.tsv | perl disambig.pl > $@

draft.tsv: tagdict.tsv ig2draft.pl ig-output.txt
	cat ig-output.txt | perl ig2draft.pl > $@

tagdict.tsv: ${GA2GV}/GV.txt tag2ud.pl extras.tsv numbers.tsv gold.tsv alts.tsv
	cat ${GA2GV}/GV.txt | perl tag2ud.pl | sort -u | sort -k1,1 > $@

numbers.tsv: ${GA2GV}/GV.txt ${GA2GV}/focloir.txt getnums.sh
	bash getnums.sh > $@

ig-output.txt: corpus.txt
	cat corpus.txt | sed 's/.*/<div text="&"\/>&/' | bash ${HOME}/seal/caighdean/tiomanai.sh -x > $@

alts.tsv: ${GA2GV}/focloir.txt
	cat ${GA2GV}/focloir.txt | egrep -v '0$$' | egrep -v ' ' | cut -f 1,4 | sed 's/[0-9]_/_/' | sed 's/_prep/|ADP/g; s/_v/|VERB/g; s/_n[a-z]*/|NOUN/g; s/_adv/|ADV/g; s/_a/|ADJ/g; s/_pronm/|ADP/g; s/_conj/|SCONJ/g; s/_interr/|PRON/g; s/_pn/|PRON/g; s/_card/|NUM/g; s/_excl/|INTJ/g; s/_poss/|DET/g' | egrep -v "^([A-Za-zÇç'-]+\|[A-Z]+)[^A-Z]\1$$" | sort -u | sort -k1,1 > $@
	sed -i '/^[A-ZÇ]/s/|NOUN/|PROPN/g' $@

BATCH=5
corpus.txt:
	make gold-corpus.txt
	cat ${HOME}/seal/idirlamha/gv/freq/corpus.txt | shuf | keepif -n gold-corpus.txt | egrep -v '[=<>×~|`+{}_#]' | egrep -v ' (of|the|you|or|in|an|to|npl|mpl) ' | sed 's/^[0-9][0-9]*:[0-9][0-9]*: *//' | sed 's/^[0-9][0-9]*[.)]\?  *\([A-Z]\)/\1/' | egrep '^[A-ZÇ“"‘]' | egrep '[.?!”"’]$$' | head -n $(BATCH) > $@

# Always safe to run this, as long as not in the middle
# of editing edit.tsv, tagged.tsv, or pedit.tsv!
clean: 
	rm -f corpus.txt ig-output.txt draft.tsv edit.tsv tagged.tsv pedit.tsv
	rm -f alts.tsv numbers.tsv tagdict.tsv gold-corpus.txt gv_cadhan-ud-test.conllu

FORCE:
