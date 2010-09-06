# Makefile

SHELL := sh -e

LANGUAGES = en

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
	# FIXME: sisu-concordance sisu-pg sisu-sqlite
	for LANGUAGE in $(LANGUAGES); \
	do \
		cd $(CURDIR)/manual/$${LANGUAGE}; \
		sisu-epub live-manual.ssm; \
		sisu-html live-manual.ssm; \
		sisu-odf live-manual.ssm; \
		sisu-pdf live-manual.ssm; \
		sisu-txt live-manual.ssm; \
	done

autobuild: clean build
	rm -rf build
	cp -a html build

	for LANGUAGE in en $(shell cd manual/po && ls); \
	do \
		mkdir -p build/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/epub/live-manual.epub build/$${LANGUAGE}; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/[0-9]*.html manual/$${LANGUAGE}/build/$${LANGUAGE}/index.html build/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/opendocument.odt build/$${LANGUAGE}/live-manual.odt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/doc.html build/$${LANGUAGE}/live-manual.html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/plain.txt build/$${LANGUAGE}/live-manual.txt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.a4.pdf build/$${LANGUAGE}/live-manual.landscape-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.a4.pdf build/$${LANGUAGE}/live-manual.portrait-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.letter.pdf build/$${LANGUAGE}/live-manual.landscape-letter.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.letter.pdf build/$${LANGUAGE}/live-manual.portrait-letter.pdf; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|^ *||g')|" \
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
		mkdir -p $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/epub/live-manual.epub $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/[0-9]*.html manual/$${LANGUAGE}/build/$${LANGUAGE}/index.html $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/opendocument.odt $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.odt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/doc.html $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.html; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/plain.txt $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.txt; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.a4.pdf $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.landscape-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.a4.pdf $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.portrait-a4.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/landscape.letter.pdf $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.landscape-letter.pdf; \
		cp manual/$${LANGUAGE}/build/$${LANGUAGE}/live-manual/portrait.letter.pdf $(DESTDIR)/usr/share/doc/live-manual/$${LANGUAGE}/live-manual.portrait-letter.pdf; \
	done

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf manual/*/build

distclean: clean

rebuild: distclean build
