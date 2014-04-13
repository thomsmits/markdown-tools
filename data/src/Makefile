# Makefile for the slides

OUTPUT_DIR = ../result
COMPILE = ./compile.sh
MAKEALL = $(MAKE) -f ../presentation.mk all
MAKECLEAN = $(MAKE) -f ../presentation.mk clean
REQ_FILES = $(OUTPUT_DIR)/css \
		$(OUTPUT_DIR)/js \
		$(OUTPUT_DIR)/lib \
		$(OUTPUT_DIR)/img

all: $(OUTPUT_DIR) $(REQ_FILES) \
	example

clean:
	rm -rf $(OUTPUT_DIR)
	@cd 01_example && $(MAKECLEAN)

.PHONY: example
example: $(OUTPUT_DIR)/img
	@cd 01_example && $(MAKEALL)

$(OUTPUT_DIR):
	mkdir $(OUTPUT_DIR)

$(OUTPUT_DIR)/img: $(OUTPUT_DIR) _include/img/*
	mkdir -p $@
	rsync -a _include/img $(OUTPUT_DIR)/

$(OUTPUT_DIR)/css: $(OUTPUT_DIR) _include/css/*
	rsync -a _include/css $(OUTPUT_DIR)/

$(OUTPUT_DIR)/js: $(OUTPUT_DIR) _include/js/*
	rsync -a _include/js $(OUTPUT_DIR)/

$(OUTPUT_DIR)/lib: $(OUTPUT_DIR) _include/lib/* 
	rsync -a _include/lib $(OUTPUT_DIR)/

.PHONY: clean all deploy prereq
