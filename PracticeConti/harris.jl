using LinearAlgebra
I=[ 0 0 0; 0 1 0; 0 0 0]
alpha=0.1
gradX= []
gradY=[]
grad=
H=grad*grad'
f=det(H)+alpha*trace(H)
