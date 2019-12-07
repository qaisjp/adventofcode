#!/usr/bin/env python3

import sys
from collections import defaultdict
from itertools import permutations

def get_digit(number, n):
    return number // 10**n % 10

def read_val(nums, i):
    n = nums[i]
    # print("Full opcode is", n)

    opcode = get_digit(n, 0) + get_digit(n, 1)*10
    # print("Real opcode is", opcode)

    def get_param(off):
        mode = get_digit(n, off + 2)
        # print("nums[]", i+1+off)
        addr_or_val = nums[i + 1 + off]
        if mode == 0:
            # print("Reading param number", off, 'as address (@{}). '.format(addr_or_val), end='')
            # print("value", nums[addr_or_val])
            return nums[addr_or_val]
        elif mode == 1:
            # print("Reading param number", off, 'as immediate. value: {}'.format(addr_or_val))
            return addr_or_val

    def put_param(fval, off):
        # fval = get_param(f)
        mode = get_digit(n, off + 2)
        addr_or_val = nums[i + 1 + off]
        if mode == 0:
            nums[addr_or_val] = fval
        elif mode == 1:
            print("NEVER IMMEDIATE MDOE, THEY SAY")
            sys.exit(1)

    return opcode, get_param, put_param


def run(nums, inputs):
    input_num = 0
    stdout = []
    halted = False

    i = 0
    while True:
        opcode, get_param, put_param = read_val(nums, i)
        if opcode == 99:
            halt = True
            break

        fields = 1

        if opcode == 1:
            a = get_param(0)
            b = get_param(1)
            put_param(a + b, 2)
            fields += 3
            # print("a({}) + b({}) = {}".format(a, b, a + b))
        elif opcode == 2:
            a = get_param(0)
            b = get_param(1)
            put_param(a * b, 2)
            # print("a({}) * b({}) = {}".format(a, b, a * b))
            fields += 3
        elif opcode == 3:
            result = int(inputs[input_num])
            put_param(result, 0)
            fields += 1
            input_num += 1
        elif opcode == 4:
            v = get_param(0)
            # print("printing:", v)
            stdout.append(v)
            fields += 1
        elif opcode == 5 or opcode == 6:
            should_jump = get_param(0)
            new_ip = get_param(1)
            if opcode == 5:
                should_jump = should_jump != 0 # jump if true
            else:
                should_jump = should_jump == 0 # jump if false

            if should_jump:
                i = new_ip
                continue
            fields += 2
        elif opcode == 7:
            a = get_param(0)
            b = get_param(1)
            val = 0
            if a < b:
                val = 1
            put_param(val, 2)
            fields += 3
        elif opcode == 8:
            a = get_param(0)
            b = get_param(1)
            val = 0
            if a == b:
                val = 1
            put_param(val, 2)
            fields += 3
        else:
            print("Unknown opcode", opcode)
            sys.exit(1)

        # print(i, "nums is now", nums)
        i += fields

    # print("halt?", halted)
    return nums[0], stdout

def try_sequence(numbers, seq):
    inputs = [0, 0]
    for i, s in enumerate(seq):
        # print()
        inputs[0] = s
        # print(i, "-> inputs", repr(inputs))
        returned, stdout = run(numbers, inputs)
        inputs[1] = stdout[0]
        # print(i, "-> result", inputs[0])

    return inputs[1]

def part1(numbers):
    highest = 0
    for sequence in permutations([0, 1, 2, 3, 4]):
        old_highest = highest
        highest = max(highest, try_sequence(numbers.copy(), sequence))
        if highest != old_highest:
            print("new sequence is", sequence)
    return highest


with open('input.txt', 'r') as f:
    for line in f:
        line=line.strip()
        numbers = list(map(int,line.split(",")))
        if len(numbers) > 0:
            # print("len", len(numbers))
            r = part1(numbers)
            print("\nReturned: ", r)
