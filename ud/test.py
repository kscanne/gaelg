class Token:
    
    labels = ('index','token','lemma','upos','xpos','morph','head','deprel','enh','other')
    
    def __init__(self, line=None):
        if line==None:
            line="0\tROOT"+"\t_"*8
        self._data = {k: v for (k, v) in zip(Token.labels,line.split('\t'))}
        self._head = None  # will be a Token object once sentence is read
        self._case = None  # for NOUN/PROPN, will be one of Nom/Gen/Dat/Acc/Voc
        
    def __getitem__(self, arg):
        if arg not in Token.labels:
            raise ValueError('unknown token key: '+arg)
        elif arg == 'index' or arg == 'head':
            return int(self._data[arg])
        else:
            return self._data[arg]
        
    def __str__(self):
        return '('+str(self['index'])+','+self['token']+')'

    def isRoot(self):
        return self['index']==0

    def isNominal(self):
        return (self['upos']=='NOUN' or self['upos']=='PROPN')

    def setHead(self, headToken):
        self._head = headToken

    def getHead(self):
        return self._head

    def setCase(self, val):
        self._case = val
    
    def getCase(self):
        return self._case

    def getDeprel(self):
        ans = self['deprel']
        if ans=='conj':
            return self._head['deprel']
        else:
            return ans

    __repr__ = __str__


def setHeads(s):
    for t in s:
        if not t.isRoot():
            t.setHead(s[t['head']])

def qaCheck(s):
    for t in s:
        if not t.isRoot():
            if t['deprel']=='amod' and t.getHead()['upos']=='VERB':
                return True
            #print(t['deprel']+'\t'+t.getHead()['upos'])
            #print(t['upos']+'\t'+t['deprel'])
    return False
        

# read in deptags.tsv and warn for any 
# upos, deprel pairs not in there...
import re
corpus = '/home/kps/gaeilge/ga2gv/ga2gv/ud/all.conllu'
verbose = True
total = 0
with open(corpus,'r') as f:
    sentence = [Token()]
    for line in f:
        line = line.rstrip('\n')
        if line == '':
            total += 1
            setHeads(sentence)
            if qaCheck(sentence):
                print(sentence)
            sentence = [Token()]
        elif line[0] == '#' or re.match('^[0-9]+-',line):
            # skip comments and multiword tokens
            pass
        else:
            sentence.append(Token(line))

#print('Parsed',total,'sentences')
