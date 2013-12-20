# Makefile to be included for the subprojects
# to compile the slides

OUTPUT_DIR = ../../result
COMPILE = ../compile.sh
LATEX = pdflatex
RENDER = phantomjs ../render_slide.js
TEMP_DIR = ~/Temp/$(CHAPTER)

CSS = ../_include/css/*.css  ../_include/css/print/*.css  ../_include/css/theme/*.css 
JS = ../_include/js/*.js

.PHONE: all
all: $(OUTPUT_DIR) \
		$(OUTPUT_DIR)/$(CHAPTER).html \
		$(OUTPUT_DIR)/$(CHAPTER)_plain.html \
#		$(OUTPUT_DIR)/$(CHAPTER)_print.html \

pdf: $(OUTPUT_DIR) \
		$(OUTPUT_DIR)/$(CHAPTER).pdf


$(OUTPUT_DIR)/$(CHAPTER).html: *.md metadata.properties img/*
	$(COMPILE) . slide $@
	rsync -a img/* $(OUTPUT_DIR)/img/

$(OUTPUT_DIR)/$(CHAPTER)_plain.html: *.md metadata.properties img/*
	$(COMPILE) . plain $@
	rsync -a img/* $(OUTPUT_DIR)/img/

$(OUTPUT_DIR)/$(CHAPTER).pdf: *.md metadata.properties img/* $(TEMP_DIR)
	$(COMPILE) . tex $(TEMP_DIR)/$(CHAPTER).tex
	cp ../_include/tex/* $(TEMP_DIR)
	rsync -a img/* $(TEMP_DIR)/img/
	cd $(TEMP_DIR) ; $(LATEX) $(CHAPTER).tex
	cp $(TEMP_DIR)/$(CHAPTER).pdf $(OUTPUT_DIR)

$(TEMP_DIR):
	mkdir -p $(TEMP_DIR)
