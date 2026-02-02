F = GF(101)
R.<x1, x2> = PolynomialRing(F, 2)

f = x1*x2 + x1 + 1
from itertools import product

def partial_sum(f, sum_var, fixed):
    total = F(0)
    for b in [0,1]:
        subs = fixed | {sum_var: b}
        total += f.subs(subs)
    return total

print(partial_sum(f, x1, {x2: 1}))
print(partial_sum(f, x2, {x1: 1}))
