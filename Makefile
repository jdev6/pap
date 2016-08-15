DEST := /usr/bin
LOVEPATH := `which love`
FILES := *.lua lib

.PHONY: install

all: pap.love
	cat $(LOVEPATH) builds/pap.love > builds/pap

pap.love:
	[ -d builds ] || mkdir builds
	mkdir lovetmp
	cp $(FILES) ./lovetmp -r
	cd lovetmp && zip -9 -q -r ../builds/pap.love .
	rm -rf ./lovetmp

install:
	install builds/pap $(DEST)