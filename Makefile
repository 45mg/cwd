PREFIX ?= /usr/local

.PHONY: install clean

install:
	mkdir -p $(PREFIX)/bin
	install -m 0755 cwd $(PREFIX)/bin/cwd

clean:
	rm -f $(PREFIX)/bin/cwd
