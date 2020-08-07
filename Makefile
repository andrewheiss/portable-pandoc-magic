# Put this Makefile and the accompanying pandoc support folder in the same
# directory as the paper you're writing. You can use it to create .html, .docx
# (through LibreOffice's .odt), and .pdf (through xelatex) files from your
# Markdown or R Markdown file.
# 
# Instructions:
#	1. Ensure you have the following things installed:
#		- R (and these packages: tidyverse, rvest, stringi)
#		- python3
#		- LibreOffice
#		- pandoc
#		- pandoc-include (pip install pandoc-include)
#		- pandoc-citeproc (brew install pandoc-citeproc on macOS)
#		- pandoc-crossref (brew install pandoc-crossref on macOS)
#		- bibtools (brew install bib-tools on macOS)
#		- gawk (brew install gawk on macOS)
#		- Fonts (as needed) in pandoc/fonts/
# 
#	2. Set SRC and BIB_FILE to the appropriate file names
# 
#	3. Change other variables in the "Modifiable variables" section as needed
# 
#	4. Run one of the following:
#		- make md:		Convert R Markdown to regular Markdown
#		- make html:	Create HTML file
#		- make tex:		Create nice PDF through xelatex in TEX_DIR folder
#		- make mstex: 	Create manuscripty PDF through xelatex in TEX_DIR folder
#		- make odt: 	Create ODT file
#		- make docx:	Create Word file (through LibreOffice)
#		- make ms: 		Create manuscripty ODT file
#		- make msdocx:	Create manuscripty Word file (through LibreOffice)
#		- make bib:		Extract bibliography references to a standalone .bib file
#		- make count:	Count the words in the manuscript
#		- make clean:	Remove all output files
# 
#	    You can also combine these: e.g. `make html tex mstex docx bib count`
# 
# By default, all targets run `make clean` beforehand. You can remove that to
# rely on make's timestamp checking. However, if you do this, you'll need to add
# all the document's images, etc. as dependencies, which means it might be
# easier to just clean and delete everything every time you rebuild.


# ----------------------
# Modifiable variables
# ----------------------
# Main document (either .md or .Rmd)
# SRC = md-paper.md
SRC = rmd-paper.Rmd

# Bibliography file
BIB_FILE = references.bib

# Move all figures and tables to the end (only happens in mstex target)
ENDFLOAT = FALSE

# Remove identifying information (only happens in mstex and msdocx targets)
# Use pandoc/bin/replacements.csv to map identifying information to anonymous output
ANONYMIZED = FALSE

# Add version control information in footer (only happens in tex target)
VC_ENABLE = FALSE

# Output folder for LaTeX PDFs (uses a separate folder so all the intermediate
# TeX stuff doesn't clutter up your main directory)
TEX_DIR = tex_out

# CSL stylesheet
# Download CSL files from https://github.com/citation-style-language/styles
# These are included in pandoc/csl/:
#	- american-political-science-association
#	- chicago-fullnote-bibliography
#	- chicago-fullnote-no-bib
#	- chicago-syllabus-no-bib
#	- apa
#	- apsa-no-bib
CSL = chicago-author-date

# LaTeX doesn't use pandoc-citeproc + CSL and instead lets biblatex handle the
# heavy lifting. There are three possible styles built in to the template:
#	- bibstyle-chicago-notes
#	- bibstyle-chicago-authordate
#	- bibstyle-apa
TEX_REF = bibstyle-chicago-authordate

# Word and HTML can choke on PDF images, so those targets use a helper script
# (pandoc/bin/replace_pdfs.py) to replace all references to PDFs with PNGs
# and--if needed--convert existing PDFs to PNG using sips. However, there are
# times when it's better to *not* convert to PNG on the fly, like when using
# high resolution PNGs exported from R with ggsave+Cairo. To disable on-the-fly
# conversion and supply your own PNGs, use `PNG_CONVERT = --no-convert` below. 
# The script will still replace references to PDFs with PNGs, but will not 
# convert the PDFs. To enable PNG conversion, use `PNG_CONVERT = ` 
PNG_CONVERT = --no-convert


# ----------------
# Pandoc options
# ----------------
# 
# You shouldn't really have to change anything here
# 
# Location of Pandoc support folder
PREFIX = pandoc

# Pandoc options to use for all document types
OPTIONS = markdown+simple_tables+table_captions+yaml_metadata_block+smart

# Cross reference options
CROSSREF = --filter pandoc-crossref -M figPrefix:"Figure" -M eqnPrefix:"Equation" -M tblPrefix:"Table"

# Move figures and tables to the end
ifeq ($(ENDFLOAT), TRUE)
	ENDFLOAT_PANDOC = -V endfloat
else
	ENDFLOAT_PANDOC =
endif

# Anonymize stuff if needed
ifeq ($(ANONYMIZED), TRUE)
	ANONYMIZE = | $(PREFIX)/bin/anonymize.py $(PREFIX)/bin/replacements.csv
else
	ANONYMIZE =
endif

# Enable fancy version control footers if needed
ifeq ($(VC_ENABLE), TRUE)
	VC_COMMAND = cd $(PREFIX)/bin && ./vc
	VC_PANDOC = -V pagestyle=athgit -V vc
else
	VC_COMMAND =
	VC_PANDOC =
endif


# --------------------
# Target definitions
# --------------------
MD_EXT = $(suffix $(SRC))
BASE = $(basename $(SRC))

# Targets
MD=$(SRC:$(MD_EXT)=.md)
HTML=$(SRC:$(MD_EXT)=.html)
TEX=$(SRC:$(MD_EXT)=.tex)
MS_TEX=$(SRC:$(MD_EXT)=-manuscript.tex)
ODT=$(SRC:$(MD_EXT)=.odt)
DOCX=$(SRC:$(MD_EXT)=.docx)
MS_ODT=$(SRC:$(MD_EXT)=-manuscript.odt)
MS_DOCX=$(SRC:$(MD_EXT)=-manuscript.docx)
BIB=$(SRC:$(MD_EXT)=.bib)

.PHONY: clean count

## all	:	Convert manuscript to Markdown, HTML, .odt, .docx, manuscripty .odt, 
## 		manuscripty .docx, and PDF *and* extract all citations into a standalone 
## 		.bib file
all:	clean $(MD) $(HTML) $(ODT) $(DOCX) $(MS_ODT) $(MS_DOCX) $(TEX) $(MS_TEX) $(BIB) count

## md	:	Convert manuscript to Markdown
md: 	clean $(MD)

## html	:	Convert manuscript to HTML
html:	clean $(HTML)

## tex	:	Convert manuscript to PDF (through XeLaTeX)
tex:	clean $(TEX)

## mstex	:	Convert manuscript to manuscripty PDF (through XeLaTeX)
mstex:	clean $(MS_TEX)

## odt	:	Convert manuscript to .odt
odt:	clean $(ODT)

## docx	:	Convert manuscript to .docx (through .odt)
docx:	clean $(DOCX)

## ms	:	Convert manuscript to manuscripty .odt
ms: 	clean $(MS_ODT)

## msdocx	:	Convert manuscript to manuscripty .docx (through .odt)
msdocx:	clean $(MS_DOCX)

## bib	:	Extract bibliography to standalone .bib file
bib:	$(BIB)


# --------------------
# Build instructions
# --------------------
%.md:	%.Rmd
	R --slave -e "set.seed(1234);knitr::knit('$<')"

%.html:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to HTML...$(NO_COLOR)"
	python $(PREFIX)/bin/replace_pdfs.py $(PNG_CONVERT) $< | \
	pandoc -r $(OPTIONS)+ascii_identifiers -s -w html \
		--filter pandoc-include \
		$(CROSSREF) \
		--default-image-extension=png \
		--mathjax \
		--table-of-contents \
		--metadata link-citations=true \
		--metadata linkReferences=true \
		--template=$(PREFIX)/templates/html.html \
		--css=$(PREFIX)/templates/ath-clean.css \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
		-o $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.tex:	%.md
	$(VC_COMMAND)
	@echo "$(WARN_COLOR)Converting Markdown to TeX using hikma-article template...$(NO_COLOR)"
	pandoc -r $(OPTIONS)+raw_tex -w latex -s \
		--filter pandoc-include \
		$(CROSSREF) \
		--default-image-extension=pdf \
		--pdf-engine=xelatex \
		--template=$(PREFIX)/templates/xelatex.tex \
		--biblatex \
		-V $(TEX_REF) \
		--bibliography=$(BIB_FILE) \
		-V chapterstyle=hikma-article \
		$(VC_PANDOC) \
		--shift-heading-level-by=0 \
		-o $@ $<
	@echo "$(WARN_COLOR)...converting TeX to PDF with latexmk (prepare for lots of output)...$(NO_COLOR)"
	latexmk -outdir=$(TEX_DIR) -xelatex -quiet $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%-manuscript.tex:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to TeX using generic manuscript template...$(NO_COLOR)"
	cat $< $(ANONYMIZE) | \
	pandoc -r $(OPTIONS)+raw_tex -w latex -s \
		--filter pandoc-include \
		$(CROSSREF) \
		$(ENDFLOAT_PANDOC) \
		--default-image-extension=pdf \
		--pdf-engine=xelatex \
		--template=$(PREFIX)/templates/xelatex-manuscript.tex \
		--biblatex \
		-V $(TEX_REF) \
		--bibliography=$(BIB_FILE) \
		--shift-heading-level-by=0 \
		-o $@
	@echo "$(WARN_COLOR)...converting TeX to PDF with latexmk (prepare for lots of output)...$(NO_COLOR)"
	latexmk -outdir=$(TEX_DIR) -xelatex -quiet $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.odt:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to .odt...$(NO_COLOR)"
	python $(PREFIX)/bin/replace_pdfs.py $(PNG_CONVERT) $< | \
	pandoc -r $(OPTIONS) -w odt \
		--filter pandoc-include \
		$(CROSSREF) \
		--default-image-extension=png \
		--template=$(PREFIX)/templates/odt.odt \
		--reference-doc=$(PREFIX)/templates/reference.odt \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
		-o $@
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%-manuscript.odt:	%.md
	@echo "$(WARN_COLOR)Converting Markdown to .odt using manuscript template...$(NO_COLOR)"
	python $(PREFIX)/bin/replace_pdfs.py $(PNG_CONVERT) $< $(ANONYMIZE) | \
	pandoc -r $(OPTIONS) -w odt \
		--filter pandoc-include \
		$(CROSSREF) \
		--default-image-extension=png \
		--template=$(PREFIX)/templates/odt-manuscript.odt \
		--reference-doc=$(PREFIX)/templates/reference-manuscript.odt \
		--filter pandoc-citeproc \
		--csl=$(PREFIX)/csl/$(CSL).csl \
		--bibliography=$(BIB_FILE) \
		-o $@

%.docx: %.odt
	@echo "$(WARN_COLOR)Converting .odt to .docx...$(NO_COLOR)"
	/Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to docx --outdir . $<
	@echo "$(WARN_COLOR)Removing .odt file...$(NO_COLOR)"
	rm $<
	@echo "$(OK_COLOR)All done!$(NO_COLOR)"

%.bib: %.md
	@echo "$(WARN_COLOR)Extracing all citations into a standalone .bib file...$(NO_COLOR)"
	python ${PREFIX}/bin/bib_extract.py --bibtex_file $(BIB_FILE) --bibtools_resource ${PREFIX}/bin/bibtool.rsc $< $@

## count	:	Get Word-like word count
count: html
	@echo "$(WARN_COLOR)Count manuscript words like Word...$(NO_COLOR)"
	Rscript ${PREFIX}/bin/word_count.R $(BASE).html

## clean	:	Delete all manuscript-related targets
clean:
	@echo "$(WARN_COLOR)Deleting all existing targets...$(NO_COLOR)"
	rm -f $(addsuffix .html, $(BASE)) \
		$(addsuffix .odt, $(BASE)) $(addsuffix .docx, $(BASE)) \
		$(addsuffix -manuscript.odt, $(BASE)) $(addsuffix -manuscript.docx, $(BASE)) \
		$(addsuffix .tex, $(BASE)) $(addsuffix -manuscript.tex, $(BASE)) $(addsuffix .bib, $(BASE))

# Self-documenting Makefiles from The Carpentries
# https://swcarpentry.github.io/make-novice/08-self-doc/index.html
## help	:	Show possible targets
.PHONY: help
help: Makefile
	@sed -n 's/^##//p' $<


# -------------------
# Color definitions
# -------------------
NO_COLOR    = \x1b[0m
BOLD_COLOR	= \x1b[37;01m
OK_COLOR    = \x1b[32;01m
WARN_COLOR  = \x1b[33;01m
ERROR_COLOR = \x1b[31;01m
