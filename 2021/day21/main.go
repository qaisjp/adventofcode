package main

import (
	"fmt"
	"time"
)

var lastPrint = time.Now()
var startTime = time.Now()

// Generated by Ruby code: [1,2,3].repeated_permutation(3).map(&:sum).to_a
// Every time a player "plays", generate these many universes.
var dieRolls = [27]uint8{3, 4, 5, 4, 5, 6, 5, 6, 7, 4, 5, 6, 5, 6, 7, 6, 7, 8, 5, 6, 7, 6, 7, 8, 7, 8, 9}

type Player struct {
	Position uint8
	Score    uint8
}

type Universe struct {
	Players    [2]Player
	NextPlayer bool // 0 or 1
}

var cacheUniverses = map[Universe][2]uint64{}
var cacheUses = 0

func printUniverses(force bool) {
	timeSince := time.Since(lastPrint)
	if (timeSince > (time.Second * 2)) || force {
		ms_elapsed := time.Since(startTime).Milliseconds()
		fmt.Printf("Universes won: elapsed: %d ms - cache size is %d, used %d times\n", ms_elapsed, len(cacheUniverses), cacheUses)
		lastPrint = time.Now()
	}
}

var maxDepth = 0

func playUniverse(universe Universe, depth int) [2]uint64 {
	if depth > maxDepth {
		maxDepth = depth
	}

	// printUniverses(false)
	cache, ok := cacheUniverses[universe]
	if ok {
		cacheUses++
		return cache
	}

	playerIndex := 0
	if universe.NextPlayer {
		playerIndex = 1
	}

	player := universe.Players[playerIndex]

	var winPair [2]uint64
	for _, moves := range dieRolls {
		newPos := (player.Position + moves) % 10
		newScore := player.Score + newPos + 1

		if newScore >= 21 {
			winPair[playerIndex]++
			continue
		}

		newUniverse := universe
		newUniverse.NextPlayer = !newUniverse.NextPlayer
		newUniverse.Players[playerIndex] = Player{newPos, newScore}

		play := playUniverse(newUniverse, depth+1)
		winPair[0] += play[0]
		winPair[1] += play[1]
	}

	cacheUniverses[universe] = winPair

	return winPair
}

func main() {
	var playerOnePos uint8 = 7
	var playerTwoPos uint8 = 2
	universesWon := playUniverse(Universe{
		Players: [2]Player{
			{playerOnePos - 1, 0},
			{playerTwoPos - 1, 0},
		},
		NextPlayer: false,
	}, 0)

	printUniverses(true)
	fmt.Println("maxDepth", maxDepth)
	fmt.Printf("Universes won: [%d, %d]\n", universesWon[0], universesWon[1])
}
