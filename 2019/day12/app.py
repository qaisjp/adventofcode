#!/usr/bin/env python3

import sys
from collections import defaultdict, namedtuple

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
                    x = float(cparts[1][:-1])
                elif cparts[0] == 'y':
                    y = float(cparts[1][:-1])
                elif cparts[0] == 'z':
                    z = float(cparts[1][:-1])
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

def main():
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

if __name__ == "__main__":
    main()