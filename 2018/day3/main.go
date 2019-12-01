package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type claim struct {
	id   int
	x, y int
	w, h int

	overlaps bool
}

func main() {
	out, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	claimStrs := strings.Split(string(out), "\n")

	claims := make([]*claim, len(claimStrs)-1)
	for i, line := range claimStrs {
		if line == "" {
			continue
		}

		var err error
		id, x, y, w, h := 0, 0, 0, 0, 0

		sep := strings.Split(line, "@")
		idStr := strings.TrimSpace(sep[0][1:])
		geom := strings.Split(sep[1], ":")
		coords := strings.Split(strings.TrimSpace(geom[0]), ",")
		size := strings.Split(strings.TrimSpace(geom[1]), "x")

		id, err = strconv.Atoi(idStr)
		if err != nil {
			panic(err)
		}
		x, err = strconv.Atoi(coords[0])
		if err != nil {
			panic(err)
		}
		y, err = strconv.Atoi(coords[1])
		if err != nil {
			panic(err)
		}
		w, err = strconv.Atoi(size[0])
		if err != nil {
			panic(err)
		}
		h, err = strconv.Atoi(size[1])
		if err != nil {
			panic(err)
		}

		claims[i] = &claim{id, x, y, w, h, false}
	}

	size := 1000
	grid := make([][][]*claim, size)
	for y := range grid {
		grid[y] = make([][]*claim, size)
		for x := range grid[y] {
			grid[y][x] = make([]*claim, 0)
		}
	}

	for _, claim := range claims {
		maxX := claim.x + claim.w
		maxY := claim.y + claim.h
		for y := claim.y; y < maxY; y++ {
			for x := claim.x; x < maxX; x++ {
				grid[y][x] = append(grid[y][x], claim)

				if len(grid[y][x]) > 1 {
					for _, c := range grid[y][x] {
						c.overlaps = true
					}
				}
				// visualise(grid)
				// fmt.Println()
			}
		}
	}

	// visualise(grid)

	total := 0
	for _, col := range grid {
		for _, claims := range col {
			claimCount := len(claims)
			if claimCount >= 2 {
				total++
			}
		}
	}

	// Part 1
	fmt.Println(total)

	// Part 2

	for _, c := range claims {
		if !c.overlaps {
			fmt.Println(c.id)
		}
	}
}

func visualise(grid [][][]claim) {
	for _, col := range grid {
		for _, claims := range col {
			count := len(claims)
			if count == 0 {
				fmt.Print(".")
			} else {
				fmt.Print(count)
			}
		}
		fmt.Println()
	}
}
