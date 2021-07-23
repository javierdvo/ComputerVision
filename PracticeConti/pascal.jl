function binom(a,b)
    Int(factorial(a)/(factorial(b)*factorial(a-b)))
end

n=5
for i in 0:1:n
    for j in 0:1:i
        print(binom(i,j))
    end
    println()
end # for
