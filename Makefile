# Makefile

SHELL := sh -e

LANGUAGES = en $(shell cd manual/po && ls)

FORMATS = epub html odf pdf txt

DEBUG = 0

all: build

test:
	@echo "Checking for syntax errors... [not implemented yet - FIXME]"
	@echo "Checking for spelling errors... [not implemented yet - FIXME]"

tidy:
	# Removing useless whitespaces at EOL
	for FILE in manual/en/*.ssm manual/en/*.ssi; \
	do \
		sed -i -e 's|[ \t]*$$||' $${FILE}; \
	done

build: clean
	#FIXME: do a proper dependency-based build
	#FORMATS = epub html odf pdf txt
	#...
	#%.pdf: $(sisu_sources)
	#	sisu-pdf -v live-manual.ssm
	#etc.

	@# FIXME: sisu-concordance sisu-pg sisu-sqlite

	cd $(CURDIR)/manual; \
	sisu --configure
	for LANGUAGE in $(LANGUAGES); \
	do \
		for FORMAT in $(FORMATS); \
		do \
			cd $(CURDIR)/manual; \
			sisu-$${FORMAT} -v $${LANGUAGE}/live-manual.ssm; \
			if [ "$${FORMAT}" = "html" ] ; \
			then \
			    for FILE in ../build/manual/html/*.$${LANGUAGE}.html ../build/manual/html/live-manual/*.$${LANGUAGE}.html; \
			    do \
				    bin/fix-sisu-html.rb $${FILE}; \
				    ([ $(DEBUG) -gt 0 ] || rm -f $${FILE}~); \
			    done; \
			fi ; \
		done; \
	done; \


autobuild: build
	cd build/manual && rm -rf manifest toc.html; \
	set +e; for LANGUAGE in $(LANGUAGES); \
	do \
		FROMDIR=$(CURDIR)/manual/$${LANGUAGE}; \
		TODIR=$(CURDIR)/build/manual; \
		cp $${FROMDIR}/index.html.in $${TODIR}; \
		sed -e "s|@DATE_BUILD@|$(shell LC_ALL=C date -R)|" \
		    -e "s|@DATE_CHANGE@|$(shell LC_ALL=C git log | grep -m1 Date | awk -FDate: '{ print $2 }' | sed -e 's|  ||g')|" \
		$${TODIR}/index.html.in > $${TODIR}/index.$${LANGUAGE}.html; \
		rm $${TODIR}/index.html.in; \
	done

commit: tidy test
	$(MAKE) -C manual rebuild

	@if grep -qs fuzzy manual/po/*/*; \
	then \
		echo "" ; \
		echo "There are some fuzzy strings. You can run 'make translate' to fix them." ; \
		exit 1 ; \
	fi

	@echo
	@echo "You may now proceed...please do:"
	@echo
	@echo "  * git add ."
	@echo "  * git commit -a -m \"Your commit message.\""
	@echo "  * git push "

install:
		FROMDIR=$(CURDIR)/build/manual; \
		TODIR=$(DESTDIR)/usr/share/doc/live-manual; \
	cd $${FROMDIR} && rm -rf manifest index.html toc.html; \
	mkdir -p $${TODIR}; \
	cp -a $(CURDIR)/build/manual/* $(DESTDIR)/usr/share/doc/live-manual

uninstall:
	rm -rf $(DESTDIR)/usr/share/doc/live-manual

clean:
	rm -rf build
	rm -f manual/en/*~

distclean: clean
	rm -rf build

rebuild: distclean build

translate:
	@if grep -qs fuzzy manual/po/*/*; \
	then \
		./manual/bin/find-fuzzy.sh ; \
	else \
		echo "There are no fuzzy strings to translate." ; \
	fi
