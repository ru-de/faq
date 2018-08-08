#!/bin/bash

set -xe

DIR=`dirname $0`

apt-get -yqq update && apt-get install -y hunspell hunspell-ru hunspell-en-us hunspell-de-de jq
curl -s https://extensions.libreoffice.org/extensions/russian-spellcheck-dictionary.-based-on-works-of-aot-group > .dict_page
cat .dict_page | grep -oP "<a href.+title=\"Current release for the project\"" | grep -oP "https://extensions.libreoffice.org/extensions/russian-spellcheck-dictionary.-based-on-works-of-aot-group/[^\"]+" > .current_release
echo -n $(cat .current_release) > .current_release
echo -n "/@@download[^\"]+" >> .current_release
cat .dict_page | grep -oP -f .current_release | wget -q -i - -O /tmp/dictionary.otx
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

go get ./...
go get -u github.com/ewgRa/ci-utils/cmd/diff_liner
go get -u github.com/ewgRa/ci-utils/cmd/hunspell_parser
go get -u github.com/ewgRa/ci-utils/cmd/github_comments_diff
go get -u github.com/ewgRa/ci-utils/cmd/github_comments_send

go build -o /tmp/check_spell $DIR/go/check_spell/main.go
go build -o /tmp/check_links $DIR/go/check_links/main.go
