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

    def put_param(fval, off, debugval=None):
        # fval = get_param(f)
        mode = get_digit(n, off + 2)
        addr_or_val = g(i + 1 + off)

        if mode == 2:
            # relative mode
            addr_or_val = state['rel_base'] + addr_or_val
            mode = 0

        if mode == 0:
            if debugval:
                print('['+debugval+']', 'addr', addr_or_val, "(fval is", fval,")")

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
            # print('putting', a, '+', b, 'at ', end="")
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

def grid_set(grid, x, y, c):
    prev = grid[y][x]
    if prev != '?':
        if prev != c:
            print("grid[{}][{}] should be {}, found {}".format(y, x, c, prev))
            assert prev == c
    grid[y][x] = c

def print_grid(grid, d_x, d_y):
    lines = [
        '  |' + "".join([ str(get_digit(n, 1)) for n in range(41) ]),
        '  |' + "".join([ str(get_digit(n, 0)) for n in range(41) ]),
        '  ' + '-' * 42
    ]
    for y in range(0, 40 + 1):
        l = ['{:02d}|'.format(y)]
        for x in range(0, 40+1):
            if d_x == x and d_y == y:
                l.append("D")
            else:
                l.append(grid[y][x])
        lines.append("".join(l))
    print("\n".join(lines))

def direction_coord(x, y, direction):
    assert direction in [1, 2, 3, 4]
    if direction == 1:
        return x, y - 1
    elif direction == 2:
        return x, y + 1
    elif direction == 3:
        return x - 1, y
    else:
        return x + 1, y

dir_to_card = {
    1: 'north',
    2: 'south',
    3: 'west',
    4: 'east'
}

def opposite(n):
    return {1:2, 2:1, 3:4, 4:3}[n]

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
    grid = defaultdict(lambda: defaultdict(lambda: '?'))

    x = 0
    y = 0
    next_pos = (0, 0)

    halted = False
    current_direction = 1
    last_successful_inverted = None
    while not halted:
        print('(pre) m[1039], m[1040] == ', (state['data'][1039], state['data'][1040]))
        x, y = (state['data'][1039], state['data'][1040])
        halted = run(state)

        # Apply pending stdout
        print('len(stdout)', len(state['stdout']))
        while curr_stdout < len(state['stdout']):
            status_code = state['stdout'][curr_stdout]
            curr_stdout += 1
            print("status_code was", status_code)
            # print('(post) m[1039], m[1040] == ', (state['data'][1039], state['data'][1040]))

            if status_code == 0:
                grid_set(grid, *next_pos, '#')
                current_direction += 1
                if current_direction > 4:
                    current_direction = 1
                while current_direction == last_successful_inverted:
                    current_direction += 1
                    if current_direction > 4:
                        current_direction = 1
            else:
                if status_code == 1:
                    grid_set(grid, *next_pos, '.')
                else:
                    assert status_code == 2
                    grid_set(grid, *next_pos, 'o')
                    return

                last_successful_inverted = opposite(current_direction)
                # x, y = (state['data'][1039], state['data'][1040])
                x, y = next_pos
                print_grid(grid, x, y)



        if halted:
            print('halted!')
            break

        print('\nmove', dir_to_card[current_direction], current_direction)
        state['stdin'].append(current_direction)
        next_pos = direction_coord(x, y, current_direction)


        print('ignoring request for stdin')

    return state['stdout']

with open('input.txt', 'r') as f:
    for line in f:
        line=line.strip()
        numbers = list(map(int,line.split(",")))
        if len(numbers) > 0:
            # print("len", len(numbers))
            r = part1(numbers)
            print("\nReturned: ", r)


"""
Reverse engineering notes.

- address 1033 seems to be where the directino goes
- north: 1, south: 2, west: 3, east: 4
- 1: north, 2: south, 3: west, 4: east

[1039] is for x value
[1040] is for y value

[1044] is where the wall output is
"""