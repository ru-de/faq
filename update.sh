#!/bin/bash

DE_FAQ_DIR=/tmp/de_faq

rm -rf $DE_FAQ_DIR

git clone https://github.com/ru-de/faq.git $DE_FAQ_DIR --depth=1

rm $DE_FAQ_DIR/CONTRIBUTING.md

(echo "---\nlayout: default\n---\n"; cat "$DE_FAQ_DIR/README.md") > index.md
rm $DE_FAQ_DIR/README.md

mkdir $DE_FAQ_DIR/tmp_pages

for file in $DE_FAQ_DIR/*.md; do
  bname=$(basename "$file")
  title=$(basename "$file" .md)
  (echo -e "---\ntitle: $title\nlayout: default\n---\n"; cat "$file") > "$DE_FAQ_DIR/tmp_pages/$bname"
done

rm -rf pages
mkdir pages
cp -R $DE_FAQ_DIR/files pages
cp $DE_FAQ_DIR/tmp_pages/*.md pages
