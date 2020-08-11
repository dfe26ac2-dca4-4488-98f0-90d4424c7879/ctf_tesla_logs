# Configuration
PYTHON_VER?=python3
PYTHON_VENV?=virtualenv_${PYTHON_VER}
PYTHON_BIN?=$(shell which ${PYTHON_VER})

.PHONY: all
all:
	@echo "Please select from one of the below targets:"
	@echo "--------------------------------------------"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

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

tesla_autogen.dbc: final_log venv
	./candump2dbc.py ${^}

.PHONY:
ovaltine: tesla_autogen.dbc
	candump vcan0 | cantools decode ${^}

.PHONY: ovaltine2
ovaltine2: tesla_autogen.dbc
	cantools monitor --channel vcan0 tesla_autogen.dbc
