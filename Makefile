name    := debian-live-manual
version := 0.1
date    := $(shell date)

all: clean build-html build-pdf build-text

clean:
	rm -rf $(name).html
	rm -f $(name).pdf $(name).wiki $(name).txt
	rm -f $(name).tpt version.ent

version.ent:
	rm -f $@
	echo "<!entity version \"$(version)\">" >> $@
	echo "<!entity date \"$(date)\">" >> $@

build-%: version.ent
	debiandoc2$* $(name).sgml

.PHONY: all clean
