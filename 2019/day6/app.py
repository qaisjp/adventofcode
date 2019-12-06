#!/usr/bin/env python3
from collections import defaultdict

children = defaultdict(list)
parents = {}

def count(cs):
    direct = len(cs)
    indirect = 0

    for child in cs:
        child_cs = children[child]
        d, i = count(child_cs)
        indirect += d + i
        direct += d

    return direct, indirect

def day1(pairs):
    for left, right in pairs:
        children[left].append(right)

    direct, indirect = count(children['COM'])

    print(direct, '+', indirect, '=', direct+indirect)


def partree(name):
    if name == "COM":
        return []

    par = parents[name]
    return [par] + partree(par)

def day2(pairs):
    for left, right in pairs:
        parents[right] = left

    yours = partree('YOU')
    sans = partree('SAN')
    # print('YOU', yours)
    # print('SAN', sans)

    for yi, yv in enumerate(yours):
        for si, sv in enumerate(sans):
            if yv == sv:
                print(yi + si)
                return



if __name__ == "__main__":
    with open('input.txt', 'r') as f:
        pairs = []
        for line in f:
            a, b = line.strip().split(')')
            pairs.append((a,b))

        day2(pairs)
