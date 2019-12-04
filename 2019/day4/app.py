from collections import defaultdict
minval = 240298
maxval = 784956

day = 2

def are_two_same(n):
    s = str(n)
    m = defaultdict(int)
    for c in s:
        m[c] += 1

    for char, count in m.items():
        if (day == 1) and count > 1:
            return True
        elif (day == 2) and count == 2:
            return True
    return False

def are_incremental(n):
    s = str(n)
    last_c = 0
    for c in s:
        c = int(c)
        if c < last_c:
            return False
        last_c = c
    return True

def main():
    n = 0
    for i in range(minval, maxval+1):
        if are_two_same(i) and are_incremental(i):
            n += 1
    print(n)

if __name__ == "__main__":
    main()