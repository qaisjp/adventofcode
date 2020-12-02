package aoc

import (
	"log"
	"os"
)

func CheckArgs() bool {
	msg := "Expected first arg to be '1' or '2'"
	if len(os.Args) == 1 {
		log.Fatalln(msg)
	}
	puzzleOne := os.Args[1] == "1"
	if !puzzleOne && os.Args[1] != "2" {
		log.Fatalln(msg)
	}
	return puzzleOne
}
