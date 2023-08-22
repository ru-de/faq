#!/bin/bash

set -xe

PWD_DIR=`pwd`
DIR=`dirname $0`

apt-get -yqq update && apt-get install -y curl wget unzip binutils hunspell hunspell-ru hunspell-en-us hunspell-de-de jq
wget https://extensions.libreoffice.org/assets/downloads/48/dict_ru_ru-aot-0.4.5.oxt -O /tmp/dictionary.otx 
unzip /tmp/dictionary.otx -d /tmp
cp /tmp/*.dic /usr/share/hunspell
cp /tmp/*.aff /usr/share/hunspell
chmod +r /usr/share/hunspell/*

dicList=""russian-aot""
for dic in $dicList
    do
        cat /usr/share/hunspell/$dic.dic | iconv --from KOI8-R --to UTF-8 > /usr/share/hunspell/$dic-utf8.dic
        cat /usr/share/hunspell/$dic.aff | iconv --from KOI8-R --to UTF-8 | sed 's/SET KOI8-R/SET UTF-8/' > /usr/share/hunspell/$dic-utf8.aff
done

dicList=""de_DE" "en_US""
for dic in $dicList
    do
        cat /usr/share/hunspell/$dic.dic | iconv --from ISO8859-1 --to UTF-8 > /usr/share/hunspell/$dic-utf8.dic
        cat /usr/share/hunspell/$dic.aff | iconv --from ISO8859-1 --to UTF-8 | sed 's/SET ISO8859-1/SET UTF-8/' > /usr/share/hunspell/$dic-utf8.aff
done

(cat $DIR/dictionary.dic; echo) | sed '/^$/d' | wc -l > /tmp/dictionary.dic
(cat $DIR/dictionary.dic; echo) | sed '/^$/d' >> /tmp/dictionary.dic

echo "SET UTF-8" >> /tmp/dictionary.aff
mv /tmp/dictionary.* /usr/share/hunspell

go install github.com/ewgRa/ci-utils/cmd/diff_liner@latest
go install github.com/ewgRa/ci-utils/cmd/hunspell_parser@latest
go install github.com/ewgRa/ci-utils/cmd/github_comments_diff@latest
go install github.com/ewgRa/ci-utils/cmd/github_comments_send@latest

cd $DIR/go
go build -o /tmp/check_spell check_spell/main.go
go build -o /tmp/check_links check_links/main.go
cd $PWD_DIR
