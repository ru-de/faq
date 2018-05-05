#!/bin/bash

DIR=`dirname $0`

git config --global core.quotepath false

git diff HEAD^ --name-status | grep "^D" -v | sed 's/^.\t//g' | grep "\.md$" > /tmp/changed_files

curl -sH "Accept: application/vnd.github.v3.diff.json" https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST > /tmp/pr.diff
cat /tmp/pr.diff | diff_liner > /tmp/pr_liner.json

rm -f /tmp/comments.json
touch /tmp/comments.json

while read FILE; do
    COMMIT=$(git log --pretty=format:"%H" -1 "$FILE");
    echo "Проверка изменений в файле $FILE на опечатки... ";

    cat "$FILE" | sed 's/https\?:[^ ]*//g' | sed "s/[(][^)]*\.md[)]//g" | sed "s/[(]files[^)]*[)]//g" | hunspell -d dictionary,russian-aot-utf8,ru_RU,de_DE-utf8,en_US-utf8 > /tmp/hunspell.out
    cat /tmp/hunspell.out | hunspell_parser > /tmp/hunspell_parsed.json
    /tmp/check_spell -file "$FILE" -commit=$COMMIT -pr-liner /tmp/pr_liner.json -hunspell-parsed-file /tmp/hunspell_parsed.json >> /tmp/comments.json

    echo "Проверка изменений в файле $FILE на недоступные ссылки... ";

    /tmp/check_links -file "$FILE" -commit=$COMMIT -pr-liner /tmp/pr_liner.json -expected-codes files/expected_codes.csv >> /tmp/comments.json

    echo
done < /tmp/changed_files

curl -s https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls/$TRAVIS_PULL_REQUEST/comments > /tmp/pr_comments.json

github_comments_diff -comments /tmp/comments.json -exists-comments /tmp/pr_comments.json > /tmp/send_comments.json

OUTPUT=$(cat /tmp/comments.json | (! grep .));
OUTPUT_EXIT_CODE=$?

if [ $OUTPUT_EXIT_CODE -ne 0 ]; then
    cat /tmp/send_comments.json
    echo $TRAVIS_REPO_SLUG $TRAVIS_PULL_REQUEST
    github_comments_send -file /tmp/send_comments.json -repo $TRAVIS_REPO_SLUG -pr $TRAVIS_PULL_REQUEST
    EXIT_CODE=1
fi

exit $EXIT_CODE
