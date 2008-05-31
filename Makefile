prefix?=/usr/local
etc_prefix?=$(prefix)
DST=$(DEST)$(prefix)
ETCDIR=$(DEST)$(etc_prefix)/etc/molly-guard

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
	sed -e 's,@ETC_PREFIX@,$(etc_prefix),g' $< > $@

install: shutdown molly-guard.8.gz
	mkdir -m755 --parent $(DST)/share/molly-guard
	install -m755 -oroot -oroot shutdown $(DST)/share/molly-guard

	mkdir -m755 --parent $(DST)/sbin
	ln -s ../share/molly-guard/shutdown $(DST)/sbin/poweroff
	ln -s ../share/molly-guard/shutdown $(DST)/sbin/halt
	ln -s ../share/molly-guard/shutdown $(DST)/sbin/reboot
	ln -s ../share/molly-guard/shutdown $(DST)/sbin/shutdown

	mkdir -m755 --parent $(ETCDIR)
	install -m644 -oroot -oroot rc $(ETCDIR)
	cp -r run.d $(ETCDIR) \
	  && chown root.root $(ETCDIR)/run.d && chmod 755 $(ETCDIR)/run.d

	mkdir -m755 --parent $(ETCDIR)/messages.d

	mkdir -m755 --parent $(DST)/share/man/man8
	install -m644 -oroot -groot molly-guard.8.gz $(DST)/share/man/man8
.PHONY: install
