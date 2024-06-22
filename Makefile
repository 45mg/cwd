PREFIX ?= /usr/local

.PHONY: cwd clean

cwd:
	mkdir -p $(PREFIX)/bin
	install -m 0755 cwd $(PREFIX)/bin/cwd

clean:
	rm -f $(PREFIX)/bin/cwd
