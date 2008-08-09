AUTOBUILD	:= autobuild
LANGUAGES       := de fr

include Makefile.common

autobuild: clean translations all
	set -e; for FORMAT in $(FORMATS); do \
		mkdir -p $(AUTOBUILD)/$$FORMAT; \
		cp *.$$FORMAT $(AUTOBUILD)/$$FORMAT; \
	done
	sed '{s/__UPDATED__/$(shell LC_ALL=C date)/;s%/__LANG__%%;}' index.html.in > $(AUTOBUILD)/index.html
	set -e; for LANGUAGE in $(LANGUAGES); do \
		for FORMAT in $(FORMATS); do \
			mkdir -p $(AUTOBUILD)/$$FORMAT/$$LANGUAGE; \
			cp $$LANGUAGE/*.$$FORMAT $(AUTOBUILD)/$$FORMAT/$$LANGUAGE; \
		done; \
		sed "{s/__UPDATED__/$(shell LC_ALL=C date)/;s/__LANG__/$$LANGUAGE/;}" $$LANGUAGE/index.html.in > $(AUTOBUILD)/index.$$LANGUAGE.html; \
	done

po4a:
	po4a -k 0 po4a/live-manual.cfg;

translations: po4a
	set -e; for LANGUAGE in $(LANGUAGES); do \
		mkdir -p $$LANGUAGE; \
		cp -r ent/ $$LANGUAGE; \
		cp -r xsl/ $$LANGUAGE; \
		cp Makefile.common $$LANGUAGE/Makefile; \
		$(MAKE) -C $$LANGUAGE; \
	done

clean:
	-rm -rf $(LANGUAGES)
	rm -f *.html *.pdf *.txt
	rm -f ent/version.ent

.PHONY: clean po4a translations
