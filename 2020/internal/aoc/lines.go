package aoc

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

func ForFilenameLines(path string, mapper func(string)) {
	file, err := os.Open(path)
	if err != nil {
		panic(err.Error())
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		mapper(scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		panic(err.Error())
	}
}

func ScanLines(path string, format string, f func(string), a ...interface{}) {
	ForFilenameLines(path, func(line string) {
		_, err := fmt.Sscanf(line, format, a...)
		Must(err)
		f(line)
	})
}
func FilenameToInts(path string) (results []int) {
	ForFilenameLines(path, func(line string) {
		i, err := strconv.Atoi(line)
		if err != nil {
			panic(err.Error())
		}
		results = append(results, i)
	})
	return
}

func Must(err error) {
	if err != nil {
		panic(err.Error())
	}
}
