#!/usr/bin/env python3

# Replace text with different text for anonymity.
#
# You must specify the replacement dictionary in a CSV file with columns named
# "original" and "replacement":
#
#   original,replacement
#   old text,new text
#
# usage: anonymize.py [-h] replacements [input_file] [output]
#
# Recommended usage: Send the Markdown output to stdout (default) and pipe
# into pandoc for instant preprocessing:
#
#   anonymize.py replacements.csv document.md | pandoc -f markdown -t html -o document.html

# Load libraries
import argparse
import sys
import re
import csv

# Get command line arguments
parser = argparse.ArgumentParser(description='Replace text with different text for anonymity.')
parser.add_argument('replacements', type=argparse.FileType('r'),
                    help='CSV file of replacements (with columns named "original" and "replacement")')
parser.add_argument('input_file', type=argparse.FileType('r'),
                    nargs='?', default=sys.stdin,
                    help='file to anonymize')
parser.add_argument('output', type=argparse.FileType('w'),
                    nargs='?', default=sys.stdout,
                    help='the name of the output file (defaults to stdout)')
args = parser.parse_args()


# Load replacements CSV as a dictionary
with args.replacements as file:
    reader = csv.DictReader(file, skipinitialspace=True)
    replacements = {row['original']: row['replacement'] for row in reader}


# Replace keys in the dictionary with values
def anonymize(text, repl):
    # Sort keys by length, in reverse
    for item in sorted(repl.keys(), key=len, reverse=True):
        # Replace stuff
        text = re.sub(item, repl[item], text)

    return(text)


# All done!
with args.output as f:
    f.write(anonymize(args.input_file.read(), replacements))
