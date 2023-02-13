# Makefile for the slides

OUTPUT_DIR = ../result
COMPILE = ./compile.sh
MAKEALL = $(MAKE) -f ../presentation.mk all
MAKECLEAN = $(MAKE) -f ../presentation.mk clean
REQ_FILES = $(OUTPUT_DIR)/js \
		$(OUTPUT_DIR)/css \
		$(OUTPUT_DIR)/dist \
		$(OUTPUT_DIR)/plugin

all: $(REQ_FILES) \
	example

clean:
	rm -rf $(OUTPUT_DIR)
	@cd 01_example && $(MAKECLEAN)

.PHONY: example
example: $(OUTPUT_DIR)
	mkdir -p $(OUTPUT_DIR)
	@cd 01_example && $(MAKEALL)

$(OUTPUT_DIR)/css: _include/css/*
	mkdir -p $(OUTPUT_DIR)/css
	rsync -a _include/css $(OUTPUT_DIR)/

$(OUTPUT_DIR)/js: _include/js/*
	mkdir -p $(OUTPUT_DIR)/js
	rsync -a _include/js $(OUTPUT_DIR)/

$(OUTPUT_DIR)/dist: _include/dist/*
	mkdir -p $(OUTPUT_DIR)/dist
	rsync -a _include/dist $(OUTPUT_DIR)/

$(OUTPUT_DIR)/plugin: _include/plugin/*
	mkdir -p $(OUTPUT_DIR)/plugin
	rsync -a _include/plugin $(OUTPUT_DIR)/

.PHONY: clean all deploy prereq
