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


def run(state):
    # nums, inputs, i=0, input_num=0
    halted = False
    should_break = False
    state['stdout'] = None

    i = state['ip']
    while True:
        opcode, get_param, put_param = read_val(state['data'], i)
        if opcode == 99:
            halted = True
            # print("halting")
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
            # print("Input num is", state['stdin_index'])
            inputs = state['stdin']
            if state['stdin_index'] >= len(inputs):
                should_break = True
                fields = 0
                # print("Waiting for input", i)
            else:
                if state['stdin_index'] > 0:
                    assert state['stdin_index'] == len(inputs)-1
                result = int(inputs[state['stdin_index']])
                put_param(result, 0)
                fields += 1
                state['stdin_index'] += 1
        elif opcode == 4:
            v = get_param(0)
            # print("printing:", v)
            state['stdout'] = v
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
        if should_break:
            break

    state['ip'] = i

    return halted

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


def try_sequence(numbers, seq):
    states = []
    for i in range(5):
        states.append({
            'ip': 0,
            'stdout': 0,
            'data': numbers.copy(),
            'stdin': [seq[i]],
            'stdin_index': 0,
        })

    i = 0
    prev_state = states[len(states) - 1]
    curr_state = states[i]
    while True:
        prev_state = curr_state
        curr_state = states[i]

        curr_state['stdin'].append(prev_state['stdout'])
        # print(i, "->", repr(curr_state))
        halted = run(curr_state)
        # print(i, "<-", repr(curr_state))
        # print()

        if halted and i == 4:
            # print(i, "halted")
            break

        i += 1
        if i >= len(seq):
            i = 0

    return states[4]['stdout']

def part2(numbers):
    highest = 0
    for sequence in permutations([5, 6, 7, 8, 9]):
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
            r = part2(numbers)
            print("\nReturned: ", r)
