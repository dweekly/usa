# Building PDFs

This repository includes scripts to generate professional PDFs from the book content.

## Prerequisites

- **Pandoc** (3.x or later): `brew install pandoc`
- **XeLaTeX** (included with MacTeX): `brew install --cask mactex` or `brew install basictex`

## Generate Full Book PDF

To build the complete book with all chapters:

```bash
./scripts/generate-pdf.sh
```

This will:
1. Combine the README overview and all chapters in order
2. Generate a professionally formatted PDF with:
   - Clean, modern typography (Palatino for body text)
   - Table of contents
   - Page numbers and headers
   - Proper spacing and layout
   - Optimized for printing

Output: `output/united-states-of-awesome.pdf`

## Generate Single Chapter PDF

To build a PDF for just one chapter:

```bash
./scripts/generate-chapter-pdf.sh <chapter-number>
```

Or specify the chapter file directly:

```bash
./scripts/generate-chapter-pdf.sh chapters/01-foundations.md
```

Examples:
```bash
./scripts/generate-chapter-pdf.sh 1        # Chapter I - Foundations
./scripts/generate-chapter-pdf.sh 7        # Chapter VII - Immigration
./scripts/generate-chapter-pdf.sh 12       # Chapter XII - Defense
```

Output: `output/chapter-<number>-<name>.pdf`

## Customization

You can edit `scripts/generate-pdf.sh` to customize:
- Fonts (mainfont, sansfont, monofont)
- Page margins and geometry
- Line spacing
- Table of contents depth
- Header/footer styling

## Font Notes

The default configuration uses:
- **Body text**: Palatino (excellent for long-form reading)
- **Sans-serif**: Helvetica Neue (for headings and UI elements)
- **Monospace**: Menlo (for code blocks)

These fonts provide excellent legibility both on-screen and in print.
