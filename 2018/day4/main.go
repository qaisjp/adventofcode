package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"sort"
	"strings"
	"time"
)

// Entry is essentially a line (but can also be reused for groups)
type Entry struct {
	time    time.Time
	guardID int
	status  guardStatus

	duration time.Duration
}

func (e *Entry) String() string {
	msg := "unknown message"
	if e.status == statusShiftBegun {
		msg = "begins shift"
	} else if e.status == statusAsleep {
		msg = "falls asleep"
	} else if e.status == statusAwake {
		msg = "wakes up"
	}
	return fmt.Sprintf("[%d-%02d-%02d %02d:%02d] Guard #%d %s (for %s)", e.time.Year(), e.time.Month(), e.time.Day(), e.time.Hour(), e.time.Minute(), e.guardID, msg, e.duration.String())
}

type guardStatus int

const (
	statusNull guardStatus = iota
	statusShiftBegun
	statusAsleep
	statusAwake
)

// An EntryHeap is a min-heap of ints.
type EntryHeap []*Entry

func (h EntryHeap) Len() int { return len(h) }
func (h EntryHeap) Less(i, j int) bool {
	// fmt.Println("Called")
	return h[i].time.Before(h[j].time)
}
func (h EntryHeap) Swap(i, j int) { h[i], h[j] = h[j], h[i] }

func (h *EntryHeap) Push(x interface{}) {
	// Push and Pop use pointer receivers because they modify the slice's length,
	// not just its contents.
	*h = append(*h, x.(*Entry))
}

func (h *EntryHeap) Pop() interface{} {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[0 : n-1]
	return x
}

func main() {
	out, err := ioutil.ReadFile("test.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(out), "\n")

	entries := EntryHeap(make([]*Entry, 0, len(lines)-1))

	for _, line := range lines {
		if line == "" {
			continue
		}

		var y, month, d, h, min int
		var guard int
		msg := line[19:]

		_, err := fmt.Sscanf(line, "[%d-%d-%d %d:%d]", &y, &month, &d, &h, &min)
		if err != nil {
			panic(err)
		}

		if strings.HasPrefix(msg, "Guard #") {
			_, err := fmt.Sscanf(msg, "Guard #%d", &guard)
			if err != nil {
				panic(err)
			}
		}

		var status guardStatus
		if msg == "falls asleep" {
			status = statusAsleep
		} else if msg == "wakes up" {
			status = statusAwake
		} else if strings.Contains(msg, " begins shift") {
			status = statusShiftBegun
		}

		date := time.Date(y, time.Month(month), d, h, min, 0, 0, time.UTC)
		entry := &Entry{
			time:    date,
			guardID: guard,
			status:  status,
		}

		entries = append(entries, entry)
	}

	sort.Sort(&entries)

	var prevEntry *Entry
	for i := range entries {
		entry := entries[i]
		if prevEntry == nil {
			prevEntry = entry
			continue
		}
		if entry.guardID == 0 {
			entry.guardID = prevEntry.guardID
		}

		// y, m, d := entry.time.Date()
		// pY, pM, pD := prevEntry.time.Date()
		if entry.guardID != prevEntry.guardID {

			// 	entryDay := time.Date(y, m, d, 0, 0, 0, 0, time.UTC)
			// 	mleft := entryDay.Sub(prevEntry.time)
			// 	fmt.Printf("entry: %s; prevEntry: %s, leaving next day to be: %+v, so minutes left is: %f\n", entry.String(), prevEntry.String(), entryDay, mleft.Minutes())
			// 	prevEntry.duration = mleft

			prevEntry.duration = time.Minute * time.Duration(60-prevEntry.time.Minute())
		} else {
			prevEntry.duration = entry.time.Sub(prevEntry.time)
		}

		prevEntry = entry
	}

	sleepyDurations := make(map[int]time.Duration)
	for _, entry := range entries {
		fmt.Println(entry.String())
		if entry.status != statusAsleep {
			continue
		}
		sleepyDurations[entry.guardID] = sleepyDurations[entry.guardID] + entry.duration
	}

	visualise(entries)

	// Wish there was a nicer and more efficient way than performing sort.Sort and getting the last item...

	maxGuard := -1
	maxSleep := time.Duration(-1)
	for guard, duration := range sleepyDurations {
		if duration > maxSleep {
			maxSleep = duration
			maxGuard = guard
		}
	}

	// fmt.Println(maxGuard, maxSleep)

	minutes := make([]int, 60)
	for _, entry := range entries {
		if entry.guardID != maxGuard {
			continue
		}

		m := entry.time.Minute()
		for i := m; i < m+int(math.Floor(entry.duration.Minutes())); i++ {
			minutes[i%60]++
		}
	}

	maxMinute := -1
	maxMinuteCount := -1
	for minute, count := range minutes {
		if count > maxMinuteCount {
			maxMinute = minute
			maxMinuteCount = count
		}
	}

	fmt.Println(maxGuard, maxMinute, maxGuard*maxMinute)
}

func visualise(entries []*Entry) {
	fmt.Println("Date\tID\tMinute")

	fmt.Printf("\t\t")
	for t := 0; t < 6; t++ {
		for o := 0; o < 10; o++ {
			fmt.Print(t)
		}
	}

	fmt.Println()

	fmt.Printf("\t\t")
	for t := 0; t < 6; t++ {
		for o := 0; o < 10; o++ {
			fmt.Print(o)
		}
	}

	var prev *Entry
	printed := 0
	for _, entry := range entries {
		mins := entry.duration.Minutes()

		if prev == nil || dayDifferent(prev, entry) || prev.guardID != entry.guardID {
			printed = 0

			fmt.Println()
			fmt.Printf("%02d-%02d\t#%d\t", entry.time.Month(), entry.time.Day(), entry.guardID)

			// If guard starts shift at 00:20, time we need 20 pre-start dots
			// But not if they start before the hour
			if entry.time.Hour() == 0 {
				for i := 0; i < entry.time.Minute(); i++ {
					fmt.Printf("p")
					printed += 1
				}
			} else {
				// If they start before the hour. We do something illegal. We
				mins -= float64(60 - entry.time.Minute())
			}
		}

		for i := 0; i < int(mins); i++ {
			if printed == 60 {
				break
			}
			c := "."
			if entry.status == statusAsleep {
				c = "#"
			}
			fmt.Print(c)
			printed++
		}
		prev = entry
	}

	fmt.Println()
}

func dayDifferent(a, b *Entry) bool {
	aY, aM, aD := a.time.Date()
	bY, bM, bD := b.time.Date()
	return aY != bY || aM != bM || aD != bD
}
