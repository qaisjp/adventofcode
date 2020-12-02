package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/qaisjp/adventofcode/2020/internal/aoc"
)

func fail(err error) {
	if err != nil {
		panic(err.Error())
	}
}

func main() {
	puzzleOne := aoc.CheckArgs()

	valid := 0

	aoc.ForFilenameLines(os.Args[2], func(line string) {
		var lo, hi int
		var c rune
		var pw string
		fmt.Sscanf(line, "%d-%d %c: %s", &lo, &hi, &c, &pw)

		if puzzleOne {
			count := strings.Count(pw, string(c))
			if count >= lo && count <= hi {
				valid++
			}
		} else {
			if (pw[lo-1] == byte(c)) != (pw[hi-1] == byte(c)) {
				valid++
			}
		}
	})

	fmt.Println(valid)
}
