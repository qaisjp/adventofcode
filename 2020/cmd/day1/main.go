package main

import (
	"fmt"
	"os"

	"github.com/qaisjp/adventofcode/2020/internal/aoc"
)

var input1 = []int{
	1721,
	979,
	366,
	299,
	675,
	1456,
}

func main() {
	puzzleOne := os.Args[1] == "1"
	if !puzzleOne && os.Args[1] != "2" {
		panic("Expected first arg to be '1' or '2'")
	}

	if puzzleOne {
		firstPuzzle()
	} else {
		secondPuzzle()
	}
}

func firstPuzzle() {
	filename := os.Args[2]
	input := aoc.FilenameToInts(filename)
	for _, a := range input {
		for _, b := range input {
			if a+b == 2020 {
				fmt.Printf("a: %d, b: %d, a + b: %d, a * b: %d\n", a, b, a+b, a*b)
			}
		}
	}
}

func secondPuzzle() {
	filename := os.Args[2]
	input := aoc.FilenameToInts(filename)
	for _, a := range input {
		for _, b := range input {
			for _, c := range input {
				if a+b+c == 2020 {
					fmt.Printf("a: %d, b: %d, c: %d, a + b + c: %d, a * b * c: %d\n", a, b, c, a+b+c, a*b*c)
				}
			}
		}
	}
}
