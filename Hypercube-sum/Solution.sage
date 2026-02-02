from itertools import product

F = GF(101)
R.<x1, x2> = PolynomialRing(F, 2)

f = x1*x2 + x1 + 1

def eval_on_boolean_hypercube(f, variables=None):
    F = f.base_ring()
    total = F(0)

    if variables is None:
        variables = f.variables()

    for b in product([0,1], repeat=len(variables)):
        total += f.subs(dict(zip(variables, b)))

    return total

eval_on_boolean_hypercube(f)