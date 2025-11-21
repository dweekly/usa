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

# Generate timestamp
PDF_DATE=$(date "+%B %d, %Y")

# Create output directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "Building PDF book..."

# Combine all markdown files in order
cat > "$TEMP_DIR/combined.md" <<TITLEPAGE
---
title: "United States of Awesome"
subtitle: "A Game Plan for the Greatest Country on Earth to Rock the 21st Century"
author: "David E. Weekly"
date: "Version 0.1 — Living Draft — PDF generated $PDF_DATE"
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
toc: false
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
  - \usepackage{eso-pic}
  - \AddToShipoutPictureBG*{\AtPageUpperLeft{\raisebox{-2in}{\hspace{2.75in}\includegraphics[width=3in]{assets/logo-300.png}}}}
---

TITLEPAGE

# Add living document notice using printf to avoid heredoc issues
{
    printf "\n\\\\newpage\n\n"
    printf "\\\\thispagestyle{empty}\n\n"
    printf "\\\\vspace*{2in}\n\n"
    printf "\\\\begin{center}\n"
    printf "\\\\Large\\\\textbf{This is a Living Document}\n"
    printf "\\\\end{center}\n\n"
    printf "\\\\normalsize\n\n"
    printf "This PDF was generated on \\\\textbf{%s} and represents a snapshot of the project at that time.\n\n" "$PDF_DATE"
    printf "\\\\textbf{United States of Awesome} is designed to evolve continuously based on:\n\n"
    printf "\\\\begin{itemize}\n"
    printf "\\\\item New research and evidence\n"
    printf "\\\\item Public feedback and critique\n"
    printf "\\\\item Policy developments and real-world testing\n"
    printf "\\\\item Contributions from experts and citizens\n"
    printf "\\\\end{itemize}\n\n"
    printf "\\\\vspace{0.5em}\n\n"
    printf "\\\\textbf{For the latest version and to contribute:}\n\n"
    printf "\\\\begin{center}\n"
    printf "\\\\texttt{https://github.com/dweekly/usa}\n"
    printf "\\\\end{center}\n\n"
    printf "\\\\vspace{0.5em}\n\n"
    printf "At the GitHub repository, you can:\n\n"
    printf "\\\\begin{itemize}\n"
    printf "\\\\item View the most current version of all chapters\n"
    printf "\\\\item Submit issues with questions or concerns\n"
    printf "\\\\item Propose improvements via pull requests\n"
    printf "\\\\item Review the complete version history\n"
    printf "\\\\item Join ongoing policy discussions\n"
    printf "\\\\end{itemize}\n\n"
    printf "\\\\vspace{0.5em}\n\n"
    printf "This work is open-source nation-building. Your input matters.\n\n"
} >> "$TEMP_DIR/combined.md"

# Add README content (skip duplicate Overview heading - it's in the chapters)
{
    sed -n '13,55p' README.md
} >> "$TEMP_DIR/combined.md"

# Add all chapters in order (strip horizontal rules and add page breaks only between chapters)
first_chapter=true
for chapter in chapters/*.md; do
    if [ -f "$chapter" ]; then
        # Add page break before each chapter except the first
        if [ "$first_chapter" = false ]; then
            printf "\n\\\\newpage\n\n" >> "$TEMP_DIR/combined.md"
        fi
        first_chapter=false

        # Remove standalone horizontal rules
        grep -v "^---$" "$chapter" >> "$TEMP_DIR/combined.md"
    fi
done

# Generate PDF using Pandoc with LaTeX
echo "Running Pandoc to generate PDF..."

pandoc "$TEMP_DIR/combined.md" \
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
