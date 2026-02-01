import random
from itertools import product

F = GF(101)
R.<x1, x2> = PolynomialRing(F, 2)

# multilinear polynomial
f = x1*x2 + x1 + 1

def prover_round(f, variables, fixed):
    """
    f         : polynomial
    variables : remaining variables
    fixed     : dict of fixed variables {x1: r1, ...}
    """
    F = f.base_ring()
    Xi = variables[0]

    g0 = F(0)
    g1 = F(0)

    rest = variables[1:]

    for b in product([0,1], repeat=len(rest)):
        subs0 = fixed | {Xi: 0} | dict(zip(rest, b))
        subs1 = fixed | {Xi: 1} | dict(zip(rest, b))
        g0 += f.subs(subs0)
        g1 += f.subs(subs1)

    # since multilinear, g(X) = g0*(1-X) + g1*X
    return g0, g1

def eval_on_boolean_hypercube(f, variables=None):
    F = f.base_ring()
    total = F(0)

    if variables is None:
        variables = f.variables()

    for b in product([0,1], repeat=len(variables)):
        subs = dict(zip(variables, b))
        total += f.subs(subs)

    return total


def verifier(f, variables):
    F = f.base_ring()
    claim = eval_on_boolean_hypercube(f)   # initial sum
    fixed = {}

    for Xi in variables:
        g0, g1 = prover_round(f, variables[variables.index(Xi):], fixed)

        # check
        if g0 + g1 != claim:
            return False

        # verifier challenge
        r = F.random_element()
        fixed[Xi] = r

        # update claim
        claim = g0 * (1 - r) + g1 * r

    # final check
    return claim == f.subs(fixed)

verifier(f, [x1, x2])