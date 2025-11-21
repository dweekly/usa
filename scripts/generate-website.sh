#!/bin/bash
#
# generate-website.sh - Generate HTML versions of all chapters for website
#
# DESCRIPTION:
#   Converts all markdown chapters to HTML for hosting on GitHub Pages
#
# REQUIREMENTS:
#   - pandoc (3.x or later)
#
# USAGE:
#   ./scripts/generate-website.sh
#
# OUTPUT:
#   docs/chapters/*.html
#

set -euo pipefail

# Configuration
DOCS_DIR="docs"
CHAPTERS_DIR="chapters"
OUTPUT_CHAPTERS_DIR="$DOCS_DIR/chapters"

# Create output directory
mkdir -p "$OUTPUT_CHAPTERS_DIR"

echo "Generating HTML chapters for website..."

# Create a shared CSS template for chapters
cat > "$OUTPUT_CHAPTERS_DIR/chapter-style.css" <<'CSS'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Charter, 'Palatino Linotype', Palatino, Georgia, serif;
    line-height: 1.75;
    color: #1a1a1a;
    background: #fafafa;
    padding: 2rem 1rem;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    background: white;
    padding: 3rem;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

header {
    border-bottom: 3px solid #c41e3a;
    padding-bottom: 1.5rem;
    margin-bottom: 2rem;
}

.logo {
    max-width: 400px;
    width: 100%;
    height: auto;
    margin-bottom: 1rem;
}

.breadcrumb {
    font-size: 0.9rem;
    color: #666;
    margin-top: 1rem;
}

.breadcrumb a {
    color: #0052a5;
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

h1, h2, h3, h4, h5, h6 {
    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
    font-weight: 700;
    margin-top: 2rem;
    margin-bottom: 1rem;
    color: #0052a5;
}

h1 {
    font-size: 2.5rem;
    color: #1a1a1a;
    border-bottom: 2px solid #c41e3a;
    padding-bottom: 0.5rem;
}

h2 {
    font-size: 1.8rem;
}

h3 {
    font-size: 1.4rem;
}

p {
    margin-bottom: 1.2rem;
}

blockquote {
    border-left: 4px solid #c41e3a;
    padding-left: 1.5rem;
    margin: 1.5rem 0;
    font-style: italic;
    color: #444;
}

ul, ol {
    margin-left: 2rem;
    margin-bottom: 1.2rem;
}

li {
    margin-bottom: 0.5rem;
}

a {
    color: #0052a5;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

strong {
    font-weight: 700;
    color: #1a1a1a;
}

em {
    font-style: italic;
}

code {
    background: #f5f5f5;
    padding: 0.2rem 0.4rem;
    border-radius: 3px;
    font-family: Menlo, Monaco, 'Courier New', monospace;
    font-size: 0.9em;
}

pre {
    background: #f5f5f5;
    padding: 1rem;
    border-radius: 5px;
    overflow-x: auto;
    margin-bottom: 1.2rem;
}

pre code {
    background: none;
    padding: 0;
}

footer {
    margin-top: 3rem;
    padding-top: 2rem;
    border-top: 2px solid #e5e5e5;
    text-align: center;
    color: #666;
    font-size: 0.9rem;
}

footer a {
    color: #0052a5;
}

@media (max-width: 768px) {
    .container {
        padding: 1.5rem;
    }

    h1 {
        font-size: 2rem;
    }

    h2 {
        font-size: 1.5rem;
    }
}
CSS

echo "Converting chapters to HTML..."

# Process each chapter
for chapter_file in "$CHAPTERS_DIR"/*.md; do
    if [ -f "$chapter_file" ]; then
        basename=$(basename "$chapter_file" .md)
        output_file="$OUTPUT_CHAPTERS_DIR/${basename}.html"

        # Extract chapter title
        chapter_title=$(grep -m 1 "^# " "$chapter_file" | sed 's/^# //' | sed 's/\*\*//g')

        echo "  Converting $basename..."

        # Create HTML with proper structure
        cat > "$output_file" <<HTMLHEADER
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$chapter_title - United States of Awesome">
    <title>$chapter_title | United States of Awesome</title>
    <link rel="stylesheet" href="chapter-style.css">
</head>
<body>
    <div class="container">
        <header>
            <a href="../index.html"><img src="../assets/logotext-800.png" alt="United States of Awesome" class="logo"></a>
            <div class="breadcrumb">
                <a href="../index.html">Home</a> → $chapter_title
            </div>
        </header>
        <main>
HTMLHEADER

        # Convert markdown to HTML (strip horizontal rules)
        grep -v "^---$" "$chapter_file" | pandoc -f markdown -t html >> "$output_file"

        cat >> "$output_file" <<HTMLFOOTER
        </main>
        <footer>
            <p>
                <strong>This is a living document.</strong>
                <a href="https://github.com/dweekly/usa/blob/main/$chapter_file">View source on GitHub</a> •
                <a href="https://github.com/dweekly/usa/issues/new">Provide feedback</a>
            </p>
            <p style="margin-top: 0.5rem;">
                <a href="../index.html">← Back to Home</a>
            </p>
        </footer>
    </div>
</body>
</html>
HTMLFOOTER
    fi
done

echo "✓ Website generation complete!"
echo "  Output: $OUTPUT_CHAPTERS_DIR/"
