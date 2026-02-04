from itertools import product
import hashlib

F = GF(101)
R.<x1, x2> = PolynomialRing(F, 2)
g = x1*x2 + x1 + x2

def hypercube_sum(f, variables):
    return sum(f.subs(dict(zip(variables,b)))
               for b in product([0,1], repeat=len(variables)))
    
def hash_to_field(*objs):
    h = hashlib.sha256()
    for o in objs:
        h.update(str(o).encode())
    return F(int(h.hexdigest(), 16))

def sumcheck_prover(f, variables):
    proof = []
    claim = hypercube_sum(f, variables)
    fixed = {}

    for i in range(len(variables)):
        Xi = variables[i]
        rest = variables[i+1:]

        g0 = F(0)
        g1 = F(0)

        for b in product([0,1], repeat=len(rest)):
            g0 += f.subs(fixed | {Xi:0} | dict(zip(rest,b)))
            g1 += f.subs(fixed | {Xi:1} | dict(zip(rest,b)))

        # univariate ring
        Ux.<X> = PolynomialRing(F)
        poly = Ux(g0)*(1 - X) + Ux(g1)*X

        proof.append(poly)

        # Fiat–Shamir challenge
        r = hash_to_field(poly, claim, i)
        fixed[Xi] = r
        claim = poly(r)

    return {
        "claimed_sum": hypercube_sum(f, variables),
        "polys": proof
    }

    
def sumcheck_verifier(f, variables, proof):
    claim = proof["claimed_sum"]
    polys = proof["polys"]
    fixed = {}

    for i, poly in enumerate(polys):
        # sumcheck condition
        if poly(0) + poly(1) != claim:
            return False

        # Fiat–Shamir challenge
        r = hash_to_field(poly, claim, i)
        fixed[variables[i]] = r
        claim = poly(r)

    return claim == f.subs(fixed)

proof = sumcheck_prover(g, [x1, x2])
print(sumcheck_verifier(g, [x1, x2], proof))
print("correct proof is: ", proof)

proof["claimed_sum"] += 1
print(sumcheck_verifier(g, [x1, x2], proof))
