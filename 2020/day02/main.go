package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Policy struct {
	Lo     int
	Hi     int
	Letter string
}

type Line struct {
	Policy   Policy
	Password string
}

func (l Line) MeetsPolicy1() bool {
	p := l.Policy
	needle := p.Letter[0]
	found := 0
	for _, l := range []byte(l.Password) {
		if l == needle {
			found++
			if found > p.Hi {
				return false
			}
		}
	}
	return found >= p.Lo
}
func (l Line) MeetsPolicy2() bool {
	p := l.Policy
	needle := p.Letter[0]
	password := l.Password
	fmt.Println(l)
	a := needle == password[l.Policy.Lo-1]
	b := needle == password[l.Policy.Hi-1]

	return a != b
}

func (l Line) String() string {
	return fmt.Sprintf("%d-%d %s: %s", l.Policy.Lo, l.Policy.Hi, l.Policy.Letter, l.Password)
}

func fail(err error) {
	if err != nil {
		panic(err.Error())
	}
}

func LinesFromFilename(path string) []Line {
	var passwords []Line
	ForFilenameLines(path, func(line string) {
		items := strings.Split(line, " ")
		if len(items) != 3 {
			panic(fmt.Sprint("len of items", line, "is", len(items)))
		}

		nums := strings.Split(items[0], "-")
		if len(items[1]) != 2 {
			panic("unexpected items[1]: " + items[1])
		}

		letter := items[1][0]
		lo, err := strconv.Atoi(nums[0])
		fail(err)
		hi, err := strconv.Atoi(nums[1])
		fail(err)

		passwords = append(passwords, Line{
			Policy{
				Lo:     lo,
				Hi:     hi,
				Letter: string([]byte{letter}),
			},
			items[2],
		})
	})
	return passwords
}

func main() {
	puzzleOne := CheckArgs()

	lines := LinesFromFilename(os.Args[2])

	count := 0
	if puzzleOne {
		for _, line := range lines {
			if line.MeetsPolicy1() {
				count++
				fmt.Println("Meets policy: ", line)
			}
		}
	} else {
		for _, line := range lines {
			if line.MeetsPolicy2() {
				count++
				fmt.Println("Meets policy: ", line)
			}
		}
	}
	fmt.Println(count)
}
