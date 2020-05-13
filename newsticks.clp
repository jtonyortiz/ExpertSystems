;======================================================
; Author: James Anthony Ortiz  
; File: newsticks.clp
; Date: 11/21/2019
; Description: Updated version of the sticks program
;======================================================

; =====================================================
; FACT TEMPLATES
; =====================================================

; The phase fact indicates the current action to be
; undertaken before the game can begin

; (phase 
;    <action>)      ; Either choose-player or 
                    ; select-pile-size

; The player-select fact contains the human's response to 
; the "Who moves first?" question.

; (player-select
;    <choice>)      ; Valid responses are c (for computer)
                    ; and h (for human).
    
; The pile-select fact contains the human's response to 
; the "How many sticks in the pile?" question.

; (pile-select
;    <choice>)      ; Valid responses are integers 
                    ; greater than zero.

; The pile-size fact contains the current number 
; of sticks in the stack.

; (pile-size
;    <sticks>)      ; An integer greater than zero.

; The player-move fact indicates whose turn it is.

; (player-move
;    <player)       ; Either c (for computer) 
                    ; or h (for human).

; The human-takes fact contains the human's response to 
; the "How many sticks do you wish to take?" question.


; (human-takes
;    <choice>)      ; Valid responses are 1, 2, and 3.

; The take-sticks facts indicate how many sticks the 
; computer should take based on the remainder when the 
; stack size is divided by 4.

(deftemplate take-sticks
   (slot how-many)         ; Number of sticks to take.
   (slot for-remainder))   ; Remainder when stack is
                           ; divided by 4.

; ====================================================
; DEFFACTS 
; ====================================================

(deffacts initial-phase
   (phase choose-player)
   (phase opponent-player))

(deffacts take-sticks-information
   (take-sticks (how-many 1) (for-remainder 1))
   (take-sticks (how-many 1) (for-remainder 2))
   (take-sticks (how-many 2) (for-remainder 3))
   (take-sticks (how-many 3) (for-remainder 0)))

; *****
; RULES 
; *****

; RULE player-select
; IF
;   The phase is to choose the first player
; THEN
;   Ask who should move first, and
;   Get the human's response

(defrule ask-for-user-name
	(initial-fact)
=>
(printout t "What is your name? ")
(assert (name (read)))
(assert (phase choose-opponent))
(assert (select-opp)))

(defrule select-opponent
	?phase <- (phase choose-opponent)
	?select <- (select-opp)
	(name ?selected)
=>
	(retract ?phase ?select)
	(printout t ?selected " select your opponent (Computer: c  Human: h)? ")
	(assert (opponent-select (read)))
	(assert (phase choose-opponent)))
	
(defrule player2-select
	(name ?selected)
	?phase <- (phase choose-player)
	?make <- (make-move)
	?opp <- (opponent-move ?player&h | h)
=>
    (retract ?opp ?make)
    (printout t "I'm gonna give you a break, " ?selected ", and let you go first." crlf)
    (printout t "By the way, what is your opponent's name? ")
    (assert (op-name (read)))
    (assert (phase choose-player))
    (assert (player-select h)))
	
(defrule good-opponent-choice
   ?phase <- (phase choose-opponent)
   ?opp <- (opponent-select ?player&c | h)
   =>
   (retract ?phase ?opp)
   (assert (phase choose-player))
   (assert (make-move))
   (assert (opponent-move ?player)))
   
(defrule bad-opponent-choice
   ?phase <- (phase choose-opponent)
   (name ?selected)
   ?opp <- (opponent-select ?player&~c&~h)
   
 =>
 
    (retract ?phase ?opp)
    (printout t "Come on, " ?selected "!!  Choose c or h." crlf)
	(assert (phase choose-opponent))
	(assert (select-opp)))
	
(defrule player-select
   ?make <- (make-move)
   (name ?selected)
   ?phase <- (phase choose-player)
   (opponent-move ?player&~h)
   
   =>
   
   (retract ?phase ?make)
   (printout t "Hey " ?selected "!  Who moves first (Computer: c "
               "Human: h)? ")
   (assert (player-select (read)))
   (assert (phase choose-player)))
   
; RULE good-player-choice
; IF
;   The phase is to choose the first player, and
;   The human has given a valid response
; THEN
;   Remove unneeded information, and 
;   Indicate whose turn it is, and
;   Indicate that the pile size should be chosen

(defrule good-player-choice
   ?phase <- (phase choose-player)
   ?choice <- (player-select ?player&c | h)
   
   =>
   
   (retract ?phase ?choice)
   (assert (player-move ?player))
   (assert (phase select-pile-size)))
   
 (defrule good-player2-choice
   ?phase <- (phase choose-player)
   ?choice <- (player-select ?player&p2)
   
   =>
   
   (retract ?phase ?choice)
   (assert (player-move ?player))
   (assert (phase select-pile-size)))

; RULE bad-player-choice
; IF
;   The phase is to choose the first player, and
;   The human has given a invalid response
; THEN
;   Remove unneeded information, and 
;   Indicate that the first player should be chosen again, 
;   and Print the valid choices

(defrule bad-player-choice
   (name ?selected) 
   ?phase <- (phase choose-player)
   ?choice <- (player-select ?player&~c&~h)
   
   =>
   
   (retract ?phase ?choice)
   (assert (phase choose-player))
   (assert (make-move))
   (printout t "Come on, " ?selected "!!  Choose c or h." crlf))

; RULE pile-select
; IF
;   The phase is to choose the pile size
; THEN
;   Ask what the pile size should be, and
;   Get the human's response

(defrule pile-select
   (name ?selected) 
   (phase select-pile-size)
   
   =>
   
   (printout t ?selected ", how many sticks in the pile? ")
   (assert (pile-select (read))))

; RULE good-pile-choice
; IF
;   The phase is to choose the pile size, and
;   The human has given a valid response
; THEN
;   Remove unneeded information, and 
;   Store the pile size

(defrule good-pile-choice
   ?phase <- (phase select-pile-size)
   ?choice <- (pile-select ?size&:(integerp ?size)
                                &:(> ?size 0))
								
   =>
   
   (retract ?phase ?choice)
   (assert (pile-size ?size)))

; RULE bad-pile-choice
; IF
;   The phase is to choose the pile size, and
;   The human has given a invalid response
; THEN
;   Remove unneeded information, and 
;   Indicate that the pile size should be chosen again, 
;   and Print the valid choices

(defrule bad-pile-choice
   ?phase <- (phase select-pile-size)
   ?choice <- (pile-select ?size&~:(integerp ?size)
                                 |:(<= ?size 0))
								 
   =>
   
   (retract ?phase ?choice)
   (assert (phase select-pile-size))
   (printout t "Choose an integer greater than zero."
               crlf))


; RULE computer-loses
; IF
;   The pile size is 1, and
;   It is the computer's move
; THEN
;   Print that the computer has lost the game

(defrule computer-loses
   (pile-size 1)
   (player-move c)
   
   =>
   
   (printout t "The computer must take the last stick!" crlf)
   (printout t "The computer loses!" crlf))

; RULE human-loses
; IF
;   The pile size is 1, and
;   It is the human's move
; THEN
;   Print that the human has lost the game

(defrule human-loses
   (name ?selected)
   (pile-size 1)
   (player-move h)
   
   =>
   
   (printout t "Sorry, " ?selected ".  You must take the last stick!" crlf)
   (printout t "You lose!" crlf))
   
(defrule human-loses2
   (declare (salience 10))
   (op-name ?opname)
   (name ?selected)
   (pile-size 1)
   ?p <- (player-move h)
   
   =>
   
   (retract ?p)
   (printout t ?selected ",  you must take the last stick!" crlf)
   (printout t "You lose!" crlf))
   
(defrule human-loses3
   (declare (salience 15))
   (op-name ?opname)
   (name ?selected)
   (pile-size 1)
   (player2-move)
   
   =>
   
   (printout t ?opname ",  you must take the last stick!" crlf)
   (printout t "You lose!" crlf))


; RULE get-human-move
; IF
;   The pile size is greater than 1, and
;   It is the human's move
; THEN
;   Ask how many sticks to take, and
;   Get the human's response

(defrule get-human-move
   (name ?selected)
   (pile-size ?size&:(> ?size 1))
   (player-move h)
   
   =>
   
   (printout t ?selected ", how many sticks do you wish to take? ")
   (assert (human-takes =(read)))
   (assert (player2-move)))
   
 (defrule get-human2-move
 	(name ?selected)
 	(op-name ?opname)
 	(pile-size ?size&:(> ?size 1))
 	?p2 <- (player2-move)
	
 =>
 
 	 (retract ?p2)
     (printout t ?opname ", how many sticks do you wish to take? ")
     (assert (human-takes =(read)))
     (assert (player1-move))
     (assert (ok-to-check))
     (assert (player-move h)))

; RULE good-human-move
; IF
;   There is a pile of sticks, and
;   The human has chosen how many sticks to take, and
;   It is the human's move, and
;   The human's choice is valid
; THEN
;   Remove unneeded information, and 
;   Compute the new pile size, and
;   Update the pile size, and
;   Print the number of sticks left in the stack, and
;   Trigger the computer player's turn

(defrule good-human-move
   (declare (salience 200))
   (not (op-name ?opname))
   ?pile <- (pile-size ?size)
   ?move <- (human-takes ?choice)
   ?whose-turn <- (player-move h)
   (test (and (integerp ?choice)
              (>= ?choice 1) 
              (<= ?choice 3)
              (< ?choice ?size)))
			  
   =>
   
   (retract ?pile ?move ?whose-turn)
   (bind ?new-size (- ?size ?choice))
   (assert (pile-size ?new-size))
   (printout t ?new-size " stick(s) left in the pile."
               crlf)
   (assert (player-move c)))
   
  (defrule good-human2-move
  (declare (salience 100))
    (not (ok-to-check))
   ?p <- (player2-move)
   ?pile <- (pile-size ?size)
   ?move <- (human-takes ?choice)
   ?whose-turn <- (player-move h)
   (test (and (integerp ?choice)
              (>= ?choice 1) 
              (<= ?choice 3)
              (< ?choice ?size)))
			  
   =>
   
   (retract ?pile ?move ?whose-turn ?p)
   (bind ?new-size (- ?size ?choice))
   (assert (pile-size ?new-size))
   (printout t ?new-size " stick(s) left in the pile."
               crlf)
   (assert (player2-move)))
   
     (defrule good-human3-move
     (declare (salience 150))
     ?ok <- (ok-to-check)
     ?p <- (player1-move)
     ?pile <- (pile-size ?size)
     ?move <- (human-takes ?choice)
     ?whose-turn <- (player-move h)
     (test (and (integerp ?choice)
              (>= ?choice 1) 
              (<= ?choice 3)
              (< ?choice ?size)))
			  
 =>
 
   (retract ?pile ?move ?whose-turn ?p ?ok)
   (bind ?new-size (- ?size ?choice))
   (assert (pile-size ?new-size))
   (printout t ?new-size " stick(s) left in the pile."
               crlf)
   (assert (player-move h)))

; RULE bad-human-move
; IF
;   There is a pile of sticks, and
;   The human has chosen how many sticks to take, and
;   It is the human's move, and
;   The human's choice is invalid
; THEN
;   Print the valid choices, and
;   Remove unneeded information, and
;   Retrigger the human player's move


(defrule bad-human-move
   (name ?selected)
   (pile-size ?size)
   ?move <- (human-takes ?choice)
   ?whose-turn <- (player-move h)
   (test (or (not (integerp ?choice)) 
             (< ?choice 1) 
             (> ?choice 3)
             (>= ?choice ?size)))
			 
   =>
   
   (printout t "Hey " ?selected "!! The number of sticks must be between 1 and 3,"
               crlf
               "and you must be forced to take the last "
               "stick." crlf)
   (retract ?move ?whose-turn)
   (assert (player-move h)))

; RULE computer-move
; IF
;   It is the computers's move, and
;   The pile size is greater than 1, and
;   The computer's response is available
; THEN
;   Remove unneeded information, and
;   Compute the new pile size, and
;   Print the number of sticks left in the stack, and
;   Update the pile size, and
;   Trigger the human players move

(defrule computer-move
   ?whose-turn <- (player-move c)
   ?pile <- (pile-size ?size&:(> ?size 1))
   (take-sticks (how-many ?number)
                (for-remainder =(mod ?size 4)))
				
   =>
   
   (retract ?whose-turn ?pile)
   (bind ?new-size (- ?size ?number))
   (printout t "The computer takes " ?number " stick(s)."
               crlf)
   (printout t ?new-size " stick(s) left in the pile."
               crlf)
   (assert (pile-size ?new-size))
   (assert (player-move h)))