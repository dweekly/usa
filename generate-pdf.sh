#!/bin/bash
set -euo pipefail

# Generate PDF book from README and chapters
# Uses Pandoc with LaTeX for professional typography

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

# Add README content (skip the title and TOC section)
echo "" >> "$TEMP_DIR/combined.md"
echo "\\newpage" >> "$TEMP_DIR/combined.md"
echo "" >> "$TEMP_DIR/combined.md"
echo "# Overview" >> "$TEMP_DIR/combined.md"
echo "" >> "$TEMP_DIR/combined.md"

# Extract overview content from README (lines 13-57, before the Chapters section)
sed -n '13,57p' README.md >> "$TEMP_DIR/combined.md"

# Add page break before chapters
echo "" >> "$TEMP_DIR/combined.md"
echo "\\newpage" >> "$TEMP_DIR/combined.md"
echo "" >> "$TEMP_DIR/combined.md"

# Add all chapters in order
for chapter in chapters/*.md; do
    if [ -f "$chapter" ]; then
        echo "" >> "$TEMP_DIR/combined.md"
        echo "\\newpage" >> "$TEMP_DIR/combined.md"
        echo "" >> "$TEMP_DIR/combined.md"
        cat "$chapter" >> "$TEMP_DIR/combined.md"
    fi
done

# Generate PDF using Pandoc with LaTeX
echo "Running Pandoc to generate PDF..."

pandoc "$TEMP_DIR/combined.md" \
    -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=1 \
    --standalone

# Check if PDF was created successfully
if [ -f "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
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
