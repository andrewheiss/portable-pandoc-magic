#!/usr/bin/env Rscript

# string::stri_count_words() counts, um, words. That's its whole job. But it
# doesn't count them like Microsoft Word counts them, and academic publishing
# portals tend to care about Word-like counts. For instance, Word considers
# hyphenated words to be one word, while stringr counts them as two (and even
# worse, stringi counts / as word boundaries, so URLs can severely inflate your
# word count).
#
# Also, academic writing typically doesn't count the title, abstract, table
# text, figure captions, or equations as words in the manuscript (and it
# SHOULDN'T count bibliographies, but it always seems to ugh).
#
# This script parses the rendered manuscript HTML, removes extra elements,
# adjusts the text so that stringi treats it more like Word, and then provides a
# more accurate word count.

suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(stringi))

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  ms_file <- "paper.html"
} else {
  ms_file <- args[1]
}

# Read the HTML file
ms_raw <- read_html(ms_file)

# Extract just the article, ignoring title, abstract, etc.
ms <- ms_raw %>%
  html_nodes("article")

# Get rid of figures, tables, and math
xml_remove(ms %>% html_nodes("figure"))
xml_remove(ms %>% html_nodes("table"))
xml_remove(ms %>% html_nodes(".display"))  # Block math
xml_replace(ms %>% html_nodes(".inline"), read_xml("<span>MATH</span>")) %>%
  invisible()

# Go through each child element in the article and extract it
ms_cleaned_list <- map(html_children(ms), ~ {
  .x %>%
    html_text(trim = TRUE) %>%
    # ICU counts hyphenated words as multiple words, so replace - with DASH
    str_replace_all("\\-", "DASH") %>%
    # ICU also counts / as multiple words, so URLs go crazy. Replace / with SLASH
    str_replace_all("\\/", "SLASH") %>%
    # ICU *also* counts [things] in bracketss multiple times, so kill those too
    str_replace_all("\\[|\\]", "") %>%
    # Other things to ignore
    str_replace_all("×", "")
})

# Get count of words! (close enough to Word)
stri_count_words(ms_cleaned_list) %>% 
  sum() %>% 
  scales::comma() %>% 
  cat(., "words in manuscript\n")

# Word counts in each paragraph
# stri_count_words(ms_cleaned_list)

# Export intermediate Word file for comparison
# paste(ms_cleaned_list, collapse = "\n\n") %>%
#   pander::Pandoc.convert(text = ., format = "docx")
