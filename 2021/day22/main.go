package main

import (
	"fmt"
	"os"
	"strings"
	"time"
)

type Coord struct {
	x int
	y int
	z int
}

type Cuboid struct {
	a  Coord
	b  Coord
	on bool
}

var xa, xb, ya, yb, za, zb int
var x, y, z int

func progress() {
	for {
		time.Sleep(time.Second * 1)
		fmt.Printf("x progress: %d/%d (%d%%)\n", x-xa, xb-xa, (x-xa)*100/(xb-xa))
		fmt.Printf("y progress: %d/%d (%d%%)\n", y-ya, yb-ya, (y-ya)*100/(yb-ya))
		fmt.Printf("z progress: %d/%d (%d%%)\n", z-za, zb-za, (z-za)*100/(zb-za))
		fmt.Printf("total progress: %d%%\n", (x-xa)*100/(xb-xa)*100/(yb-ya)*100/(zb-za))
		fmt.Println()
	}
}

func main() {
	fmt.Println("allocating...")
	start := time.Now()
	var bigmap = make(map[Coord]struct{}, 1000000000)
	fmt.Println("allocated in", time.Since(start))
	bigmap[Coord{0, 0, 0}] = struct{}{}

	go progress()

	bytes, _ := os.ReadFile("input.txt")
	for _, line := range strings.Split(string(bytes), "\n") {
		if line == "" {
			continue
		}

		var state string

		fmt.Println(line)
		if _, err := fmt.Sscanf(line, "%s x=%d..%d,y=%d..%d,z=%d..%d", &state, &xa, &ya, &xb, &yb, &za, &zb); err != nil {
			panic(err.Error())
		}

		if state != "on" && state != "off" {
			panic("?! " + state)
		}
		on := state == "on"

		for x = xa; x <= xb; x++ {
			for y = ya; y <= yb; y++ {
				for z = za; z <= zb; z++ {
					if on {
						bigmap[Coord{x, y, z}] = struct{}{}
					} else {
						delete(bigmap, Coord{x, y, z})
					}
				}
			}
		}
	}

	fmt.Println(len(bigmap))
}
