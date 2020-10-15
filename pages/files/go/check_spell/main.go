package main

import (
    "fmt"
    "os"
    "github.com/ewgRa/ci-utils/src/diff_liner"
    "github.com/ewgRa/ci-utils/src/hunspell_parser"
    "github.com/google/go-github/github"
    "flag"
    "encoding/json"
)

func main() {
    prLiner := flag.String("pr-liner", "", "Pull request liner")
    hunspellParsedFile := flag.String("hunspell-parsed-file", "", "Hunspell parsed file name")
    file := flag.String("file", "", "File name that checked")
    commit := flag.String("commit", "", "Commit")
    flag.Parse()

    if *prLiner == "" || *hunspellParsedFile == "" || *file == "" || *commit == "" {
        flag.Usage()
        os.Exit(1)
    }

    linerResp := diff_liner.ReadLinerResponse(*prLiner)

    hunspellParsedResp := hunspell_parser.ReadHunspellParserResponse(*hunspellParsedFile)

    var comments []*github.PullRequestComment

    for _, resp := range hunspellParsedResp {
        prLine := linerResp.GetDiffLine(*file, resp.Line)

        if prLine == 0 {
            continue
        }

        body := fmt.Sprintf("Возможная ошибка в слове \"**%s**\".\n Варианты правильного написания \"**%s**\".\nЕсли слово \"%s\" является правильным, добавьте его в files/dictionary.dic", resp.Word, resp.Alternative, resp.Word)

        comments = append(comments, &github.PullRequestComment{
            Body: &body,
            CommitID: commit,
            Path: file,
            Position: &prLine,
        })
    }

    if len(comments) > 0 {
        jsonData, err := json.Marshal(comments)

        if err != nil {
            panic(err)
        }

        fmt.Println(string(jsonData))
    }
}
