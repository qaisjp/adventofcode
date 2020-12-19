package main

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

var spaceRegex = regexp.MustCompile(`\s+`)
var parenRegex = regexp.MustCompile(`(\(|\))`)

func tokenise(line string) []string {
	line = parenRegex.ReplaceAllString(line, " $1 ")
	line = spaceRegex.ReplaceAllString(line, " ")
	// fmt.Printf("pre-spilt: %#v\n", line)
	ts := strings.Split(strings.TrimSpace(line), " ")
	// fmt.Printf("tokenised %s to %#v\n", line, ts)
	return ts
}

type Expr struct {
	Left  interface{}
	Op    string
	Right interface{}
}

func (e Expr) String() string {
	return fmt.Sprintf("(%v %s %v)", e.Left, e.Op, e.Right)
}

func (e Expr) Eval() int {
	l, r := 0, 0

	switch v := e.Left.(type) {
	case int:
		l = v
	case Expr:
		l = v.Eval()
	default:
		panic(fmt.Sprintf("I don't know about ltype %T!\n", v))
	}

	switch v := e.Right.(type) {
	case int:
		r = v
	case Expr:
		r = v.Eval()
	default:
		panic(fmt.Sprintf("I don't know about rtype %T!\n", v))
	}

	switch e.Op {
	case "*":
		return l * r
	case "+":
		return l + r
	default:
		panic("I don't know what to do with op " + e.Op)
	}
}

func node(tokens []string) interface{} {
	if len(tokens) == 1 {
		n, err := strconv.Atoi(tokens[0])
		if err != nil {
			panic(err.Error())
		}
		return n
	}

	return parse(tokens)
}

func isOp(s string) bool {
	return s == "*" || s == "+"
}

func maybeInt(t string) (int, bool) {
	i, err := strconv.Atoi(t)
	return i, err == nil
}

func parse(tokens []string) Expr {
	size := len(tokens)
	last := tokens[size-1]
	secondLast := tokens[size-2]

	lastNum, numErr := strconv.Atoi(last)
	if numErr == nil && isOp(secondLast) {
		e := Expr{
			node(tokens[:size-2]),
			secondLast,
			lastNum,
		}
		return e
	} else if last == ")" {
		left := size - 1
		found := 1
		for found > 0 {
			left--
			if tokens[left] == ")" {
				found++
			} else if tokens[left] == "(" {
				found--
			}
		}

		if left == 0 {
			l, lOk := maybeInt(tokens[1])
			r, rOk := maybeInt(secondLast)
			if !(lOk && rOk) {
				panic("que")
			}
			return Expr{l, tokens[2], r}
		}

		fmt.Printf("\n%#v (left: %d) became:\n", tokens, left)
		ltokens := tokens[:left-1]
		op := tokens[left-1]
		rtokens := tokens[left+1 : size-1]
		fmt.Printf("- (%v) %s (%v)\n", ltokens, op, rtokens)
		return Expr{
			node(ltokens),
			op,
			node(rtokens),
		}
	} else {
		panic(fmt.Sprintf("Not sure what to do with %#v", tokens))
	}
}

func parseLine(line string) Expr {
	return parse(tokenise(line))
}

func TestParser() {
	try := func(line string, expected string) {
		// fmt.Println("Testing", line)
		actual := parse(tokenise(line)).String()
		if actual != expected {
			fmt.Printf("[TEST} Expected %s, got %s\n", expected, actual)
			panic("parse test failed")
		}
	}
	try("2 + 3", "(2 + 3)")
	try("1 + 2 * 3 + 4 * 5 + 6", "(((((1 + 2) * 3) + 4) * 5) + 6)")
	try("2 * 3 + (4 * 5)", "((2 * 3) + (4 * 5))")

	try2 := func(line string, expected int) {
		fmt.Println("Testing", line)
		expr := parse(tokenise(line))
		fmt.Printf("[TEST] Evaluating %v\n", expr)
		actual := expr.Eval()
		if actual != expected {
			fmt.Printf("[TEST} Expected %d, got %d, for %s\n", expected, actual, line)
			panic("eval test failed")
		} else {
			// fmt.Println("try2 passed")
		}
	}
	try2("1 + 2 * 3 + 4 * 5 + 6", 71)
	try2("1 + (2 * 3) + (4 * (5 + 6))", 51)
	try2("2 * 3 + (4 * 5)", 26)
	try2("5 + (8 * 3 + 9 + 3 * 4 * 3)", 437)
	try2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240)
	try2("(1 + 2)", 3)
	try2("(1 + 2) + 3", 6)
	try2("(2 + 4 * 9)", 54) // wrong value

	try2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632) // panics que
}

func main() {
	TestParser()
	// fmt.Printf("%#v", tokenise("1 + (2 * 3) + (4 * (5 + 6))"))
}
