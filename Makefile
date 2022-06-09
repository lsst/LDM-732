DOCTYPE = LDM
NAMESPACE = DM
PLAN = LVV-P47
DOCNUMBER = 732
DOCNAME = $(DOCTYPE)-$(DOCNUMBER)
JOBNAME = $(DOCNAME)
TEX = $(filter-out $(wildcard *acronyms.tex) , $(wildcard *.tex))

export TEXMFHOME ?= lsst-texmf/texmf

# Version information extracted from git.
GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif

$(JOBNAME).pdf: figures $(DOCNAME).tex meta.tex acronyms.tex
	xelatex -jobname=$(JOBNAME) $(DOCNAME)
	bibtex $(JOBNAME)
	xelatex -jobname=$(JOBNAME) $(DOCNAME)
	xelatex -jobname=$(JOBNAME) $(DOCNAME)
	xelatex -jobname=$(JOBNAME) $(DOCNAME)

.FORCE:

generate: .FORCE
	docsteady baseline-ve --subcomponent NETWORK jira_docugen.tex

# conda create and activate docsteady-env first
#	docsteady --namespace DM baseline-ve DM Network jira_docugen.tex
#Github action docgec_from_jira is probalby a better option - you have to instgall docstready and do the  the auth for this other wise.. see docsteady.lsst.io

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	printf '%% GENERATED FILE -- edit this in the Makefile\n' >>$@
	printf '\\newcommand{\\lsstDocType}{$(DOCTYPE)}\n' >>$@
	printf '\\newcommand{\\lsstDocNum}{$(DOCNUMBER)}\n' >>$@
	printf '\\newcommand{\\vcsRevision}{$(GITVERSION)$(GITDIRTY)}\n' >>$@
	printf '\\newcommand{\\vcsDate}{$(GITDATE)}\n' >>$@




#Traditional acronyms are better in this document
acronyms.tex : ${TEX} myacronyms.txt skipacronyms.txt
	echo ${TEXMFHOME}
	python3 ${TEXMFHOME}/../bin/generateAcronyms.py -t "DM"    $(TEX)

myacronyms.txt :
	touch myacronyms.txt

skipacronyms.txt :
	touch skipacronyms.txt

.PHONY: figures
figures: figures/scope
	$(MAKE) -C $<

clean :
	latexmk -c
	rm *.pdf *.nav *.bbl *.xdv *.snm
