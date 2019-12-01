package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func contains(slice []int, val int) int {
	for i, v := range slice {
		if v == val {
			return i
		}
	}
	return -1
}

func main() {
	out, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(out), "\n")

	freq := 0

	visited := []int{0}
	foundFirst := -1

	for _, line := range lines {
		if line == "" {
			continue
		}
		f, err := strconv.ParseInt(line, 10, 64)
		if err != nil {
			panic(err)
		}
		freq += int(f)

		if i := contains(visited, freq); foundFirst == -1 && i != -1 {
			foundFirst = i
		}

		visited = append(visited, freq)
	}

	// Part 1
	fmt.Println(freq)

	for foundFirst == -1 {
		for _, line := range lines {
			if line == "" {
				continue
			}
			f, err := strconv.ParseInt(line, 10, 64)
			if err != nil {
				panic(err)
			}
			freq += int(f)

			if i := contains(visited, freq); foundFirst == -1 && i != -1 {
				foundFirst = i
				break
			}

			visited = append(visited, freq)
		}
	}

	// Part 2
	if foundFirst == -1 {
		fmt.Println("No duplicate found")
	} else {
		fmt.Println(visited[foundFirst])
	}
}
