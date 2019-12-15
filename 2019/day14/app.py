#!/usr/bin/env python3

import sys
from collections import defaultdict, namedtuple
import math
from typing import List, Dict, Tuple

class Formula:
    ingredients: Dict[str, int]
    prod: str
    volume: int
    string: str
    from_ore: bool = False

    def __init__(self, ingredients: Dict[str, int], production: Tuple[str, int]):
        super().__init__()

        self.ingredients = ingredients
        self.prod = production[0]
        self.volume = production[1]

        if "ORE" in ingredients:
            assert len(ingredients) == 1
            self.from_ore = True

    def __str__(self):
        if hasattr(self, 'string'):
            return self.string
        return super().__str__()


class Formulae:
    flist: List[Formula]
    fdict: Dict[str, Formula] = {}
    core: Dict[str, Formula] = {} # the formulae that produce these core ingredients

    def __init__(self, formulae: List[Formula]):
        super().__init__()

        self.flist = formulae

        for f in formulae:
            if f.prod in self.fdict:
                print("f.prod already in self.fdict", f.prod)
                sys.exit(1)

            if f.from_ore:
                self.core[f.prod] = f

            self.fdict[f.prod] = f

    # def calculate(self, goal: str, volume_wanted: int, inventory, depth=0):
    #     f = self.fdict[goal]
    #     prefix = depth*"  "
    #     print("\n{}{}> To produce".format((depth-1) * " ", depth * "="), goal, "@", volume_wanted, "we have to use formula `{}`".format(f))

    #     freq = 0
    #     volume_needed = max(0, volume_wanted-inventory[goal])
    #     if inventory[goal] > 0:
    #         print(prefix, "Want", volume_wanted, goal, "gonna try to use", volume_needed, "inventory: ", inventory)

    #     while volume_needed > (freq * f.volume):
    #         freq += 1
    #     left_over = -(volume_needed % -f.volume)

    #     inventory[goal] -= volume_wanted
    #     if inventory[goal] < 0:
    #         inventory[goal] = 0
    #     inventory[goal] += left_over

    #     print(prefix, "adding", left_over, "to inventory[{}]".format(goal), "it's now", inventory[goal], "we are now requesting", volume_needed)
    #     # print(prefix, "which is the formula times by {}".format(freq * f.volume, freq), "(this leaves over {})".format(left_over))

    #     if f.from_ore:
    #         cost = freq * f.volume
    #         print(prefix, "<=", "Returning {}".format(cost))
    #         return cost

    #     cost = sum([self.calculate(i, v * freq, depth=depth+1, inventory=inventory) for i, v in f.ingredients.items()])
    #     # if inventory
    #     return cost

    def find_required_inventory(self, goal: str, volume_wanted: int, inventory, wasted, depth=0):
        if goal == "ORE":
            inventory['ORE'] += volume_wanted
            return

        f = self.fdict[goal]

        # prefix = depth*"   "
        # print("\n{}{}> To produce {} of {} we have to use formula `{}`".format((depth-1) * " ", depth * "=", volume_wanted, goal, f))

        volume_needed = volume_wanted - wasted[goal]
        if volume_needed <= 0:
            # e.g. 5 (wanted) - 6 (wasted) = -1. so we add to wasted
            wasted[goal] += -volume_wanted
            return 0

        freq = math.ceil(volume_needed / f.volume)
        wasted[goal] = f.volume * freq - volume_needed
        return [self.find_required_inventory(ingredient, volume * freq, depth=depth+1, inventory=inventory, wasted=wasted) for ingredient, volume in f.ingredients.items()]



def read_line(line):
    l, r = line.split("=>")

    ingredients: Dict[str, int] = {}
    for item in l.split(","):
        n, c = item.strip().split(" ")
        if c in ingredients:
            print("DUPLICATES AAA")
            sys.exit(1)
        ingredients[c] = int(n)

    n, c = r.strip().split(" ")
    f = Formula(ingredients, (c, int(n)))
    f.string = line
    return f


def read_file(f=sys.argv[1]):
    formulae = []
    with open(f, 'r') as f:
        for line in f:
            formulae.append(read_line(line.strip()))
    return Formulae(formulae)


def main():
    formulae = read_file()

    inventory = defaultdict(int)
    wasted = defaultdict(int)
    formulae.find_required_inventory("FUEL", 1, inventory=inventory, wasted=wasted)

    print('step1', inventory['ORE'])

    trillion = 1000000000000
    i = 0
    step = trillion / 10
    while step >= 1:
        result = 0
        while result < trillion:
            i += step
            inventory = defaultdict(int)
            formulae.find_required_inventory("FUEL", i, inventory=inventory, wasted=defaultdict(int))
            result = inventory['ORE']

        i -= step
        step /= 10
    print('step2', i)


if __name__ == "__main__":
    main()