#!/usr/bin/env python3

# Find all pandoc-style citations in a Markdown file and extract their
# corresponding BibTeX entries from a larger, master BibTeX file into a new
# .bib file. Perfect for creating a clean bibliography file for distribution.
#
# Requires bibtool (http://www.gerd-# neugebauer.de/software/TeX/BibTool/index.en.html), 
# which is easily installed on OS X with Homebrew (`brew install bib-tool`)
#
# Inspired and based on David Sanson's extract_bib.rb script: https://gist.github.com/dsanson/1383132
#
# Usage: bib_extract.py [-h] [--bibtex_file BIBTEX_FILE]
#                       [--bibtools_resource BIBTOOLS_RESOURCE]
#                       md_file output_file 
#

# Configure the three variables below for your system:
default_bib_file = "/Users/andrew/Dropbox/Readings/Papers.bib"
default_resource_file = "/Users/andrew/bin/bibtool.rsc"
bibtool_path = "/usr/local/bin/bibtool"


# Load libraries
import argparse
import re
import os
from subprocess import run, PIPE
# import subprocess

# Get command line information
parser = argparse.ArgumentParser(description='Generate a BibTeX file containing citation entries in a given pandoc Markdown file.',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('md_file', type=argparse.FileType('r'), 
                    help='the path to a Markdown file')
parser.add_argument('output_file', type=str, 
                    help='the name of the new BibTeX file')
parser.add_argument('--bibtex_file', type=str, 
                    default=default_bib_file,
                    help='the path to the existing master BibTeX file')
parser.add_argument('--bibtools_resource', type=str, 
                    default=default_resource_file,
                    help='the path to the a custom resource file for bibtool')
args = parser.parse_args()

# Save arguments
md_file = args.md_file
output_file = os.path.abspath(args.output_file)
bib_file = os.path.abspath(args.bibtex_file)

# See http://www.gerd-neugebauer.de/software/TeX/BibTool/bibtool.pdf and
# http://www.gerd-neugebauer.de/software/TeX/BibTool/ref_card.pdf for
# documentation on resource files and command line options.
bibtool_settings = os.path.abspath(args.bibtools_resource)

# Read Markdown file
md = md_file.read()

# Find all citekeys
# MAYBE: This finds anything that starts with @, meaning that stuff like
# e-mail addresses and  Twitter @usernames will be picked up. Maybe someday
# make sure this only looks inside [brackets]. That said, bibtool skips over
# any spurious cite keys, so it doesn't really matter.
citekeys = re.findall("@(.*?)[\\.,;\\] ]", md)

# Build regex for bibtool's extract command
# reg = "\\(" + "\\)\\|\\(".join(citekeys) + "\\)"
reg = " ".join(['-X "{0}"'.format(i) for i in citekeys])

# Run bibtool with all required arguments
bibtool_command = [bibtool_path, "-q", "-s",
                   "-r", bibtool_settings, 
                   reg, 
                   "-i", bib_file,
                   "-o", output_file]

response = run(" ".join(bibtool_command), 
                          stderr=PIPE,
                          shell=True)
