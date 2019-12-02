#!/usr/bin/env python3

import sys
def part1(nums, a=12, b=2):
    nums[1] = a
    nums[2] = b

    i = 0
    while True:
        opcode = nums[i]
        if opcode == 99:
            return nums[0]

        a = nums[nums[i+1]]
        b = nums[nums[i+2]]
        target = nums[i+3]

        result = nums[target]
        if opcode == 1:
            # print("add", a, b, "to", target)
            result = a + b
        elif opcode == 2:
            # print("mul", a, b, "to", target)
            result = a * b
        else:
            print("Unknown opcode", opcode)
            sys.exit(1)

        nums[target] = result
        # print(i, "nums is now", nums)
        i += 4

    print("did not halt")
    return nums[0]

with open('input.txt', 'r') as f:
    for line in f:
        line=line.strip()
        numbers = list(map(int,line.split(",")))
        if len(numbers) > 0:
            print("len", len(numbers))
            for a in range(100):
                for b in range(100):
                    n = part1(numbers.copy(), a, b)
                    if n == 19690720:
                        print(a, "* 100 +", b, '==', a*100+b)
