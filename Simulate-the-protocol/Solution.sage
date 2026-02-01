from itertools import product
import random

F = GF(101)
R.<x1, x2, x3> = PolynomialRing(F, 3)

# 3-variable polynomial
f = x1*x2 + x2*x3 + 1

# Multilinear extension
def multilinear_extension(f, variables):
    """
    Compute the multilinear extension of f over all of F^n.
    """
    F = f.base_ring()
    Rx = PolynomialRing(F, [str(v) for v in variables])  # fix here
    g = Rx(0)
    
    for b in product([0,1], repeat=len(variables)):
        term = F(f.subs(dict(zip(variables,b))))
        for xi, bi in zip(variables, b):
            if bi == 0:
                term *= (1 - Rx.gen(variables.index(xi)))
            else:
                term *= Rx.gen(variables.index(xi))
        g += term
    return g


# Prover round using MLE
def prover_round_MLE(g, variables, fixed):
    F = g.base_ring()
    Xi = variables[0]
    rest = variables[1:]

    g0 = F(0)
    g1 = F(0)

    for b in product([0,1], repeat=len(rest)):
        subs0 = fixed | {Xi: 0} | dict(zip(rest, b))
        subs1 = fixed | {Xi: 1} | dict(zip(rest, b))
        g0 += F(g.subs(subs0))
        g1 += F(g.subs(subs1))

    # univariate polynomial: g(X) = g0*(1-X) + g1*X
    Rx.<x> = PolynomialRing(F)
    return g0*(1 - x) + g1*x, g0, g1
def run_sumcheck(f, variables, manual_claim=None):
    """
    f            : polynomial (can be non-multilinear)
    variables    : list of variables [x1,x2,...]
    manual_claim : optional manually overridden initial claimed sum
    """
    F = f.base_ring()
    
    # Build MLE
    g = multilinear_extension(f, variables)
    
    # Initial claim = sum over Boolean hypercube
    claim = F(0)
    for b in product([0,1], repeat=len(variables)):
        subs = dict(zip(variables,b))
        claim += F(g.subs(subs))
    
    if manual_claim is not None:
        print(f"Overriding claimed sum to {manual_claim}")
        claim = F(manual_claim)
    
    fixed = {}
    
    print("Initial claimed sum:", claim)
    
    # Sumcheck rounds
    for i, Xi in enumerate(variables):
        poly, g0, g1 = prover_round_MLE(g, [v for v in variables if v not in fixed], fixed)
        print(f"\nRound {i+1} for {Xi}:")
        print(f"  Polynomial: {poly}")
        print(f"  g0 = {g0}, g1 = {g1}")
        
        if g0 + g1 != claim:
            print("Verifier rejected! Sum mismatch.")
            return False
        
        # Verifier challenge
        r = F.random_element()
        fixed[Xi] = r
        print(f"  Verifier challenge r_{i+1} = {r}")
        
        # Update claim
        claim = g0*(1 - r) + g1*r
    
    final_eval = g.subs(fixed)
    if claim == final_eval:
        print("\nProtocol passed: claimed sum verified!")
        print("Final evaluation g(r1,...,rn) =", final_eval)
        return True
    else:
        print("\nProtocol failed: inconsistency detected!")
        print("Final evaluation g(r1,...,rn) =", final_eval)
        return False
    
run_sumcheck(f, [x1, x2, x3])
run_sumcheck(f, [x1, x2, x3], manual_claim=50)


"""
Output:

Share
Initial claimed sum: 12

Round 1 for x1:
  Polynomial: 2*x + 5
  g0 = 5, g1 = 7
  Verifier challenge r_1 = 45

Round 2 for x2:
  Polynomial: 91*x + 2
  g0 = 2, g1 = 93
  Verifier challenge r_2 = 8

Round 3 for x3:
  Polynomial: 8*x + 58
  g0 = 58, g1 = 66
  Verifier challenge r_3 = 83

Protocol passed: claimed sum verified!
Final evaluation g(r1,...,rn) = 15
Overriding claimed sum to 50
Initial claimed sum: 50

Round 1 for x1:
  Polynomial: 2*x + 5
  g0 = 5, g1 = 7
Verifier rejected! Sum mismatch.
False
"""