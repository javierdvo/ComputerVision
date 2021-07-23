using LinearAlgebra

A = [1. 0. 0. 0. 2.; 0. 0. 3. 0. 0.; 0. 0. 0. 0. 0.; 0. 2. 0. 0. 0.]
meanA=mean!(ones(size(A)[1]),A)
A.-meanA
U,S,Vt =svd(A.-meanA) #Thin Decomp -> economy. Can improve by reducing the # of num,
U* Diagonal(S)*Vt' #Recompose original matrix
U*U' #Left-Singular vectors->cols
Vt'*Vt #Right-Singular vectors->cols
eigenVectors=U # Nth U vectors are our eigenvectors of the Covariance Matrix
eigenValues=Diagonal(S)*Diagonal(S)/size(A)[1] #eigenvalues of the Covariance Matrix

covar=u*Diagonal(S)*Diagonal(S)/size(A)[1]*U'  #Can obtain covariance matrix from SVD

pcaA=Transpose(Transpose(A.-meanA)*eigenVectors) #Obtain the PCA representation of our observation matrix
invPCA=eigenVectors*pcaA.+meanA #reconstruct observations from PCA vectors
