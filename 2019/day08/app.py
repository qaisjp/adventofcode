#!/usr/bin/env python3

from functools import reduce

def day1(nums, width, height):
    size = width * height
    s = ""
    for i in range(0, len(nums), size):
        this = nums[i:i+size]
        if s == "":
            s = this
        elif this.count("0") < s.count("0"):
            s = this
        print(this, len(this))
    print("answer:", s, s.count("1") * s.count("2"))

def reducer(left, right):
    right = list(right)
    for i, r in enumerate(right):
        l = left[i]
        if l != "2":
            right[i] = l
    return "".join(right)

def day2(nums, width, height):
    size = width * height
    layers = []
    for i in range(0, len(nums), size):
        this = nums[i:i+size]
        layers.append(this)
        # print(this, len(this))

    msg = reduce(reducer, layers)
    for i in range(0, len(msg), width):
        print(msg[i:i+width].replace("1", "█").replace("0", u" "))
    # print("answer:", s, s.count("1") * s.count("2"))


def main(nums, width, height):
    day2(nums, width, height)

if __name__ == "__main__":
    with open('input.txt') as f:
        # main("123456789012", 3, 2)
        # main("0222112222120000", 2, 2)
        main(f.readline(), 25, 6)