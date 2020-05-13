(deftemplate node
   (slot name)
   (slot question)
   (slot L)
   (slot O)
   (slot G)
   (slot B)
   (slot next-question) 	
)

(deftemplate typeValue
 (slot typeName)
 (slot value)
 (slot personalityType)
)


(deffacts initial
(node (name Q1) (question "Question 1") (L "Likes Authority") (O "Enthusiastic") (G "Sensitive Feelings") (B "Likes Instructions") (next-question Q2))
(node (name Q2) (question "Question 2") (L "Takes Charge") (O "Takes Risks") (G "Loyal") (B "Accurate") (next-question Q3))
(node (name Q3) (question "Question 3") (L "Determined") (O "Visionary") (G "Calm, Even Keel") (B "Consistent") (next-question Q4))
(node (name Q4) (question "Question 4") (L "Enterprising") (O "Very Verbal") (G "Enjoys Routine") (B "Predictable") (next-question Q5))
(node (name Q5) (question "Question 5") (L "Competitive") (O "Promoter") (G "Dislikes Change") (B "Practical") (next-question Q6))
(node (name Q6) (question "Question 6") (L "Problem Solver") (O "Enjoys Popularity") (G "Gives In To Others") (B "Factual") (next-question Q7))
(node (name Q7) (question "Question 7") (L "Productive") (O "Fun-Loving") (G "Avoids Confrontations") (B "Conscientious") (next-question Q8))
(node (name Q8) (question "Question 8") (L "Bold") (O "Likes Variety") (G "Sympathetic") (B "Perfectionist") (next-question Q9))
(node (name Q9) (question "Question 9") (L "Decision Maker") (O "Spontaneous") (G "Nurturing") (B "Detail-Oriented") (next-question Q10))
(node (name Q10)(question "Question 10") (L "Persistent") (O "Inspirational") (G "Pacemaker") (B "Analytical") (next-question nil))





(typeValue (typeName L) (value 0) (personalityType "Lion")) 
(typeValue (typeName O) (value 0) (personalityType "Otter")) 
(typeValue (typeName G) (value 0) (personalityType "Gold Retriever")) 
(typeValue (typeName B) (value 0) (personalityType "Bear"))	
(currentQ Init)
)

(defrule InitialPersonList   
   ?Q <- (currentQ Init) 	
=>
   (retract ?Q)
   (assert (currentQ Q1))
)


(deffunction Value-One-Option(?option)
   (printout t ?option " (select 1...4) "crlf)
   (bind ?answer (read))                      
   (while (and (integerp ?answer)(or (< ?answer 1) (> ?answer 4))) 
     (printout t ?option " (select 1...4) "crlf)
     (bind ?answer (read)))                      
   (return ?answer))   

(defrule askQ   
   ?f1 <- (currentQ ?currentNode)
   (node (name ?currentNode) (question ?Q) (L ?L) (O ?O) (G ?G) (B ?B) (next-question ?nextNode))
   ?fL <- (typeValue (typeName L) (value ?LVal))
   ?fO <- (typeValue (typeName O) (value ?OVal))
   ?fG <- (typeValue (typeName G) (value ?GVal))
   ?fB <- (typeValue (typeName B) (value ?BVal))  
=>
   (printout t ?Q ") put the number '4' next to the word that best describes you in that line; a '3' next to the word that
describes you next best; a '2' to the next best word, and a '1' by the word that least describes " crlf)
   (printout t "___" ?L crlf)
   (printout t "___" ?O crlf)
   (printout t "___" ?G crlf)
   (printout t "___" ?B crlf)
   (printout t "*********************" crlf)

   (bind ?LAns (Value-One-Option ?L))                      
   (bind ?OAns (Value-One-Option ?O))                      
   (bind ?GAns (Value-One-Option ?G))                      
   (bind ?BAns (Value-One-Option ?B))                      


   ;(bind ?nextNode (ValidateResponses ?LAns ?OAns ?GAns ?BAns ?currentNode ?nextNode))                      

   (if (neq ?nextNode ?currentNode) then
  (modify ?fL (value (+ ?LVal ?LAns)))
  (modify ?fO (value (+ ?OVal ?OAns)))
  (modify ?fG (value (+ ?GVal ?GAns)))
  (modify ?fB (value (+ ?BVal ?BAns)))
    )
    
   (retract ?f1)
   (assert (currentQ ?nextNode))   
)



(defrule findAns   
   ?f1 <- (currentQ nil)
   ?fL <- (typeValue (typeName L) (value ?lVal))
   ?fO <- (typeValue (typeName O) (value ?oVal))
   ?fG <- (typeValue (typeName G) (value ?gVal))
   ?fB <- (typeValue (typeName B) (value ?bVal)) 	  
=>
   (retract ?f1)
   (assert (currentQ sort))	
   (assert (personalityList ?fL ?fO ?fG ?fB))
   
   (printout t "Results: " crlf)
   (printout t "Lion: " ?lVal crlf)
   (printout t "Otter: " ?oVal crlf)
   (printout t "Golden Retriever: " ?gVal crlf)
   (printout t "Bear: " ?bVal crlf)
   
   
   
)
