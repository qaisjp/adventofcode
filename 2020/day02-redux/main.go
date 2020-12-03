package main

import (
	"fmt"
	"os"
	"strings"
)

type Data struct {
	lo, hi int
	c      rune
	pw     string
}

func main() {
	puzzleOne := aoc.CheckArgs()

	valid := 0

	data := Data{}
	ScanLines(os.Args[2], "%d-%d %c: %s", func(line string) {
		if puzzleOne {
			count := strings.Count(data.pw, string(data.c))
			if count >= data.lo && count <= data.hi {
				valid++
			}
		} else {
			if (data.pw[data.lo-1] == byte(data.c)) != (data.pw[data.hi-1] == byte(data.c)) {
				valid++
			}
		}

	}, &data.lo, &data.hi, &data.c, &data.pw)

	fmt.Println(valid)
}
