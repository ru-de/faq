#!/bin/bash

set -xe

apt-get -yqq update && apt-get install -y hunspell hunspell-ru hunspell-en-us hunspell-de-de
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

go get ./...
go get -u github.com/ewgRa/ci-utils/utils/diff_liner
go get -u github.com/ewgRa/ci-utils/utils/hunspell_parser
go get -u github.com/ewgRa/ci-utils/utils/github_comments_diff
go get -u github.com/ewgRa/ci-utils/utils/github_comments_send

mkdir $GOPATH/ci-scripts/check_spell
cp $DIR/check_spell.go $GOPATH/ci-scripts/check_spell/check_spell.go
go build -o /tmp/check_spell $GOPATH/ci-scripts/check_spell/check_spell.go

mkdir $GOPATH/ci-scripts/check_links
cp $DIR/check_links.go $GOPATH/ci-scripts/check_links/check_links.go

go build -o /tmp/check_links $GOPATH/ci-scripts/check_links/check_links.go

