# Configuration
BUS?=can0
RATE?=500000

PYTHON_VER?=python3
PYTHON_VENV?=virtualenv_${PYTHON_VER}
PYTHON_BIN?=$(shell which ${PYTHON_VER})

.PHONY: all
all:
	@echo "Please select from one of the below targets:"
	@echo "--------------------------------------------"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: debug
debug:
	$(info $${PYTHON_VER}=${PYTHON_VER})
	$(info $${PYTHON_VENV}=${PYTHON_VENV})
	$(info $${PYTHON_BIN}=${PYTHON_BIN})

.PHONY: clean-all
clean-all:
	${MAKE} clean
	rm -rf ${PYTHON_VENV}

.PHONY: clean
clean:

.PHONY: venv
venv: ${PYTHON_VENV}/bin/python
	@echo "...venv..."

${PYTHON_VENV}/bin/python:
	${PYTHON_BIN} -mvenv ${PYTHON_VENV}
	${PYTHON_VENV}/bin/pip install --upgrade pip wheel
	${PYTHON_VENV}/bin/pip install -r requirements.txt

.PHONY: dbc
dbc: opendbc OBD2-DBC-MDF4/CSS-Electronics-OBD2-v1.3.dbc

opendbc:
	git clone https://github.com/commaai/opendbc.git

OBD2-DBC-MDF4.zip:
	wget https://canlogger1000.csselectronics.com/files/guides/mdf-intro/OBD2-DBC-MDF4.zip

OBD2-DBC-MDF4/CSS-Electronics-OBD2-v1.3.dbc: OBD2-DBC-MDF4.zip
	unzip ${^}

can_db.dbc: can_db.json
	${PYTHON_VENV}/bin/canconvert ${^} ${@}
