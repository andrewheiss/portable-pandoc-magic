#!/usr/bin/env python3

# Replace any images that use PDFs with PNGs, since Word and HTML
# struggle with displaying PDFs
#
# Usage: replace_pdfs [-h] [input_file] [output]
#
# Recommended usage: Send the Markdown output to stdout (default) and pipe
# into pandoc for immediate processing:
#
#   replace_pdfs.py document.md | pandoc -f markdown -t docx -o document.docx
#
# TODO: Use subprocess instead of system - but doing that does weird stuff with the path

# Load libraries
import re
import argparse
import sys
import subprocess
from os import path, system

# Get command line arguments
parser = argparse.ArgumentParser(description='Replace image PDFs with PNGs')
parser.add_argument('input_file', type=argparse.FileType('r'),
                    nargs='?', default=sys.stdin,
                    help='Markdown file to preprocess')
parser.add_argument('output', type=argparse.FileType('w'),
                    nargs='?', default=sys.stdout,
                    help='the name of the output file (defaults to stdout)')
parser.add_argument('--convert', dest='convert', action='store_true')
parser.add_argument('--no-convert', dest='convert', action='store_false')
parser.set_defaults(convert=False)
args = parser.parse_args()

# Save arguments
input_file = args.input_file.read()
output = args.output
convert = args.convert

# Find images
# md_images = re.compile(r"!\[([^\[]*)\]\(([^\)]+)\)")
md_images = re.compile(r"!\[(.*)\]\((.*)\)")


# Convert a list of PDFs to PNGs
def pdf2png(images):
    for image in images:
        file_name, file_extension = path.splitext(image)
        command = 'sips -s format png "' + path.abspath(image) + '" --out "' + path.abspath(file_name) + '.png" > /dev/null 2>&1'
        system(command)


# Replace `.pdf` in the () part of the image syntax with `.png`
def replace_extension(match):
    converted_name = match.group(2).replace('.pdf', '.png')
    return("![{0}]({1})".format(match.group(1), converted_name))


# Find all PDFs and convert them
if convert:
    images = [image[1] for image in re.findall(md_images, input_file)]
    pdf2png(images)

# Replace calls to PDF images with PNGs
result = re.sub(md_images, replace_extension, input_file)

# Output results
with output as f:
    f.write(result)
