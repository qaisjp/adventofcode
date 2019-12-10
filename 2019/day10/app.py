#!/usr/bin/env python3

from collections import namedtuple, defaultdict
from typing import Iterable
import math
import sys

Point = namedtuple('Point', ('x', 'y'))
Obj = namedtuple('Obj', ('kind', 'pos'))

def read_file(f=sys.argv[1]):
    y = 0
    objs = []
    with open(f, 'r') as f:
        for line in f:
            x = 0
            for c in line.strip():
                pos = Point(x,y)
                objs.append(Obj(c, pos))
                x += 1
            y += 1

    return objs

def day1():
    objs = read_file()

    asteroids = list(filter(lambda o: o.kind == '#', objs))

    max_angles = 0
    pos = None
    for a in asteroids:
        angles = set()
        for b in asteroids:
            if a != b:
                angles.add(math.atan2(b.pos.y-a.pos.y, b.pos.x-a.pos.x))

        if len(angles) > max_angles:
            max_angles = len(angles)
            pos = a.pos
    print("Max asteroids at a single position:", max_angles)
    print("That position is", pos)
    return objs, pos

def day2():
    objs, pos = day1()

    asteroids = list(filter(lambda o: o.kind == '#', objs))
    # angles = []
    angle_distances = defaultdict(list)
    for b in asteroids:
        if b.pos == pos:
            continue
        y_diff = b.pos.y - pos.y
        x_diff = b.pos.x - pos.x
        angle = 90 + math.degrees(math.atan2(y_diff, x_diff))
        if angle < 0:
            angle = 360 + angle
        # angles.append(angle)
        angle_distances[angle].append((b.pos, math.sqrt(x_diff*x_diff + y_diff*y_diff)))

    angle_distances = dict(angle_distances)
    for key in sorted(angle_distances.keys()):
        print(key)
        angle_distances[key].sort(key=lambda t: t[1])

    i = 0
    i_find = int(sys.argv[2])
    no_find = False
    while not no_find:
        no_find = True
        for angle in sorted(angle_distances.keys()):
            l = angle_distances[angle]
            if len(l) > 0:
                no_find = False
                i += 1
                recent = angle_distances[angle].pop(0)
                if i == i_find:
                    print(recent[0])
                    return


if __name__ == "__main__":
    day2()