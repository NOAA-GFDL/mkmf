# Makefile for creating the Man and HTML manual pages for dmwho

INSTALL = /usr/bin/install
PREFIX = .
MAN1DIR = $(PREFIX)/man/man1
HTMLDIR = $(PREFIX)/share/FRE
BINDIR = $(PREFIX)/bin

VERSION = "19.2.0"
DATE := $(shell date +"%Y %B %d")

POD2MAN = pod2man
POD2HTML = pod2html
POD2LATEX = pod2latex
PDFLATEX = pdflatex

PODS = mkmf.pod
POD_MAN1 = $(patsubst %.pod,%.1,$(PODS))

A2X = a2x
ASCIIDOC_CFG = asciidoc.conf

TXTS = list_paths.txt git-version-string.txt
TXT_MAN1 = $(patsubst %.txt,%.1,$(TXTS))

.SUFFIXES:

all: podman txtman

podman: $(POD_MAN1)

txtman: $(TXT_MAN1)

html: $(PODS:.pod=.html)

tex: $(PODS:.pod=.tex)

pdf: $(PODS:.pod=.pdf)

install: $(PODS:.pod=.1) $(PODS:.pod=.html) $(PODS)
	$(INSTALL) -d -m 755 $(MAN1DIR) $(HTMLDIR)
	$(INSTALL) -c -m 644 *.1 $(MAN1DIR)
	$(INSTALL) -c -m 644 *.html $(HTMLDIR)

clean:
	$(RM) *.[1-9]
	$(RM) *.html
	$(RM) *.tmp
	$(RM) *.tex
	$(RM) *.pdf
	$(RM) *.aux
	$(RM) *.idx
	$(RM) *.log
	$(RM) *.toc
	$(RM) *.xml

%.1: %.pod
	$(POD2MAN) --section=1 \
		   --release=$(VERSION) \
		   --center="FRE Utility" \
		   --date="$(DATE)" \
		   $< $@

%.1: %.txt $(ASCIIDOC_CFG)
	$(A2X) -v \
	       -d manpage \
	       -f manpage \
	       -aversion=$(VERSION) \
	       --asciidoc-opts="-f $(ASCIIDOC_CFG)" \
	       $<

%.html: %.txt $(ASCIIDOC_CFG)
	$(A2X) -v \
	       -d manpage \
	       -f xhtml \
	       -aversion=$(VERSION) \
	       --asciidoc-opts="-f $(ASCIIDOC_CFG)" \
	       $<

%.html: %.pod
	$(POD2HTML) --infile=$< \
		    --outfile=$*.html \
		    --title="`podselect -section NAME $< | sed -e 's/=head1 NAME//'`"
	$(RM) *.tmp

%.tex: %.pod
	$(POD2LATEX) -out $*.tex $<

%.pdf: %.pod
	$(POD2LATEX) -full -out $*.tex $<
	$(PDFLATEX) $*.tex
