# Makefile for the WAW slides

OUTPUT_DIR = ../result
COMPILE = ./compile.sh

CSS = _include/css/*.css  _include/css/print/*.css  _include/css/theme/*.css 
JS = _include/js/*.js
REQ_FILES = $(OUTPUT_DIR)/css \
		$(OUTPUT_DIR)/js \
		$(OUTPUT_DIR)/lib \
		$(OUTPUT_DIR)/img

all: $(OUTPUT_DIR) $(REQ_FILES) \
	example \
	$(OUTPUT_DIR)/index.html

clean:
	rm -rf $(OUTPUT_DIR)/css
	rm -rf $(OUTPUT_DIR)/img
	rm -rf $(OUTPUT_DIR)/js
	rm -rf $(OUTPUT_DIR)/lib
	rm -rf $(OUTPUT_DIR)

.PHONY: example
example: 
	@cd 01_example && $(MAKE) all


$(OUTPUT_DIR)/index.html: $(OUTPUT_DIR) \
		$(OUTPUT_DIR)/01_example.html
	./index.sh . > $(OUTPUT_DIR)/index.html

$(OUTPUT_DIR):
	mkdir $(OUTPUT_DIR)

$(OUTPUT_DIR)/css: $(OUTPUT_DIR) _include/css/*
	rsync -a _include/css $(OUTPUT_DIR)/

$(OUTPUT_DIR)/js: $(OUTPUT_DIR) _include/js/*
	rsync -a _include/js $(OUTPUT_DIR)/

$(OUTPUT_DIR)/lib: $(OUTPUT_DIR) _include/lib/* 
	rsync -a _include/lib $(OUTPUT_DIR)/

$(OUTPUT_DIR)/img: $(OUTPUT_DIR) _include/img/*
	mkdir -p $@
	rsync -a _include/img $(OUTPUT_DIR)/

.PHONY: clean all deploy prereq
