DB2MAN=/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/manpages/docbook.xsl
XP=xsltproc -''-nonet

MANPAGE=molly-guard.8

all: $(MANPAGE)

%.8: %.xml
	$(XP) $(DB2MAN) $<

man: $(MANPAGE)
	man -l $<
.PHONY: man

clean:
	rm -f $(MANPAGE)
.PHONY: clean

