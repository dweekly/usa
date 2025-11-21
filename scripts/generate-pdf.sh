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
  - \usepackage{eso-pic}
  - \AddToShipoutPictureBG*{\AtPageUpperLeft{\raisebox{-2in}{\hspace{2.75in}\includegraphics[width=3in]{assets/logo-300.png}}}}
---

TITLEPAGE

# Add living document notice
cat >> "$TEMP_DIR/combined.md" <<'NOTICE'

\newpage

\thispagestyle{empty}

\vspace*{2in}

\begin{center}
\Large\textbf{This is a Living Document}
\end{center}

\normalsize

This PDF was generated on \textbf{NOTICE
printf "%s" "$PDF_DATE" >> "$TEMP_DIR/combined.md"
cat >> "$TEMP_DIR/combined.md" <<'NOTICE'
} and represents a snapshot of the project at that time.

\textbf{United States of Awesome} is designed to evolve continuously based on:

\begin{itemize}
\item New research and evidence
\item Public feedback and critique
\item Policy developments and real-world testing
\item Contributions from experts and citizens
\end{itemize}

\vspace{0.5em}

\textbf{For the latest version and to contribute:}

\begin{center}
\texttt{https://github.com/dweekly/usa}
\end{center}

\vspace{0.5em}

At the GitHub repository, you can:

\begin{itemize}
\item View the most current version of all chapters
\item Submit issues with questions or concerns
\item Propose improvements via pull requests
\item Review the complete version history
\item Join ongoing policy discussions
\end{itemize}

\vspace{0.5em}

This work is open-source nation-building. Your input matters.

\newpage

NOTICE

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
