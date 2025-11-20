#!/bin/bash
#
# generate-chapter-pdf.sh - Generate a PDF for a single chapter
#
# DESCRIPTION:
#   Creates a standalone PDF document from a single chapter markdown file
#   with professional typography and formatting.
#
# REQUIREMENTS:
#   - pandoc (3.x or later)
#   - xelatex (from MacTeX or BasicTeX)
#
# USAGE:
#   ./scripts/generate-chapter-pdf.sh <chapter-number>
#   ./scripts/generate-chapter-pdf.sh <chapter-file>
#
# EXAMPLES:
#   ./scripts/generate-chapter-pdf.sh 1
#   ./scripts/generate-chapter-pdf.sh chapters/01-foundations.md
#
# OUTPUT:
#   output/chapter-<number>-<name>.pdf
#

set -euo pipefail

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <chapter-number> or <chapter-file>"
    echo ""
    echo "Examples:"
    echo "  $0 1"
    echo "  $0 chapters/01-foundations.md"
    exit 1
fi

# Configuration
OUTPUT_DIR="output"
TEMP_DIR="$OUTPUT_DIR/temp"

# Determine chapter file
CHAPTER_INPUT="$1"
if [[ "$CHAPTER_INPUT" =~ ^[0-9]+$ ]]; then
    # Input is a number, find the corresponding chapter
    CHAPTER_PATTERN=$(printf "chapters/%02d-*.md" "$CHAPTER_INPUT")
    # Find first matching file
    CHAPTER_FILE=""
    for file in $CHAPTER_PATTERN; do
        if [ -f "$file" ]; then
            CHAPTER_FILE="$file"
            break
        fi
    done

    if [ -z "$CHAPTER_FILE" ]; then
        echo "Error: Chapter $CHAPTER_INPUT not found"
        exit 1
    fi
else
    # Input is a file path
    CHAPTER_FILE="$CHAPTER_INPUT"
    if [ ! -f "$CHAPTER_FILE" ]; then
        echo "Error: File not found: $CHAPTER_FILE"
        exit 1
    fi
fi

# Extract chapter name for output filename
CHAPTER_BASENAME=$(basename "$CHAPTER_FILE" .md)
OUTPUT_FILE="$OUTPUT_DIR/chapter-${CHAPTER_BASENAME}.pdf"

# Create output directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "Building PDF for chapter: $CHAPTER_FILE"

# Extract chapter title from first markdown heading
CHAPTER_TITLE=$(grep -m 1 "^# " "$CHAPTER_FILE" | sed 's/^# //' | sed 's/\*\*//g')

# Create combined markdown with frontmatter
cat > "$TEMP_DIR/chapter.md" << FRONTMATTER
---
title: "$CHAPTER_TITLE"
subtitle: "United States of Awesome"
author: "David E. Weekly"
date: "Version 0.1 — Living Draft"
documentclass: article
papersize: letter
fontsize: 11pt
geometry:
- margin=1in
mainfont: "Palatino"
sansfont: "Helvetica Neue"
monofont: "Menlo"
linestretch: 1.15
numbersections: false
linkcolor: blue
urlcolor: blue
header-includes:
  - \usepackage{fancyhdr}
  - \usepackage{graphicx}
  - \usepackage{booktabs}
  - \usepackage{longtable}
  - \usepackage{microtype}
  - \usepackage{xcolor}
  - \definecolor{quotebg}{RGB}{248,248,248}
  - \definecolor{quoteborder}{RGB}{180,180,180}
  - \let\oldquote\quote
  - \let\endoldquote\endquote
  - \renewenvironment{quote}{\begin{oldquote}\itshape\color{black!80}}{\end{oldquote}}
  - \pagestyle{fancy}
  - \fancyhf{}
  - \fancyhead[LE,RO]{\thepage}
  - \fancyhead[RE]{\nouppercase{\leftmark}}
  - \fancyhead[LO]{\nouppercase{\rightmark}}
  - \renewcommand{\headrulewidth}{0.4pt}
  - \setlength{\parskip}{0.5em}
  - \setlength{\parindent}{0pt}
---

FRONTMATTER

# Add chapter content, stripping horizontal rules
grep -v "^---$" "$CHAPTER_FILE" >> "$TEMP_DIR/chapter.md"

# Generate PDF using Pandoc with LaTeX
echo "Running Pandoc to generate PDF..."

pandoc "$TEMP_DIR/chapter.md" \
    -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    --standalone \
    2>&1 | grep -v "Missing character" || true

# Check if PDF was created successfully
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "✓ PDF generated successfully: $OUTPUT_FILE ($FILE_SIZE)"
    echo ""
    echo "Opening PDF..."
    open "$OUTPUT_FILE"
else
    echo "✗ PDF generation failed"
    exit 1
fi

# Clean up temp files
rm -rf "$TEMP_DIR"

echo "Done!"
