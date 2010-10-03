# Makefile

SHELL := sh -e

LANGUAGES = en $(shell cd manual/po && ls)

all: test build

test:
	@echo "Checking for syntax errors... [not implemented yet - FIXME]"
	@echo "Checking for spelling errors... [not implemented yet - FIXME]"

tidy:
	# Removing useless whitespaces at EOL
	for FILE in manual/en/*.ssm manual/en/*.ssi; \
	do \
		sed -i -e 's|[ \t]*$$||' $${FILE}; \
	done

build:
	@# FIXME: sisu-concordance sisu-pg sisu-sqlite
	for LANGUAGE in $(LANGUAGES); \
	do \
		cd $(CURDIR)/manual/$${LANGUAGE}; \
		sisu-epub -v live-manual.ssm; \
		sisu-html -v live-manual.ssm; \
		sisu-odf -v live-manual.ssm; \
		sisu-pdf -v live-manual.ssm; \
		sisu-txt -v live-manual.ssm; \
	done

autobuild: clean build
	rm -rf build
	cp -a html build

	for LANGUAGE in $(LANGUAGES); \
	do \
		mkdir -p build/$${LANGUAGE}/epub; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/epub/live-manual.epub build/$${LANGUAGE}/epub; \
		mkdir -p build/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/[0-9]*.html manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/index.html build/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/doc.html build/$${LANGUAGE}/html/live-manual.html; \
		cp -a manual/$${LANGUAGE}/build/$${LANGUAGE}/_sisu build/$${LANGUAGE}; \
		mkdir -p build/$${LANGUAGE}/odf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/opendocument.odt build/$${LANGUAGE}/odf/live-manual.odt; \
		mkdir -p build/$${LANGUAGE}/pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.a4.pdf build/$${LANGUAGE}/pdf/live-manual.landscape-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.a4.pdf build/$${LANGUAGE}/pdf/live-manual.portrait-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.letter.pdf build/$${LANGUAGE}/pdf/live-manual.landscape-letter.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.letter.pdf build/$${LANGUAGE}/pdf/live-manual.portrait-letter.pdf; \
		mkdir -p build/$${LANGUAGE}/txt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/plain.txt build/$${LANGUAGE}/txt/live-manual.txt; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|  ||g')|" \
		manual/$${LANGUAGE}/index.html.in > build/$${LANGUAGE}/index.html; \
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
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/epub; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/epub/live-manual.epub $(DESTDIR)/usr/share/doc/live-manual/epub/live-manual.$${LANGUAGE}.epub; \
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/html/$${LANGUAGE}; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/[0-9]*.html manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/index.html $(DESTDIR)/usr/share/doc/live-manual/html/$${LANGUAGE}; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/doc.html $(DESTDIR)/usr/share/doc/live-manual/html/live-manual.$${LANGUAGE}.html; \
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/odf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/opendocument.odt $(DESTDIR)/usr/share/doc/live-manual/odf/live-manual.$${LANGUAGE}.odt; \
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/txt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/plain.txt $(DESTDIR)/usr/share/doc/live-manual/txt/live-manual.$${LANGUAGE}.txt; \
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.a4.pdf $(DESTDIR)/usr/share/doc/live-manual/pdf/live-manual.landscape-a4.$${LANGUAGE}.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.a4.pdf $(DESTDIR)/usr/share/doc/live-manual/pdf/live-manual.portrait-a4.$${LANGUAGE}.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.letter.pdf $(DESTDIR)/usr/share/doc/live-manual/pdf/live-manual.landscape-letter.$${LANGUAGE}.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.letter.pdf $(DESTDIR)/usr/share/doc/live-manual/pdf/live-manual.portrait-letter.$${LANGUAGE}.pdf; \
	done

	cp -a manual/en/build/en/_sisu $(DESTDIR)/usr/share/doc/live-manual

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf manual/*/build

distclean: clean
	rm -rf build

rebuild: distclean build
