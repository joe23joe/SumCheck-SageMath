import itertools

# Field and polynomial
F = GF(101)
R.<x1, x2> = PolynomialRing(F, 2)

f = x1*x2 + x1 + 1

# Sum / product over the Boolean hypercube {0,1}^n
def boolean_cube_sum(f, vars):
    total = f.base_ring()(0)
    for point in itertools.product([0, 1], repeat=len(vars)):
        subs = {vars[i]: point[i] for i in range(len(vars))}
        total += f.subs(subs)
    return total

def boolean_cube_prod(f, vars):
    total = f.base_ring()(1)
    for point in itertools.product([0, 1], repeat=len(vars)):
        subs = {vars[i]: point[i] for i in range(len(vars))}
        total *= f.subs(subs)
    return total

print("sum is: ",boolean_cube_sum(f, [x1, x2]))
print("prod is: ",boolean_cube_prod(f, [x1, x2]))