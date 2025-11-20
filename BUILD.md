# Building the PDF

This repository includes a script to generate a professional PDF book from the README and all chapters.

## Prerequisites

- **Pandoc** (3.x or later): `brew install pandoc`
- **XeLaTeX** (included with MacTeX): `brew install --cask mactex` or `brew install basictex`

## Usage

Simply run:

```bash
./generate-pdf.sh
```

This will:
1. Combine the README and all chapters in order
2. Generate a professionally formatted PDF with:
   - Clean, modern typography (Palatino for body text)
   - Table of contents
   - Page numbers and headers
   - Proper spacing and layout
   - Optimized for printing

The output will be saved to: `output/united-states-of-awesome.pdf`

## Customization

You can edit `generate-pdf.sh` to customize:
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
