from math import floor, log


def to_ieee754(x: float) -> str:
    bits = []

    # sign
    bits.append('0' if x > 0 else '1')
    exp = 127 + floor(log(x, 2))

    # exponent
    exp_bin = bin(exp)[2:]
    exp_bin = '0' * (8 - len(exp_bin)) + exp_bin
    bits.extend(list(exp_bin))

    # fraction
    fraction = x * (2 ** (127 - exp)) - 1
    for _ in range(23):
        fraction *=  2
        if fraction >= 1:
            fraction -= 1
            bits.append('1')
        else:
            bits.append('0')

    return ''.join(bits)


def from_ieee754(x: str) -> float:
    if x.startswith('0x') or x.startswith('0b'):
        x = x[2:]
    try:
        int(x, 2)
    except ValueError:
        # trying converting hex to binary
        x = bin(int(x, 16))[2:]
    assert len(x) <= 32
    x = '0' * (32 - len(x)) + x

    sign = 1 if x[0] == '0' else -1
    power = -127 + int(x[1:9], 2)
    fraction = 0
    for i, b in enumerate(x[9:]):
        fraction += int(b) * (2 ** (-(i + 1)))

    return sign * (1 + fraction) * (2 ** power)
