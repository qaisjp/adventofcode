#!/usr/bin/env python3

import sys
from collections import defaultdict

def get_digit(number, n):
    return number // 10**n % 10

def read_val(nums, i):
    n = nums[i]
    print("Full opcode is", n)

    opcode = get_digit(n, 0) + get_digit(n, 1)*10
    print("Real opcode is", opcode)

    def get_param(off):
        mode = get_digit(n, off + 2)
        # print("nums[]", i+1+off)
        addr_or_val = nums[i + 1 + off]
        if mode == 0:
            print("Reading param number", off, 'as address (@{}). '.format(addr_or_val), end='')
            print("value", nums[addr_or_val])
            return nums[addr_or_val]
        elif mode == 1:
            print("Reading param number", off, 'as immediate. value: {}'.format(addr_or_val))
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


finalvals = []
def part1(nums, a=12, b=2):
    # nums[1] = a
    # nums[2] = b

    i = 0
    while True:
        opcode, get_param, put_param = read_val(nums, i)
        if opcode == 99:
            return nums[0]

        fields = 1

        if opcode == 1:
            a = get_param(0)
            b = get_param(1)
            put_param(a + b, 2)
            fields += 3
            print("a({}) + b({}) = {}".format(a, b, a + b))
        elif opcode == 2:
            a = get_param(0)
            b = get_param(1)
            put_param(a * b, 2)
            print("a({}) * b({}) = {}".format(a, b, a * b))
            fields += 3
        elif opcode == 3:
            result = int(input('input: '))
            put_param(result, 0)
            fields += 1
        elif opcode == 4:
            v = get_param(0)
            print("printing:", v)
            finalvals.append(v)
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

    print("did not halt")
    return nums[0]

with open('input.txt', 'r') as f:
    for line in f:
        line=line.strip()
        numbers = list(map(int,line.split(",")))
        if len(numbers) > 0:
            print("len", len(numbers))
            r = part1(numbers.copy())
            print("\nReturned: ", r)
            print("Final vals", repr(finalvals))
            # for a in range(100):
            #     for b in range(100):
            #         n = part1(numbers.copy(), a, b)
            #         if n == 19690720:
            #             print(a, "* 100 +", b, '==', a*100+b)
