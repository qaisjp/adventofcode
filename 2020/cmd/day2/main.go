package main

import (
	"fmt"

	parse "github.com/qaisjp/adventofcode/2020/internal/aoc"
)

func main() {
	puzzleOne := parse.CheckArgs()

	if puzzleOne {
		firstPuzzle()
	} else {
		secondPuzzle()
	}
}

func firstPuzzle() {
	fmt.Println("first")
}

func secondPuzzle() {
	fmt.Println("second")
}
