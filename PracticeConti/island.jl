
#####################################################
#                                                   #
# Generalities and problem analyis                  #
#                                                   #
#####################################################

#If there is a fixed set of hats for each colour,each person keeps track of the count forward as well as the hats that have been said, and everyone should be safe. Although this is not the case.

#Solution asks for n-1 tourists to be saved, thus atleast one cannot be saved? What informationcan we obtain from that one which cant be saved?

#Information each person has: the hats that are in front of each, the hats that have been said from the ones behind them. And the strategy (no sharing of info allowed)
#Two ways this is useful: one, to inform the others,but in an indirect way. Two, to inform their own decision, how no clue.

#Possibility one: all say the same colour= in average 33% of the people are saved

#Desired solution constrains us: if we want n-1 to be saved, then the information we send forward needs to be the same as the right answer for each individual.
#corollary 1 of our constraint: At any given point in the task, each person knows the color of every other hat except his own and the first hat.
#This is true because each person can see the ones in front in the line, and has heard all the right results until now (As the strategy works).
#corollary 2 of our constraint: For the sake of the problem, the first hat can be completely ignored as he will very probably die, and there is no way we can know for sure which colour it is.
#Rephrase it from the first view of the first person as a fully observable scenario with 29 hats, with resulting 28-partially observable scenarios

#What can the first person who does know all other hats tell us about the entire view that will help
#And, what kind of info can the current person possibly obtain from the right answer of the previous person + the first person that will give them enough information to know their hat color.

#What statistical value can give us insight into 3 different classes?

#If we take out the 30th hat, that means we have 29 hats, there is no way with 29 hats that all hat colours appear equally as 29 is not divisible by 3.
#At least one hat colour will have 10 or more hats
#corollary of this: Either all 3 colours have different frequencies, or two of them share frequency, either being the maximum or the minimum.
#Thus we identify each constraint with the colour the first person gives:
#Cyan:Constraint the set so that two colors have the same frequency and will be the minimum. They will both have <=9 and the third will be >=11

#Both will constraint that two colours will be >=10 while the third will be <=9.
#Brown:Constraint the set so that all colors have a different frequency
#Yellow:Constraint the set so that two colors have the same frequency and will be the maximum

#Tests for this solution did not work out, the constraint idea is not bad, and for the cyan case it did work, but the brown one it didnt.
#Retook the idea of using the colours as a way to send information from the first person to the rest of the users.

#Note, further idea that could be explored in the future: Game theory using Partially observable scenaries (POMDPs for example)??? Perhaps could work

#####################################################
#                                                   #
# SECONd ATTEMPT (UNSUCCESFULL)                     #
#                                                   #
#####################################################

#Idea: as the value is n=29, there has to be at least one colour which will be repeated odd times, and we can use this to our advantage.
#Actually: there are two possible cases, either there is one odd number with two even numbers that then make up our total of 29, or 3 odd numbers.

#Both of those situations behave differently and can give us a bit of insight.

#In the case of having 1 odd number and two even ones, we see the following behaviour:
#When the person has the same hat colour as the odd # colour, this makes it so that what he observes is the actual # of ocurrences of the other two colours, and his own colour minus 1
#Both of the other colours will be even, and as his own will be odd, when discounting his own he will be able to observe 3 sets of even occurences.
#This is important because the only moment when the person will see 3 even numbers is when they are in a 1 odd scenario with their own hat being the colour of the odd one,
#thus if that person knows which one is the odd, they can just say that one and be correct.

#Now, in that same state of 1 odd number and two even ones there is another scenario when the person DOES NOT have the same hat as the odd one.
# In this case, one of the two evens which is their own colour, will be reduced by one, and thus they will see two counts that are odd and 1 even.
#This gives them some inmediate insight we can later use, if they are in this scenario, they can directly know that their hat is NOT the odd one.
#Furthermore, they can also know that whichever count that came up even, is also even (As the one being reduced is their own which is the other even one.)
#The problem is that they still need to choose between the two odd ones to find the real one, so if they know which one is odd they can they just say the other one and be correct.

#Finally, in the case where there are 3 odd numbers we only see one situation
#The counts also come up as 2 odd ones with 1 even one, with the big difference that the one being reduced is odd, and as such the even one is the o.
#This helps us in the way that if we know that we are in the 3 odd numbers situation, the persons hat colour is the only one that is even.
#The problem is that from the persons point of view, they cannot know just from the odd/even ratio without extra information whether they are in the 3-set or the 1-set where they dont have the odd hat

#Knowing which type of scenario the people find themselves in, and knowing the odd case allows them to obtain their resulting hat colour for each of them!

#We can see that we have 2 different possible world states and that in one of those states we need to know the odd hat colour, so we need 4 pieces of information.
#Whether it is a 3-odd or 1-odd scenario, and if it is the second one, which hat colour out of the possible three is the odd one.
#ie states
# 1 x x x
# 0 1 0 0
# 0 0 1 0
# 0 0 0 1

#Now, how can we share this information forward just using the first pass of the first person? as we only have three possible messages , BROWN, YELLOW, CYAN.
# if we had 4, or by omitting information we could pass this 4th state, it would be trivial. But we are constrained to only 3/
# Furthermore, we are also constrained that every person after the first MUST ONLY give their solution, so we cannot use more information from a wrong or different answer for example

#Idea: We can use the interaction between the first and second persons to encode additional information into the system that all people can detect.
#The first knows what scenario the second will face (As for him it is a perfect information game), and he knows that the second person has information about his state,
#So he can send an instruction for the second one, while at the same time giving information to all the other persons in the line.
#Mostly i thought of using a rotating pattern which by itself gives information when comparing the instruction given by the First person vs the Action taken by the second

#I.e. all other people hear that the first said BROWN as he saw that the second was in a 1-odd, own hat with colour BROWN is the odd one scenario, resulting in a count of 3 evens he can directly see
#Beforehand they come up with the strategy that if the second then sees that he is in that 3-evens scenario, he will directly know that the colour the first says is the odd one out he should choose
# if this happens thus the second said also BROWN (No rotation), so we can then make it so that every person from now on, knows they are in a 1-odd scenario,and the odd one is brown,
# thus correctly answering their own future observations as they know the scenario they are in.
# If for example the hat colour was CYAN, then the first would say CYAN as would the second. YELLOW then YELLOW would work the same.

#Example 2: If now the first person sees they are in a 3-odd one scenario, he can then notify the second person of this as well as the rest.
#Because the people only listen to the first and second answers, we need to encode this in the interaction without using any of the previous three combinations
#We only have 9 possible state combinations for answer 1 and 2: B->B, Y->Y, C->C, B->Y, Y->C, C->B, B->C. Y->B, C->Y
#So we can then take backwards 1 rotation the instruction to be sent in the way C->B for example.

#The first person will send the colour of the second persons hat with a rotation of 1 i.e. Brown hat will be sent as CYAN. knowing they are in a 3 odd scenario

#The second person will receive this instruction, but they do not know that they are in a 3 odd scenario, only that they have 2 odds and 1 even.
# If they are in a 3 odd scenario, their hat colour count is in reality odd, and will appear as even to them.
# If they are in a 1 odd scenario, their hat colour count is in reality even, and will appear as odd to them

#They will try and then move the instruction 1 place forward (i.e. to BROWN), and then analyze if their brown count is even. if it is, that tells us they are in a 3 odd scenario.
#Then they now know their hat colour which is what they will say,
# and everyone else can then know they are in a 3 odd scenario as the by seeing that the instruction of the first one and the answer of the second one are rotated 1 places.
#Then everyone else can then answer correctly.

# if their 1 instrution forward count is not even, then that means that they are in a 1-odd scenario and thus the instruction should be actually 2 places forward.
#Then everyone can know that they are in a 1-odd scenario by seeing that the instruction of the first one and the answer of the second one are rotated 2 places.

#I implemented this with backwards inference, due to the constraint that the second MUST say his own correct answer, thus limiting it to changing how the first sends the instructions.

# The full strategy would go as follows:
#2 odds case from the pov of the second case -> 2 odds 1 even
# first attempt to move forward 1 which will be the odd one
#   CYAN convert to BROWN
#   check if brown count is even
#        check if that colour value ends up being even, if so, then it is in the 3 odds case, and will then send the correct hat
#        CYAN=BROWN -> 3 odds case confirms for all#
#        BROWN=YELLOW -> 3 odds case confirms for all#
#        YELLOW=CYAN -> 3 odds case confirms for all

    #if it ends up being even, then the actual colour they have is two rotations forward
#        CYAN=YELLOW -> only 1 odd confirms for all, calculates odd one based on discarding the own one and the other even one
#        BROWN=CYAN -> only 1 odd confirms for all, calculates odd one based on discarding the own one and the other even one
#        YELLOW=BROWN -> only 1 odd confirms for all, calculates odd one based on discarding the own one and the other even one

#1 odd case with the own hat colour being the odd one: directly see #3 evens case from the pov of the second person
#    BROWN=BROWN -> brown is odd, only 1 odd confirms for all
#    YELLOW=YELLOW -> yellow is odd, only 1 odd confirms for all
#    CYAN=CYAN -> cyan is odd, only 1 odd confirms for all

#    CYAN= 3-odd case

#This solution did not work, as there was a subset of cases where a 1 odds case would be incorrectly flagged as a 3 odds case and would thus break the cycle
#If the second case was not one of this cases, everyone was saved, but if the case was incorrectly flagged, only 33% in average would be saved

#Expanding this solution I started to test having a linear combination of the brown yellow and cyan colour count to make a weighted average
#Using a simple scenario where WA= 1B+2Y+3C
#I registered the weighted average for the sets below.
# Weighted average followed an interesting pattern due to this equation:
# 1B+2Y+3C
# O O O
# O+E+O-> even

# O E E
# O E E-> odd

# E O E
# E E E-> even

# E E O
# E E O-> odd

#If weighted value is even, either odd one is yellow, or it is 3-odd case.
#If weighted value is odd, either odd one is cyan or brown.
#I continued this by trying to use this weighted average to obtain the information.
#testing the WA for the state filtering turned out to solve some of the cases where the states were being mixed, but ended up creating its own set of mixed-state scenarios.
#one useful bit of information was that by using the weighted average in the test scenarios the WA was being changed in a pattern (Expected from the equation)
#When the brown count was being reduced (the person had a brown hat), the WA was 1 less than the real WA
#When the yellow count was being reduced (the person had a yellow hat), the WA was 2 less than the real WA
#When the cyan count was being reduced (the person had a cyan hat), the WA was 3 less than the real WA.
#This WA real-observed difference is never less than 1 nor larger than 3 as we only lose 1 observation.
#We can then send to the second person the difference from the WA the first person knows is the actual one, vs the one they will know the person 2 will observe.

#Encode:
# BROWN=1 -
# YELLOW=2
# CYAN=3
# These also nicely correspond to the hat that solves that scenario.

#Problem is, how do we obtain the previous odd-one selection as well as 1 or 3 odd case from this interaction so all other persons can guess their own correctly?
#Cannot derive it directly from the relationship between first and second as depending on the given case, as state pairs are not unique to a given scenario (see test cases)

#Review this again: These 3 states that apply for all case combinations are represented by calculating the divisibility of the WA from the complete WA observation,
#and finding the divisibility of the WA from the secon person WA observation, we calculate the difference between each other to know which colour to add so that we complete it

#Enter the Epiphany:
# We do not need to send any information from the First-second interaction!
# As this difference between the total WA divisibility (first answer) and the partial WA observation gives us the correct result in every single case!
# Every person hears the first answer and thus knows the total WA divisibility, and due to our corollary 1 and 2 (all the way up), they know the partial WA observation (that excludes them)
# With these two pieces of information, every single person can then correctly find which colour is the one that needs to be added to fulfull the equation

#Color=WA_total % 3 - WA_obs % 3  (With an additional padding so it cycles c-<b-<y-<c...)

# Encode:
# BROWN= WA_total % 3 == 0
# YELLOW=2 WA_total % 3 == 1
# CYAN=3 WA_total % 3 == 2

#Person then decodes, calculates their partial WA_obs, and from the difference (or lack thereof) knows what colour to compensate


#The test cases as well as pattern finding to help me settle and test all possible solutions
#

#b= brown count
#y= yellow count
#c= cyan count
#oc= brown count
#ec= brown count
#wa= weighted average
#dv= weighted average divisibility
#df= Divisibility difference

# b  y  c oc ec wa dv df                    First then Second answer

# 9 10 10       59 2    -> state scenario where brown is odd
# 8 10 10 0o 3e 58 1 1  -> case where person has a brown hat (How it appears to them)
# 9  9 10 2o 1e 57 0 2  -> case where person has a yellow hat (How it appears to them)
# 9 10  9 2o 1e 56 2 0  -> case where person has a cyan hat (How it appears to them)

# 3 4 22        77 2   -> brown odd
# 2 4 22 0o 3e  76 1 1 -> brown             send cyan - brown
# 3 3 22 2o 1e  75 0 2 -> yellow            send cyan - yellow
# 3 4 21 2o 1e  74 2 0 -> cyan              send cyan - cyan

# 3 6 20        75 0   -> brown odd
# 2 6 20 0o 3e  74 2 1 -> brown             send brown  - brown
# 3 5 20 2o 1e  73 1 2 -> yellow            send brown  - yellow
# 3 6 19 2o 1e  72 0 0 -> cyan              send brown  - cyan

# 2 4 23        79 1   -> cyan odd
# 2 6 20 0o 3e  78 0 1 -> brown             send yellow  - brown
# 3 5 20 2o 1e  77 2 2 -> yellow            send yellow  - yellow
# 3 6 19 2o 1e  76 1 0 -> cyan              send yellow  - cyan

# 4+5+20        74 2   -> yellow odd
# 3 5 20 2o 1e  73 1 1 -> brown             send cyan - brown
# 4 4 20 0o 3e  72 0 2 -> yellow            send cyan - yellow
# 4 5 19 2o 1e  71 2 0 -> cyan              send cyan - cyan

# 2+6+21        77 2   -> cyan odd
# 1 6 21 2o 1e  76 1 1 -> brown             send cyan - brown
# 2 5 21 2o 1e  75 0 2 -> yellow            send cyan - yellow
# 2 6 20 0o 3e  74 2 0 -> cyan              send cyan - cyan

# 3+5+21        76 1   -> 3 odd
# 2 5 21 2o 1e  75 0 1 -> brown             send yellow  - brown
# 3 4 21 2o 1e  74 2 2 -> yellow            send yellow  - yellow
# 3 5 20 2o 1e  73 1 0 -> cyan              send yellow  - cyan



#Enter Code
using StatsBase #For the countmap function to find frequencies of the colours
using InvertedIndices #Invert Indices so that we can use it to easily represent the partial observation
using LinearAlgebra #Dot product

EQ_MAT=[1 2 3] # Represent our WA equation in matrix form to perform the dot product
colours=["brown","yellow","cyan"]
colours_ext=["brown","yellow","cyan","brown","yellow"]
for i in 1:1:300 #check multiple runs
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
end

#OLD CODE FOR ATTEMPT #2 UNSUCCESFUL

#First Person analyzes the data, and gives an answer for the first state
# count_dict=countmap(tourists[2:30])                                      # #Gets count for everyone but the first person so that he can find which of the 3 scenarios it is
# count_vec=[count_dict["brown"],count_dict["yellow"],count_dict["cyan"]]
# count_dict=countmap(tourists[3:30])                                      # #Gets count for everyone but the first person so that he can find which of the 3 scenarios it is
# count_vec=[count_dict["brown"],count_dict["yellow"],count_dict["cyan"]]
# first_p_odd_count= sum(count_vec.%2)                                     #First person observes the scenario to inform his instruction
# first_p_next_colour=tourists[2]
# first_p_next_colour_ind=findfirst(isequal(first_p_next_colour),colours)
# if first_p_odd_count== 3
#     first_p_answer=colours_ext[first_p_next_colour_ind+1]                #3 odd scenario, add 2 rotations ==  go backwards 1 rotation
# else
#     if count_vec[first_p_next_colour_ind]%2 == 1
#         first_p_answer=colours_ext[first_p_next_colour_ind]              #1 odd where second hat colour is odd
#     else
#         first_p_answer=colours_ext[first_p_next_colour_ind+2]            #1 odd where second hat colour is not the odd one, add 1 rotation ==  go backwards 2 rotations. send odd one
#     end
# end
#
#
# #Second person analyzes the data, the instruction received from the first answer and gives an answer for the second state
# count_dict=countmap(tourists[3:30])                                      # #Gets count for everyone but the first person so that he can find which of the 3 scenarios it is
# count_vec=[count_dict["brown"],count_dict["yellow"],count_dict["cyan"]]
# second_p_odd_count= sum(count_vec.%2)                                     #First person observes the scenario to inform his instruction
# if second_p_odd_count== 2                                                  #Either 3-odd or 1-odd not the odd hat colour
#     if first_p_answer ==colours[3]
#         second_p_answer=colours[findall(iseven,count_vec)]
#     else
#         instruction=first_p_answer
#         instruction_ind=findfirst(isequal(first_p_answer),colours)
#         odd_index_options=findall(isodd,count_vec)
#         odd_index=odd_index_options[odd_index_options.!=instruction_ind][1]
#         copy_count_vec=copy(count_vec)
#         copy_count_vec[odd_index]+=1
#         if sum(copy_count_vec.%2) ==1                                         ##Attempt 1-odd check
#             second_p_answer=colours_ext[findfirst(isequal(first_p_answer),colours)+1]
#         else
#             second_p_answer=instruction_adj
#         end
#     end
# else                                                                      #1-odd where second hat colour is odd one
#     second_p_answer=first_p_answer
# end
#
# if second_p_answer!=tourists[2]
#     println("ERROR")
# end
#
# #All remaining persons parse the interaction between 1 and 2
# if second_p_answer == first_p_answer
#     type=" 1 odd"
#     odd_colour=first_p_answer
# else
#     offset_answer=colours_ext[findfirst(isequal(first_p_answer),colours)+2]
#     if offset_answer==first_p_answer
#         odd_colour="1 odd"
#         type="1 odd"
#
#     else
#         odd_colour="NA"
#         type="3 odd"
#     end
# end
#
# println(first_p_answer,", ",second_p_answer,", ",type,", ",odd_colour)
#
#
# #Everyone else then saves the data from the two first answers and then gives their own answer
