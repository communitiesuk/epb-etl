SHELL=/bin/bash

.PHONY: install
install: install_oic
	@echo "-> Bundle install" && \
		OCI_DIR="$(shell pwd)/vendor/oracle/instantclient_12_2" \
		bundle install 1> /dev/null
	@echo "-> Done"

install_oic:
	@echo "-> Install headers for ruby-oic8" && \
		bash ./scripts/install-ruby-oic8.sh
