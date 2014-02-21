prefix?=/usr/local
etc_prefix?=$(prefix)
DST=$(DEST)$(prefix)
ETCDIR=$(etc_prefix)/etc/molly-guard

# Detect Mac OS X systems
UNAME=$(shell uname)
ifeq ($(UNAME),Darwin)
DARWIN=1
endif

ifeq ($(DARWIN),1)
USER=root
GROUP=wheel
SCRIPTDIR=libexec/molly-guard
else
USER=root
GROUP=root
SCRIPTDIR=share/molly-guard
endif

all: molly-guard.8.gz shutdown

%.8: DB2MAN=/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/manpages/docbook.xsl
%.8: XP=xsltproc -''-nonet
%.8: %.xml
	$(XP) $(DB2MAN) $<

%.gz: %
	gzip -9 $<

man: molly-guard.8
	man -l $<
.PHONY: man

clean:
	rm -f shutdown
	rm -f molly-guard.8 molly-guard.8.gz
.PHONY: clean

shutdown: shutdown.in
	sed -e 's,@ETCDIR@,$(ETCDIR),g' $< > $@

install: shutdown molly-guard.8.gz
	mkdir -m755 -p $(DST)/$(SCRIPTDIR)
	install -m755 -o$(USER) -g$(GROUP) shutdown $(DST)/$(SCRIPTDIR)

	mkdir -m755 -p $(DST)/sbin
ifneq ($(DARWIN),1)
	ln -s ../$(SCRIPTDIR)/shutdown $(DST)/sbin/poweroff
endif
	ln -s ../$(SCRIPTDIR)/shutdown $(DST)/sbin/halt
	ln -s ../$(SCRIPTDIR)/shutdown $(DST)/sbin/reboot
	ln -s ../$(SCRIPTDIR)/shutdown $(DST)/sbin/shutdown

	mkdir -m755 -p $(DEST)/$(ETCDIR)
	install -m644 -o$(USER) -g$(GROUP) rc $(DEST)/$(ETCDIR)
	cp -r run.d $(DEST)/$(ETCDIR) \
	  && chown -R $(USER):$(GROUP) $(DEST)/$(ETCDIR)/run.d && chmod -R 755 $(DEST)/$(ETCDIR)/run.d

	mkdir -m755 -p $(DEST)/$(ETCDIR)/messages.d

	mkdir -m755 -p $(DST)/share/man/man8
	install -m644 -o$(USER) -g$(GROUP) molly-guard.8.gz $(DST)/share/man/man8
.PHONY: install
