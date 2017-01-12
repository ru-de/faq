#!/bin/bash

DIR=`dirname $0`
EXIT_CODE=0

find *.md -exec blackfriday-tool {} {}.html \;
go build -o $DIR/spell-checker $DIR/spell-checker.go

cat $DIR/dictionary.dic | tr '\n' '|' | sed 's/\x27/\\x27/g' > dictionary_processed

DICT_REGEXP=$(cat dictionary_processed | sed 's/|/[^[:alnum:]]\\|/g')
DICT_REGEXP_EOF=$(cat dictionary_processed | sed 's/|$//g' | sed 's/|/$\\|/g')
DICT_REGEXP="$DICT_REGEXP$DICT_REGEXP_EOF$"

git diff HEAD^ --name-status | grep "^D" -v | sed 's/^.\t//g' > changed_files

while read FILE; do
    echo -n "Проверка файла $FILE на опечатки... ";
    OUTPUT=$(cat "$FILE" | sed "s/$DICT_REGEXP//gi" | sed 's/https\?:[^ ]*//g' | sed "s/[(][^)]*\.md[)]//g" | hunspell -d russian-aot,ru_RU,de_DE,en_US | $DIR/spell-checker);
    OUTPUT_EXIT_CODE=$?

    if [ $OUTPUT_EXIT_CODE -ne 0 ]; then
        EXIT_CODE=1
        echo "ошибка";
        echo "$OUTPUT";
    else
        echo "пройдена";
    fi

    echo
done < changed_files

while read FILE; do
    if [ -f "${FILE}.html" ]; then
        grep -Po '(?<=href=")http[^"]*(?=")' "${FILE}.html" > links

        if [ -s links ]; then
            echo "Проверка файла $FILE на битые ссылки... ";
            while read LINK; do
                echo -n "Ссылка $LINK ...";
                LINK=$(echo "$LINK" | sed -e 's/\[/\\\[/g' -e 's/\]/\\\]/g' -e 's/\&amp;/\&/g')
                status=$(curl --insecure -XGET -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36" -m 10 -L -s --head -w %{http_code} $LINK -o /dev/null)
                expectedStatus=$(grep $LINK files/known_url.txt | cut -d',' -f1)

                if [ -z "$expectedStatus" ]; then
                    expectedStatus="200"
                fi

                if [ "$status" != "$expectedStatus" ]; then
                    EXIT_CODE=1
                    echo "недоступна с кодом $status, ожидается $expectedStatus";
                else
                    echo "доступна";
                fi

                echo
            done < links

            echo
        fi
    fi
done < changed_files

exit $EXIT_CODE
