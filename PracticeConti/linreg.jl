 #Minimize  Least-Squares Error
A = [1 0; 1 1; 1 2;] #add extra column for intercept vector
B = [6 0 0]
coeffs=inv(A'*A)*(A'*B') #Simplify by multiplying by transpose on both sides

X = [1 0; 1 1; 1 2;] #add extra column for intercept vector

#Ax=b
#A*err=0
#err= b-p
#p= A*X^

#X hat vector coefficients minimize distance between linear model and observations

#Projection= A times Least squares solution
