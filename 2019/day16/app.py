#!/usr/bin/env python3

import sys
from collections import defaultdict
import numpy as np

def get_digit(number, n):
    return abs(number) // 10**n % 10

def flatten_n(n):
    return get_digit(n, 0)

def read_file(f=sys.argv[1]):
    with open(f, 'r') as f:
        return list(map(int, f.readline().strip()))

import math
def run_phase(nums, patterns):
    for i in range(len(nums)):
        # print('i =', i)
        pattern = patterns[i]
        value = np.sum(nums * pattern[1:len(nums)+1])
        nums[i] = flatten_n(value)
        # pattern_indices[i] += 1

day = int(sys.argv[2])
def main():
    nums = np.array(read_file())
    if day == 2:
        nums = np.tile(nums, 10000)
        offset = int(''.join(map(str,nums[:7])))
        nums = nums[offset::][::-1]
        for i in range(100):
            nums = np.cumsum(nums) % 10
        print(''.join(map(str, nums[::-1][:8])))
        return
    print('repeated. len(nums) is', len(nums))

    base_pattern = [0, 1, 0, -1]

    offset = int(''.join(map(str,nums[:7])))

    print('calc pat')
    patterns = {}
    for i in range(len(nums)):
        patterns[i] = np.tile(np.repeat(base_pattern, i+1), math.ceil(len(nums)/(i+1)))

    print('ready')

    # print(nums)
    for i in range(100):
        # print('done', i)
        run_phase(nums, patterns)

    print("".join(map(str,nums[:8])))


if __name__ == "__main__":
    main()