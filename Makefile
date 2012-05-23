PREFIX=/usr/local
DESTDIR=

INSTDIR=$(DESTDIR)$(PREFIX)
INSTBIN=$(INSTDIR)/bin

all:
	@echo do nothing. try one of the targets:
	@echo install-all
	@echo install
	@echo install-twitter
	@echo install-tcli
	@echo install-stereomood
	@echo install-basm
	@echo uninstall

install:
	install -m 0755 OAuth.sh $(INSTBIN)

install-twitter: install
	install -m 0755 TwitterOAuth.sh $(INSTBIN)

install-tcli: install-twitter
	install -m 0755 tcli.sh $(INSTBIN)

install-stereomood: install
	install -m 0755 StereomoodOAuth.sh $(INSTBIN)

install-basm: install-stereomood
	install -m 0755 Basm.sh $(INSTBIN)

install-all: install-tcli install-basm


uninstall:
	rm -f $(INSTBIN)/OAuth.sh

	rm -f $(INSTBIN)/TwitterOAuth.sh
	rm -f $(INSTBIN)/tcli.sh

	rm -f $(INSTBIN)/StereomoodOAuth.sh
	rm -f $(INSTBIN)/Basm.sh

.PHONY: all install uninstall install-twitter install-tcli install-stereomood install-basm
