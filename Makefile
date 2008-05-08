name    := debian-live-manual
version := 0.1
date    := $(shell date)
out     := out/

all: autobuild

autobuild: distclean build-html build-text build-pdf build-ps clean
	mv $(out)/$(name).html/ $(out)/html
	sed -e 's/NAME/$(name)/g' -e 's/UPDATED/$(date)/' index.html.in > $(out)/index.html

clean:
	rm -f $(out)/version.ent
	rm -f $(out)/head.tmp
	rm -f $(out)/body.tmp
	rm -f $(out)/$(name).tpt

distclean:
	rm -rf $(out)

out/version.ent:
	mkdir -p $(out)
	echo "<!entity version \"$(version)\">" >> $@
	echo "<!entity date \"$(date)\">" >> $@

build-%: out/version.ent
	cd $(out) && debiandoc2$* ../$(name).sgml

.PHONY: all clean distclean autobuild
