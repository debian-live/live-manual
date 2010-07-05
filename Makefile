# Makefile

SHELL := sh -e

LANGUAGES = en de

all: test build

test:
	@echo "Checking for syntax errors... [not implemented yet - FIXME]"
	@#xmllint --nonet --noout --postvalid --xinclude manual/en/index.xml || true

	@echo "Checking for spelling errors... [not implemented yet - FIXME]"

tidy:
	for FILE in manual/en/*.xml manual/en/*/*.xml xsl/*.xsl; \
	do \
		sed -i -e 's|^[ \t]*||' -e 's|[ \t]*$$||' $${FILE}; \
		echo `cat $${FILE}` > $${FILE}.tmp; \
		xmllint --format --noblanks --output $${FILE} $${FILE}.tmp; \
		rm -f $${FILE}.tmp; \
	done

build:
	mkdir -p build

	for LANGUAGE in $(LANGUAGES); \
	do \
		mkdir -p $(CURDIR)/build/$${LANGUAGE}/xml; \
		cd $(CURDIR)/manual/$${LANGUAGE}; \
		xsltproc --output $(CURDIR)/build/$${LANGUAGE}/xml/live-manual.xml --nonet --novalid --xinclude $(CURDIR)/xsl/identity.xsl index.xml; \
		mkdir -p $(CURDIR)/build/$${LANGUAGE}/html; \
		cd $(CURDIR)/build/$${LANGUAGE}/html; \
		xsltproc --nonet --novalid --xinclude $(CURDIR)/xsl/html.xsl ../xml/live-manual.xml; \
		mkdir -p $(CURDIR)/build/$${LANGUAGE}/html-single; \
		cd $(CURDIR)/build/$${LANGUAGE}/html-single; \
		xsltproc --nonet --novalid --xinclude $(CURDIR)/xsl/html-single.xsl ../xml/live-manual.xml; \
		mv $(CURDIR)/build/$${LANGUAGE}/html-single/index.html $(CURDIR)/build/$${LANGUAGE}/html-single/live-manual.html; \
		mkdir -p $(CURDIR)/build/$${LANGUAGE}/pdf; \
		cd $(CURDIR)/build/$${LANGUAGE}/pdf; \
		dblatex --style=db2latex ../xml/live-manual.xml -o live-manual.pdf; \
		mkdir -p $(CURDIR)/build/$${LANGUAGE}/txt; \
		cd $(CURDIR)/build/$${LANGUAGE}/txt; \
		xsltproc --nonet --novalid --xinclude $(CURDIR)/xsl/txt.xsl ../xml/live-manual.xml | w3m -cols 65 -dump -T text/html > live-manual.txt; \
	done

autobuild: clean build
	rm -f build/*/*.xml
	cp html/* build

	for LANGUAGE in $(LANGUAGES); \
	do \
		cp html/* build/$${LANGUAGE}; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|^ *||g')|" \
		build/$${LANGUAGE}/index.html.in > build/$${LANGUAGE}/index.html; \
	done

commit: tidy test
	$(MAKE) -C manual rebuild

	@if grep -qs fuzzy manual/po/*/*; \
	then \
		echo "Please fix fuzzy in manual/po/* first."; \
		exit 1; \
	fi

	@echo
	@echo "Successful... please do:"
	@echo
	@echo "  * git add ."
	@echo "  * git commit -a -m \"Your commit message.\""
	@echo "  * git push"

install:

	for LANGUAGE in $(LANGUAGES); \
	do \
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}; \
		cp -a build/$${LANGUAGE}/html build/$${LANGUAGE}/html-single/* build/$${LANGUAGE}/pdf/* build/$${LANGUAGE}/txt/* $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}; \
	done

	ln -s en/html $(DESTDIR)/usr/share/doc/live-manual/html
	ln -s en/live-manual.html $(DESTDIR)/usr/share/doc/live-manual/live-manual.html
	ln -s en/live-manual.pdf.gz $(DESTDIR)/usr/share/doc/live-manual/live-manual.pdf.gz
	ln -s en/live-manual.txt.gz $(DESTDIR)/usr/share/doc/live-manual/live-manual.txt.gz

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf build

distclean: clean

rebuild: distclean build

.PHONY: build
