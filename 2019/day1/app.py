#!/usr/bin/env python3
import math

def fuel_once(n):
    return max(0, math.floor(n  / 3.0) - 2)


def part1():
    with open('input.txt', 'r') as f:
        fuel = 0
        for line in f:
            line = line.strip()
            n = int(line)
            fuel += fuel_once(n)
        print(fuel)

def part2():
    with open('input.txt', 'r') as f:
        fuel = 0
        for line in f:
            line = line.strip()
            n = int(line)
            while n > 0:
                n = fuel_once(n)
                fuel += n

        print(fuel)

part2()