#!/bin/bash

DIR=`dirname $0`
EXIT_CODE=0

go build -o $DIR/spell-checker $DIR/spell-checker.go

git diff HEAD^ --name-status | grep "^D" -v | awk '{print $2}' > changed_files

while read FILE; do
    echo -n "Проверка файла $FILE на опечатки... ";

    OUTPUT_RU=$(cat "$FILE" | hunspell -d russian-aot,en_US,de_DE,$DIR/dictionary | $DIR/spell-checker);
    RU_EXIT_CODE=$?
    OUTPUT_EN=$(cat "$FILE" | hunspell -d en_US,russian-aot,de_DE,$DIR/dictionary | $DIR/spell-checker);
    EN_EXIT_CODE=$?
    OUTPUT_DE=$(cat "$FILE" | hunspell -d de_DE,en_US,russian-aot,$DIR/dictionary | $DIR/spell-checker);
    DE_EXIT_CODE=$?

    if [ $RU_EXIT_CODE -ne 0 ] || [ $EN_EXIT_CODE -ne 0 ] || [ $DE_EXIT_CODE -ne 0 ]; then
        EXIT_CODE=1;
        echo "ошибка";
        echo "$OUTPUT_RU\n$OUTPUT_EN\n$OUTPUT_DE" | sort -n -k2 | uniq;
    else
        echo "пройдена";
    fi

    echo
done < changed_files

exit $EXIT_CODE
