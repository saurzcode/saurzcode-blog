#!/bin/bash

for file in jekyll-export/_posts/*.md; do
  # Extract YAML front matter (everything until the second ---)
  awk '/^---$/ {count++} count<2 {print > "frontmatter.tmp"} count>=2 {print > "body.tmp"}' "$file"

  # Convert body from HTML to Markdown using pandoc
  pandoc --from=html --to=markdown_strict --wrap=preserve body.tmp -o body_converted.tmp

  # Combine front matter and converted body
  cat frontmatter.tmp body_converted.tmp > "${file}.converted"

  # Replace original file with converted file
  mv "${file}.converted" "$file"

  # Clean up temp files
  rm frontmatter.tmp body.tmp body_converted.tmp

  echo "Converted $file"
done
