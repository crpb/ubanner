# Copyright © 2024 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

PYTHON = python3

PREFIX = /usr/local
DESTDIR =

bindir = $(PREFIX)/bin
mandir = $(PREFIX)/share/man
zshcompletiondir = $(PREFIX)/share/zsh/site-functions

.PHONY: all
all: ;

.PHONY: install
install: ubanner
	install -d $(DESTDIR)$(bindir)
	python_exe=$$($(PYTHON) -c 'import sys; print(sys.executable)') && \
	sed \
		-e "1 s@^#!.*@#!$$python_exe@" \
		-e "s#^basedir = .*#basedir = '$(basedir)/'#" \
		$(<) > $(<).tmp
	install $(<).tmp $(DESTDIR)$(bindir)/$(<)
	rm $(<).tmp
	# manual page:
	install -d $(DESTDIR)$(mandir)/man1
	install -p -m644 doc/$(<).1 $(DESTDIR)$(mandir)/man1/
	# zsh completion:
	install -d $(DESTDIR)$(zshcompletiondir)
	install -p -m644 completion/zsh/_* $(DESTDIR)$(zshcompletiondir)

.PHONY: test
test: verbose=
test: ubanner
	prove $(and $(verbose),-v)

.PHONY: test-installed
test-installed: verbose=
test-installed: $(or $(shell command -v ubanner;),$(bindir)/ubanner)
	UBANNER_TEST_TARGET=ubanner prove $(and $(verbose),-v)

.PHONY: clean
clean:
	rm -f *.tmp

.error = GNU make is required

# vim:ts=4 sts=4 sw=4 noet
