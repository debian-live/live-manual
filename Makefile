AUTOBUILD	:= build
#LANGUAGES       := de fr

PROJECT		:= live-manual
FORMATS		:= html txt pdf

VERSION		:= Unreleased Snapshot
PUBDATE		:= $(shell date -R)

TARGETS		:= $(foreach fmt,$(FORMATS),$(PROJECT).$(fmt))
SOURCES		:= $(wildcard xml/chapters/*.xml) $(wildcard xml/appendices/*.xml) xml/entities/version.ent xml/entities/common.ent

XP		:= xsltproc --nonet --novalid --xinclude
XL		:= xmllint --nonet --noout --postvalid --xinclude
DBLATEX		:= dblatex --style=db2latex

all: $(TARGETS)

update:
	git pull

test: $(SOURCES)
	$(XL) xml/index.xml

index.html: $(SOURCES)
	$(XP) xsl/html.xsl xml/index.xml

$(PROJECT).html: index.html

$(PROJECT).txt: $(SOURCES)
	$(XP) xsl/txt.xsl xml/index.xml | w3m -cols 65 -dump -T text/html > $@

$(PROJECT).pdf: $(SOURCES)
	$(DBLATEX) xml/index.xml -o $@

xml/entities/version.ent:
	echo '<!ENTITY version "$(VERSION)">' >  $@
	echo '<!ENTITY pubdate "$(PUBDATE)">' >> $@

#build: clean translations all
build: clean all
	set -e; for FORMAT in $(FORMATS); do \
		mkdir -p $(AUTOBUILD)/$$FORMAT; \
		cp *.$$FORMAT $(AUTOBUILD)/$$FORMAT; \
	done

	sed '{s/@DATE@/$(shell LC_ALL=C date -R)/;s%/@LANG@%%;}' html/index.html.in > $(AUTOBUILD)/index.html.en

	set -e; for LANGUAGE in $(LANGUAGES); do \
		for FORMAT in $(FORMATS); do \
			mkdir -p $(AUTOBUILD)/$$FORMAT/$$LANGUAGE; \
			cp $$LANGUAGE/*.$$FORMAT $(AUTOBUILD)/$$FORMAT/$$LANGUAGE; \
		done; \
		sed "{s/@DATE@/$(shell LC_ALL=C date -R)/;s/@LANG@/$$LANGUAGE/;}" $$LANGUAGE/html/index.html.in > $(AUTOBUILD)/index.html.$$LANGUAGE; \
	done

	cp html/* $(AUTOBUILD)

po4a:
	po4a -k 0 po4a/live-manual.cfg;

translations: po4a
	set -e; for LANGUAGE in $(LANGUAGES); do \
		mkdir -p $$LANGUAGE; \
		cp -r xml/entities/ $$LANGUAGE; \
		cp -r xsl/ $$LANGUAGE; \
		cp Makefile.common $$LANGUAGE/Makefile; \
		$(MAKE) -C $$LANGUAGE; \
	done

clean:
	-rm -rf $(LANGUAGES)
	rm -f *.html *.pdf *.txt
	rm -f xml/entities/version.ent

distclean: clean
	rm -rf build

.PHONY: all clean po4a translations test $(PROJECT).html
