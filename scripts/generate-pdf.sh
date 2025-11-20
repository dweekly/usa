#!/bin/bash
#
# generate-pdf.sh - Generate a professional PDF book from README and chapters
#
# DESCRIPTION:
#   Combines the README overview and all chapter markdown files into a single
#   professionally formatted PDF using Pandoc and XeLaTeX.
#
# REQUIREMENTS:
#   - pandoc (3.x or later)
#   - xelatex (from MacTeX or BasicTeX)
#
# USAGE:
#   ./scripts/generate-pdf.sh
#
# OUTPUT:
#   output/united-states-of-awesome.pdf
#

set -euo pipefail

# Configuration
OUTPUT_DIR="output"
OUTPUT_FILE="$OUTPUT_DIR/united-states-of-awesome.pdf"
TEMP_DIR="$OUTPUT_DIR/temp"

# Create output directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "Building PDF book..."

# Combine all markdown files in order
cat > "$TEMP_DIR/combined.md" << 'TITLEPAGE'
---
title: "United States of Awesome"
subtitle: "A Game Plan for the Greatest Country on Earth to Rock the 21st Century"
author: "David E. Weekly"
date: "Version 0.1 — Living Draft"
documentclass: book
papersize: letter
fontsize: 11pt
geometry:
- margin=1in
- bindingoffset=0.5in
mainfont: "Palatino"
sansfont: "Helvetica Neue"
monofont: "Menlo"
linestretch: 1.15
toc: true
toc-depth: 1
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

TITLEPAGE

# Add README content (overview before TOC)
{
    printf "\n# Overview\n\n"
    sed -n '13,55p' README.md
} >> "$TEMP_DIR/combined.md"

# Add all chapters in order (strip horizontal rules)
for chapter in chapters/*.md; do
    if [ -f "$chapter" ]; then
        printf "\n" >> "$TEMP_DIR/combined.md"
        # Remove standalone horizontal rules (--- on its own line)
        grep -v "^---$" "$chapter" >> "$TEMP_DIR/combined.md"
    fi
done

# Generate PDF using Pandoc with LaTeX
echo "Running Pandoc to generate PDF..."

pandoc "$TEMP_DIR/combined.md" \
    -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=1 \
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
