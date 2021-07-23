
#####################################################
#                                                   #
# Generalities and problem analyis                  #
#                                                   #
#####################################################

#Solution asks for n-1 tourists to be saved, thus atleast one cannot be saved? What informationcan we obtain from that one which cant be saved?

#Information each person has: the hats that are in front of each, the hats that have been said from the ones behind them. And the strategy (no sharing of info allowed)

#Desired solution constrains us: if we want n-1 to be saved, then the information we send forward needs to be the same as the right answer for each individual.
#corollary 1 of our constraint: At any given point in the task, each person knows the color of every other hat except his own and the first hat.
#This is true because each person can see the ones in front in the line, and has heard all the right results until now (As the strategy works).
#corollary 2 of our constraint: For the sake of the problem, the first hat can be completely ignored as he will very probably die, and there is no way we can know for sure which colour it is.
#Rephrase it from the first view of the first person as a fully observable scenario with 29 hats, with resulting 28-partially observable scenarios

#What can the first person who does know all other hats tell us about the entire view that will help
#And, what kind of info can the current person possibly obtain from the right answer of the previous person + the first person that will give them enough information to know their hat color.

#What statistical value can give us insight into 3 different classes?

#Idea: Using the colours as a way to send information from the first person to the rest of the persons.

#####################################################
#                                                   #
# Solution Explanation and Analysis                 #
#                                                   #
#####################################################

#Test having a linear combination of the brown yellow and cyan colour count to make a weighted average (WA)
#Using a simple scenario where WA= 1B+2Y+3C

#When the brown count was being reduced (the person had a brown hat), the observed (by them) WA was 1 less than the real WA
#When the yellow count was being reduced (the person had a yellow hat), the he observed (by them) WA was 2 less than the real WA
#When the cyan count was being reduced (the person had a cyan hat), the he observed (by them) WA was 3 less than the real WA.
#This WA real-observed difference is never less than 1 nor larger than 3 as we only lose 1 observation.

#These 3 states that apply for all case combinations can be represented by calculating the divisibility of the WA from the complete WA observation,
#and finding the divisibility of the WA from the secon person WA observation, we calculate the difference between each other to know which colour the observer needs to add so that we complete it

# This difference between the total WA divisibility (first answer) and the partial WA observation gives us the correct result in every single case!
# Every person hears the first answer and thus knows the total WA divisibility, and due to our corollary 1 and 2 (all the way up), they know the partial WA observation (that excludes them)
# With these two pieces of information, every single person can then correctly find which colour is the one that needs to be added to fulfull the equation

#Color=WA_total % 3 - WA_obs % 3  (With an additional padding so it cycles c-<b-<y-<c...)

# First person calculates WA_total and Encodes:
# BROWN= WA_total % 3 == 0
# YELLOW=2 WA_total % 3 == 1
# CYAN=3 WA_total % 3 == 2

#Next persons then decode, calculate their partial WA_obs, and from the difference (or lack thereof) knows what colour they are to compensate


#Enter Code
using StatsBase #For the countmap function to find frequencies of the colours
using InvertedIndices #Invert Indices so that we can use it to easily represent the partial observation
using LinearAlgebra #Dot product

EQ_MAT=[1 2 3] # Represent our WA equation in matrix form to perform the dot product
colours=["brown","yellow","cyan"]
colours_ext=["brown","yellow","cyan","brown","yellow"]
tourists=rand(colours,30) #Generate a random set of hat colours from the cannibals

#First Person total observation
count_dict_first=countmap(tourists[2:30]) #observe all in front and count frequencies
count_vec_first=[count_dict_first["brown"],count_dict_first["yellow"],count_dict_first["cyan"]] #convert to vector so we can do dot
wa_total=dot(count_vec_first,EQ_MAT) #perform WA calculation
wa_total_div=wa_total%3 #Find the divisibility of the total WA
first_p_answer=colours[wa_total_div+1] #Map divisibility to colour by adding 1 (Julia indices start at 1) to the answer the first one needs to give

solution=true #Quick check to see if they are all saved

#Iteration of the next persons onwards
for i in 2:1:30
    count_dict=countmap(tourists[Not(i,1)])     #Partial observation that removes that persons colour as well as the first one from the vector to count
    count_vec=[count_dict["brown"],count_dict["yellow"],count_dict["cyan"]]
    wa_partial=dot(count_vec,EQ_MAT)
    local wa_total_div=findfirst(isequal(first_p_answer),colours)-1 #Simulate the hearing the first one and decoding part
    wa_partial_div=wa_partial%3       #Find partial WA divisibility
    divs_diff= wa_total_div-wa_partial_div    #Find difference, and then compensate around if it is 0/negative so that we end within [1,3]
    if divs_diff<1
        divs_diff=3+divs_diff
    end
    next_p_answer=colours[divs_diff] #Give answer based on the colour it needs to provide to make the partial WA into the total WA
    if tourists[i]!=next_p_answer
        println("Strategy Failed")
        break
    end
end
println("All Except 1 saved!")
