package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	out, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	twice := 0
	thrice := 0
	boxes := strings.Split(string(out), "\n")
	for _, box := range boxes {
		hasTwice := false
		hasThrice := false

		counts := make(map[rune]int)

		for _, b := range box {
			counts[b]++
		}

		for _, count := range counts {
			if count == 2 && !hasTwice {
				hasTwice = true
				twice++
				// fmt.Printf("twice++ (twice: %d, thrice: %d)\n", twice, thrice)
			} else if count == 3 && !hasThrice {
				hasThrice = true
				thrice++
				// fmt.Printf("thrice++ (twice: %d, thrice: %d)\n", twice, thrice)
			}
		}
	}

	checksum := twice * thrice
	fmt.Println(checksum)

	part2 := ""
outer:
	for _, boxA := range boxes {
		if len(boxA) == 0 {
			continue
		}
		for _, boxB := range boxes {
			if len(boxB) == 0 {
				continue
			}
			if boxA == boxB {
				continue
			}

			differences := 0
			diffIndex := 0
			for i, a := range []byte(boxA) {
				b := boxB[i]
				if a != b {
					differences++
					diffIndex = i
				}
			}

			if differences == 1 {

				s := []byte(boxB)
				part2 = string(append(s[:diffIndex], s[diffIndex+1:]...))

				break outer
			}
		}
	}

	fmt.Println(part2)
}
