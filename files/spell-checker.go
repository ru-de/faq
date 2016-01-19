package main

import (
    "fmt"
    "os"
    "bufio"
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
        for _, result := range types["&"].results {
            fmt.Println("Строка " + fmt.Sprintf("%v", result.line) + ":" + result.word)
        }

        os.Exit(1)
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

            typeResult.results = append(typeResult.results, Result{line: line, word: text[1:]})
        }
    }

    return types
}