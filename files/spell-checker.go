package main

import (
    "fmt"
    "os"
    "bufio"
    "regexp"
    "strings"
)


type TypeResult struct {
    results []Result
}

type Result struct {
    line int
    word string
}

func main() {
    scanner := bufio.NewScanner(os.Stdin)
    types := parseHunspellOutput(scanner);

    _, ok := types["&"]

    if ok {
        var dropCol = regexp.MustCompile(`^([^ ]+) \d+ \d+:(.*)$`)
        var minimumWord = regexp.MustCompile(`^[^ ]{3}`)
        exitCode := 0

        for _, result := range types["&"].results {
            if minimumWord.MatchString(result.word) {
                exitCode = 1
                fmt.Println("Строка " + fmt.Sprintf("%v", result.line) + ": " + dropCol.ReplaceAllString(result.word, "$1 >$2"))
            }
        }

        os.Exit(exitCode)
    }
}

func parseHunspellOutput(scanner *bufio.Scanner) map[string]*TypeResult {
    line := 1;
    types := make(map[string]*TypeResult)

    scanner.Scan()

    for scanner.Scan() {
        text := scanner.Text()

        if text == "" {
            line++;
        } else {
            resultType := text[0:1]

            typeResult, ok := types[resultType]

            if !ok {
                typeResult = &TypeResult{}
                types[resultType] = typeResult
            }

            typeResult.results = append(typeResult.results, Result{line: line, word: strings.Trim(text[1:], " ")})
        }
    }

    return types
}
