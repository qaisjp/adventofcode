from collections import defaultdict

grid1 = defaultdict(lambda: defaultdict(int))
grid2 = defaultdict(lambda: defaultdict(int))

def main():
    max_x = 0
    max_y = 0
    with open('input.txt', 'r') as f:
        wire_id = 0
        for wire in f:
            wire = wire.split(',')
            if wire_id == 0:
                grid = grid1
            elif wire_id == 1:
                grid = grid2
            wire_id += 1
            pos_x = 0
            pos_y = 0
            steps = 0
            for op in wire:
                n = int(op[1:])
                direction = op[0]
                for each in range(n):
                    steps += 1
                    if direction == "R":
                        pos_x += 1
                    elif direction == "L":
                        pos_x -= 1
                    elif direction == "U":
                        pos_y += 1
                    elif direction == "D":
                        pos_y -= 1

                    grid[pos_x][pos_y] = steps
                    max_x = max(max_x, pos_x)
                    max_y = max(max_y, pos_y)

    for x in range(0, max_x+1):
        for y in range(0, max_y+1):
            g1 = grid1[x][y]
            g2 = grid2[x][y]
            if g1 > 0 and g2 > 0:
                print("hit pos: ({}, {}), (g1:{}, g2:{}), g1+g2: {}".format(x, y, g1, g2, g1+g2))


if __name__ == "__main__":
    main()