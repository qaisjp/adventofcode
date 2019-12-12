#!/usr/bin/env python3

import sys
from collections import defaultdict, namedtuple
from functools import reduce

Pos = namedtuple('Pos', ('x','y','z'))
Vel = namedtuple('Vel', ('x','y','z'))
Moon = namedtuple('Moon', ('pos','vel'))


def read_file(f=sys.argv[1]):
    moons = []
    with open(f, 'r') as f:
        for line in f:
            parts = line.strip().split(' ')
            assert parts[0][0] == '<'
            parts[0] = parts[0][1:]

            x = 0
            y = 0
            z = 0
            for c in parts:
                cparts = c.split('=')
                assert len(cparts) == 2
                if cparts[0] == 'x':
                    x = int(cparts[1][:-1])
                elif cparts[0] == 'y':
                    y = int(cparts[1][:-1])
                elif cparts[0] == 'z':
                    z = int(cparts[1][:-1])
            moons.append(Moon(Pos(x,y,z), Vel(0,0,0)))
    return moons

def sign_or_zero(n):
    if n == 0:
        return 0
    if n > 0:
        return 1
    else:
        return -1

def get_moon_energy(m):
    return sum(map(abs, m.pos)) * sum(map(abs, m.vel))

def part1():
    moons = read_file()

    for step_num in range(int(sys.argv[2])):
        print('after', step_num+1, 'steps')

        new_moons = moons.copy()

        # apply gravity and velocity
        for i, imoon in enumerate(moons):
            vel = list(imoon.vel)
            for j, jmoon in enumerate(moons):
                if i == j:
                    continue

                vel[0] += sign_or_zero(jmoon.pos.x - imoon.pos.x)
                vel[1] += sign_or_zero(jmoon.pos.y - imoon.pos.y)
                vel[2] += sign_or_zero(jmoon.pos.z - imoon.pos.z)

            new_moons[i] = Moon(
                Pos(imoon.pos.x + vel[0],
                    imoon.pos.y + vel[1],
                    imoon.pos.z + vel[2], ),
                Vel(*vel))

            print(new_moons[i])

        moons = new_moons
        print()

    total_energy = sum(map(get_moon_energy, moons))
    print('total_energy', total_energy)

def find_lcm(moons):
    steps = set()
    steps.add(tuple(moons))
    step_num = 0
    while True:
        step_num += 1
        # print('after', step_num, 'steps')

        new_moons = []

        # apply gravity and velocity
        for i, imoon in enumerate(moons):
            vel = imoon[1]
            for j, jmoon in enumerate(moons):
                if i == j:
                    continue

                vel += sign_or_zero(jmoon[0] - imoon[0])
                # vel[1] += sign_or_zero(jmoon.pos.y - imoon.pos.y)
                # vel[2] += sign_or_zero(jmoon.pos.z - imoon.pos.z)

            new_moons.append((imoon[0] + vel, vel))

            # print(new_moons[i])
        moons = new_moons
        if tuple(new_moons) in steps:
            # print('x', step_num)
            return step_num
        steps.add(tuple(moons))
        # print()

def part2():
    moons = read_file()

    x_moons = list(map(lambda m: (m.pos.x, m.vel.x), moons))
    y_moons = list(map(lambda m: (m.pos.y, m.vel.y), moons))
    z_moons = list(map(lambda m: (m.pos.z, m.vel.z), moons))
    lcms = [find_lcm(x_moons),find_lcm(y_moons),find_lcm(z_moons)]
    print(reduce(lcm, lcms))

# from https://gist.github.com/endolith/114336/eff2dc13535f139d0d6a2db68597fad2826b53c3
def gcd(a,b):
    """Compute the greatest common divisor of a and b"""
    while b > 0:
        a, b = b, a % b
    return a
# from https://gist.github.com/endolith/114336/eff2dc13535f139d0d6a2db68597fad2826b53c3
def lcm(a, b):
    """Compute the lowest common multiple of a and b"""
    return a * b / gcd(a, b)

if __name__ == "__main__":
    part2()
