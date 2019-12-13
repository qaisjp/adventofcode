#!/usr/bin/env python3

import sys
from collections import defaultdict
from itertools import permutations

def get_digit(number, n):
    return number // 10**n % 10

def read_val(state, i):
    nums = state['data']
    n = nums[i]
    # print("Full opcode is", n)

    opcode = get_digit(n, 0) + get_digit(n, 1)*10
    # print("Real opcode is", opcode)

    def g(idx):
        while idx >= len(nums):
            nums.append(0)
        return nums[idx]

    def s(idx, val):
        while idx >= len(nums):
            nums.append(0)
        nums[idx] = val

    def get_param(off):
        mode = get_digit(n, off + 2)
        # print("nums[]", i+1+off)

        addr_or_val = nums[i + 1 + off]
        if mode == 2:
            # relative mode
            addr_or_val = state['rel_base'] + addr_or_val
            mode = 0

        if mode == 0:
            # position mode
            # print("Reading param number", off, 'as address (@{}). '.format(addr_or_val), end='')
            # print("value", nums[addr_or_val])
            return g(addr_or_val)
        elif mode == 1:
            # immediate mode
            # print("Reading param number", off, 'as immediate. value: {}'.format(addr_or_val))
            return addr_or_val

    def put_param(fval, off):
        # fval = get_param(f)
        mode = get_digit(n, off + 2)
        addr_or_val = g(i + 1 + off)

        if mode == 2:
            # relative mode
            addr_or_val = state['rel_base'] + addr_or_val
            mode = 0

        if mode == 0:
            # position mode
            s(addr_or_val, fval)
        elif mode == 1:
            # immediate mode
            print("NEVER IMMEDIATE MDOE, THEY SAY")
            sys.exit(1)

    return opcode, get_param, put_param


def run(state):
    # nums, inputs, i=0, input_num=0
    halted = False
    should_break = False

    i = state['ip']
    while True:
        opcode, get_param, put_param = read_val(state, i)
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
            # if True:
            if state['stdin_index'] >= len(inputs):
                should_break = True
                fields = 0
                print("Waiting for input", i)
            else:
                if state['stdin_index'] > 0:
                    assert state['stdin_index'] == len(inputs)-1
                result = int(inputs[state['stdin_index']])
                # result = int(input("input: "))
                put_param(result, 0)
                fields += 1
                state['stdin_index'] += 1
        elif opcode == 4:
            v = get_param(0)
            # print("printing:", v)
            # print("stdout", v)
            state['stdout'].append(v)
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
        elif opcode == 9:
            a = get_param(0)
            state['rel_base'] += a
            fields += 1
        else:
            print("Unknown opcode", opcode)
            sys.exit(1)

        # print(i, "nums is now", nums)
        i += fields
        if should_break:
            break

    state['ip'] = i

    return halted

def part1(numbers):
    state = {
        'ip': 0,
        'stdout': [],
        'data': numbers.copy(),
        'stdin': [],
        'stdin_index': 0,
        'rel_base': 0,
    }

    curr_stdout = 0
    grid = defaultdict(lambda: defaultdict(int))

    block_tiles = 0

    halted = False
    while not halted:
        halted = run(state)

        # Apply pending stdout
        print('len(stdout)', len(state['stdout']))
        while curr_stdout < len(state['stdout']):
            x = state['stdout'][curr_stdout]
            curr_stdout += 1

            y = state['stdout'][curr_stdout]
            curr_stdout += 1

            tile_id = state['stdout'][curr_stdout]
            curr_stdout += 1

            grid[y][x] = tile_id

            if tile_id == 2:
                block_tiles += 1

        if halted:
            print('halted!')
            break

        print('ignoring request for stdin')

    return block_tiles #state['stdout']


def part2(numbers):
    state = {
        'ip': 0,
        'stdout': [],
        'data': numbers.copy(),
        'stdin': [],
        'stdin_index': 0,
        'rel_base': 0,
    }

    curr_stdout = 0
    grid = defaultdict(lambda: defaultdict(int))

    # put in quarters
    state['data'][0] = 2

    ball_x = 0
    score = 0

    halted = False
    paddle = []
    while not halted:
        halted = run(state)

        # Apply pending stdout
        # print('len(stdout)', len(state['stdout']))

        new_paddle = []

        while curr_stdout < len(state['stdout']):
            x = state['stdout'][curr_stdout]
            curr_stdout += 1

            y = state['stdout'][curr_stdout]
            curr_stdout += 1

            tile_id = state['stdout'][curr_stdout]
            curr_stdout += 1

            if x == -1 and y == 0:
                score = tile_id
                print("setting score to", score)
                continue

            grid[y][x] = tile_id

            if tile_id == 4:
                ball_x = x
                print('ball at', x, y)
            elif tile_id == 3:
                new_paddle.append(x)

        if halted:
            print('halted!')
            break

        if len(new_paddle) != 0:
            paddle = new_paddle

        print('paddle at', paddle, len(paddle))

        if len(paddle) > 0:
            paddle_min_x = min(paddle)
            paddle_max_x = max(paddle)

        joystick_pos = 0
        if len(paddle) > 0:
            if ball_x < paddle_min_x:
                joystick_pos = -1
            elif ball_x > paddle_max_x:
                joystick_pos = 1

        state['stdin'].append(joystick_pos)

    return score #state['stdout']


with open('input.txt', 'r') as f:
    for line in f:
        line=line.strip()
        numbers = list(map(int,line.split(",")))
        if len(numbers) > 0:
            # print("len", len(numbers))
            r = part2(numbers)
            print("\nReturned: ", r)
