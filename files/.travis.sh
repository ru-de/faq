#!/bin/bash

DIR=`dirname $0`
EXIT_CODE=0

go build -o $DIR/spell-checker $DIR/spell-checker.go

cat $DIR/dictionary.dic | tr '\n' '|' | sed 's/\x27/\\x27/g' > dictionary_processed

DICT_REGEXP=$(cat dictionary_processed | sed 's/|/[^[:alnum:]]\\|/g')
DICT_REGEXP_EOF=$(cat dictionary_processed | sed 's/|$//g' | sed 's/|/$\\|/g')
DICT_REGEXP="$DICT_REGEXP$DICT_REGEXP_EOF$"

git diff HEAD^ --name-status | grep "^D" -v | sed 's/^.\t//g' > changed_files

while read FILE; do
    echo -n "Проверка файла $FILE на опечатки... ";
    OUTPUT=$(cat "$FILE" | sed "s/$DICT_REGEXP//g" | sed 's/https\?:[^ ]*//g' | sed "s/[(][^)]*\.md[)]//g" | hunspell -d russian-aot,ru_RU,de_DE,en_US | $DIR/spell-checker);
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo "ошибка";
        echo "$OUTPUT";
    else
        echo "пройдена";
    fi

    echo
done < changed_files

exit $EXIT_CODE
