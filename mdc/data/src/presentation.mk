# Makefile to be included for the subprojects
# to compile the slides

CHAPTER := $(shell grep "resultfile" ./metadata.properties | sed -E "s/resultfile=//g")
TEMP_DIR = $(shell grep "temp_dir" ./metadata.properties | sed -E "s/temp_dir=//g")


OUTPUT_DIR = ../../result
COMPILE = ../compile.sh
LATEX = pdflatex
MAKEINDEX = makeindex
RENDER = phantomjs ../render_slide.js
TEX = ../_include/tex/*.tex

.PHONY: all
all: $(OUTPUT_DIR) \
		$(TEMP_DIR) \
		$(info $$TEMP_DIR is [${TEMP_DIR}]) \
		$(OUTPUT_DIR)/$(CHAPTER).html \
		$(OUTPUT_DIR)/$(CHAPTER)_plain.html \
		$(OUTPUT_DIR)/$(CHAPTER).pdf \
		$(OUTPUT_DIR)/$(CHAPTER)-Skript.pdf

.PHONY: clean
clean:
	rm -rf $(TEMP_DIR)

$(OUTPUT_DIR)/$(CHAPTER).html: *.md metadata.properties img/*
	$(COMPILE) . slide $@
	rsync -a img/* $(OUTPUT_DIR)/img/
 
$(OUTPUT_DIR)/$(CHAPTER)_plain.html: *.md metadata.properties img/*
	$(COMPILE) . plain $@
	rsync -a img/* $(OUTPUT_DIR)/img/

$(OUTPUT_DIR)/$(CHAPTER).pdf: *.md metadata.properties img/* $(TEMP_DIR) $(TEX)
	$(COMPILE) . tex-slide $(TEMP_DIR)/$(CHAPTER).tex
	cp ../_include/tex/* $(TEMP_DIR)
	rsync -a img/* $(TEMP_DIR)/img/
	cd $(TEMP_DIR) ; $(LATEX) -draftmode $(CHAPTER).tex
	cd $(TEMP_DIR) ; $(LATEX) $(CHAPTER).tex
	cat $(TEMP_DIR)/$(CHAPTER).pdf > $(OUTPUT_DIR)/$(CHAPTER).pdf

$(OUTPUT_DIR)/$(CHAPTER)-Skript.pdf: *.md metadata.properties img/* $(TEMP_DIR) $(TEX)
	$(COMPILE) . tex-plain $(TEMP_DIR)/$(CHAPTER)-Skript.tex
	cp ../_include/tex/* $(TEMP_DIR)
	rsync -a img/* $(TEMP_DIR)/img/
	cd $(TEMP_DIR) ; $(LATEX) -draftmode $(CHAPTER)-Skript.tex
	cd $(TEMP_DIR) ; $(MAKEINDEX) $(CHAPTER)-Skript.idx
	cd $(TEMP_DIR) ; $(LATEX) -draftmode $(CHAPTER)-Skript.tex
	cd $(TEMP_DIR) ; $(LATEX) $(CHAPTER)-Skript.tex
	cat $(TEMP_DIR)/$(CHAPTER)-Skript.pdf > $(OUTPUT_DIR)/$(CHAPTER)-Skript.pdf

$(TEMP_DIR):
	mkdir -p $(TEMP_DIR)
