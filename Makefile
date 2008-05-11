PROJECT		:= live-manual
FORMATS		:= html txt pdf

AUTOBUILD	:= autobuild
VERSION		:=
PUBDATE		:=

TARGETS		:= $(foreach fmt,$(FORMATS),$(PROJECT).$(fmt))
SOURCES		:= $(wildcard chapters/*.xml) $(wildcard appendices/*.xml) ent/version.ent ent/common.ent

XP		:= xsltproc --nonet --novalid --xinclude
XL		:= xmllint --nonet --noout --postvalid --xinclude
DBLATEX		:= dblatex --style=db2latex

all: $(TARGETS)

validate: $(SOURCES)
	$(XL) index.xml

autobuild: clean all
	set -e; for FORMAT in $(FORMATS); do \
		mkdir -p $(AUTOBUILD)/$$FORMAT; \
		cp *.$$FORMAT $(AUTOBUILD)/$$FORMAT; \
	done
	sed 's/UPDATED/$(shell LC_ALL=C date)/' index.html.in > $(AUTOBUILD)/index.html

index.html: $(SOURCES)
	$(XP) xsl/html.xsl index.xml

$(PROJECT).html: index.html

$(PROJECT).txt: $(SOURCES)
	$(XP) xsl/txt.xsl index.xml | w3m -cols 65 -dump -T text/html > $@

$(PROJECT).pdf: $(SOURCES)
	$(DBLATEX) index.xml -o $@ 

ent/version.ent:
	echo '<!ENTITY version "$(VERSION)">' >  $@
	echo '<!ENTITY pubdate "$(PUBDATE)">' >> $@

clean:
	rm -f *.html *.pdf *.txt
	rm -f ent/version.ent

.PHONY: all clean validate $(PROJECT).html
