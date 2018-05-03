#!/bin/bash

DIR=`dirname $0`

git config --global core.quotepath false

go build -o /tmp/check_spell $DIR/check_spell.go
go build -o /tmp/check_links $DIR/check_links.go

(cat $DIR/dictionary.dic; echo) | sed '/^$/d' | wc -l > /tmp/dictionary.dic
(cat $DIR/dictionary.dic; echo) | sed '/^$/d' >> /tmp/dictionary.dic

echo "SET UTF-8" >> /tmp/dictionary.aff
sudo mv /tmp/dictionary.* /usr/share/hunspell

git diff HEAD^ --name-status | grep "^D" -v | sed 's/^.\t//g' | grep "\.md$" > /tmp/changed_files

curl -sH "Accept: application/vnd.github.v3.diff.json" https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST > /tmp/pr.diff
cat /tmp/pr.diff | diff_liner > /tmp/pr_liner.json

rm -f /tmp/comments.json
touch /tmp/comments.json

while read FILE; do
    echo -n "Проверка изменений в файле $FILE на опечатки... ";

    cat "$FILE" | sed 's/https\?:[^ ]*//g' | sed "s/[(][^)]*\.md[)]//g" | sed "s/[(]files[^)]*[)]//g" | hunspell -d dictionary,russian-aot-utf8,ru_RU,de_DE-utf8,en_US-utf8 > /tmp/hunspell.out
    cat /tmp/hunspell.out | hunspell_parser > /tmp/hunspell_parsed.json
    /tmp/check_spell -file "$FILE" -pr-liner /tmp/pr_liner.json -hunspell-parsed-file /tmp/hunspell_parsed.json >> /tmp/comments.json

    echo -n "Проверка изменений в файле $FILE на недоступные ссылки... ";

    /tmp/check_links -file "$FILE" -pr-liner /tmp/pr_liner.json -expected-codes files/expected_codes.csv >> /tmp/comments.json

    echo
done < /tmp/changed_files

OUTPUT=$(cat /tmp/comments.json | (! grep .));
OUTPUT_EXIT_CODE=$?

if [ $OUTPUT_EXIT_CODE -ne 0 ]; then
    # FIXME XXX: send to github
    EXIT_CODE=1
fi

exit $EXIT_CODE
