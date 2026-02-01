# Define the finite field GF(101)
F = GF(101)

# Define a polynomial ring in two variables over GF(101)
R.<x1, x2> = PolynomialRing(F, 2)

# Define the polynomial
f = x1*x2 + x1 + 1

print("f is: ", f)