;================================================================
; Author: James Anthony Ortiz
; File: BetterFamily.CLP
; Description: Improved version of family program,
; with the use of control facts, error checking and salience.
; ===============================================================


;==========================================
; deftemplate family
; 
;===========================================
(deftemplate family
 (slot mother)
 (slot father)
 (multislot daughters)
 (multislot sons))



; =================================
; deffacts family-tree
;
; =================================

(deffacts family-tree
 (family (mother Viola) (father Holt)
 (daughters Frances Mildred))
 (family (mother Cora) (father Walter)
 (daughters Jaunita Dorothy Peggy) (sons Norm Carson))
 (family (mother Frances) (father Norm)
 (daughters Susan) (sons Norman Steve))
 (family (mother Susan) (father Charlie)
 (daughters Melissa) (sons Chris))
 (family (mother Linda) (father Steve)
 (daughters Kristin) (sons Stephen Jonathan))
 (family (mother Kristin) (father Ryan)
 (sons RJ))
 (family (mother Sandy) (father Stephen)
 (sons Austin Parker))
 (family (mother Amy) (father Jonathan)
 (sons Grayson)))
 
 ; ======================================
 ; defrule Start
 ; Begins program for BetterFamily by asserting
 ; choose-action.
 ; ======================================


(defrule start
=>
	(assert (phase choose-action)))

; ====================================
; defrule menu 
; Provides prompt for the screen:
; ====================================


(defrule menu
	(phase choose-action)
=>
(printout t "Tell me what you're looking for: 
1) The parents of someone.
2) The mother of someone.
3) The father of someone.
4) I'd like to quit!
What's your pleasure (1-4)? ")
	(assert (user-select (read))))


; =======================================
; defrule good-choice 
; Checks to see if the value entered is 
; correct from the user.
; =======================================


(defrule good-choice
	?phase <- (phase choose-action)
	?choice <- (user-select ?select&1 | 2 | 3 | 4)
=>
	(retract ?phase ?choice)
	(assert (selection ?select))
	(assert (phase select-child)))

; ========================================
; defrule incorrect-choice
; Tells user that the input is incorrect 
; and retracts the choice.
; ========================================



(defrule incorrect-choice
	?phase <- (phase choose-action)
	?choice <- (user-select ?select&~1&~2&~3&~4)
=>
	(retract ?phase ?choice)
	(assert (phase choose-action))
	(printout t ?select " is not a valid response, silly! Give me a 1 through 4." crlf))

; ==========================================
; defrule quit
; Allows the user to quit the program.
; ==========================================

(defrule quit
	?phase <- (phase select-child)
	?choice <- (selection ?select&4)
=>
	(retract ?phase ?choice)
	(printout t "Thanks for chatting with me!" crlf))

; ===========================================
; defrule get-name 
; Allows the user to enter a name given the 
; selection. 
; ===========================================

(defrule get-name
	?phase <- (phase select-child)
	?choice <- (selection ?select&1 | 2 | 3)
=>
	(retract ?phase)
	(assert (phase select-parent))
	(printout t "... and who is that special someone? ")
	(assert (get-someone (read))))


; ===========================================
; defrule correct-name 
; Finds if the name is in the list. 
; ===========================================



(defrule correct-name
	?phase <- (phase select-parent)
	?name <- (get-someone ?person)
	(or (family (daughters $? ?person $?)) 
	(family (sons $? ?person $?)))
=>
	(retract ?phase)
	(assert (phase return-parents)))

; =========================================
; defrule get-parents
; Obtain information from the parents
; in the family list.
; =========================================


(defrule get-parents
	?phase <- (phase return-parents)
	?name <- (get-someone ?person)
	?choice <- (selection ?select&1)
	(and (or (family (mother ?mom) (father ?dad) (sons $? ?person $?))
	(family (mother ?mom) (father ?dad) (daughters $? ?person $?))))
=>
	(retract ?phase ?name ?choice)
	(assert (phase choose-action))
	(printout t "Here are the parents of " ?person ":
	" ?mom " is " ?person "'s mother.
	" ?dad " is " ?person "'s father." crlf))

; ==========================================
; defrule get-mother
; Obtain information from the mother in the 
; family list.
; ==========================================


(defrule get-mother
	?phase <- (phase return-parents)
	?name <- (get-someone ?person)
	?choice <- (selection ?select&2)
	(and (or (family (mother ?mom) (father ?dad) (sons $? ?person $?))
	(family (mother ?mom) (father ?dad) (daughters $? ?person $?))))
=>
	(retract ?phase ?name ?choice)
	(assert (phase choose-action))
	(printout t ?mom " is " ?person "'s mother." crlf))

; =============================================
; defrule get-father 
; Obtain information related to the father in
; the family list.
; =============================================



(defrule get-father
	?phase <- (phase return-parents)
	?name <- (get-someone ?person)
	?choice <- (selection ?select&3)
	(and (or (family (mother ?mom) (father ?dad) (sons $? ?person $?))
	(family (mother ?mom) (father ?dad) (daughters $? ?person $?))))
=>
	(retract ?phase ?name ?choice)
	(assert (phase choose-action))
	(printout t ?dad " is " ?person "'s father." crlf))

; ===================================
; defrule no-info 
; If the person entered does not have
; any information from the list 
; ===================================

(defrule no-info
	?phase <- (phase select-parent)
	?name <- (get-someone ?person)
	?choice <- (selection ?select)
	(and (or (family (mother ?person))
	(family (father ?person))))
=>
	(retract ?phase ?name ?choice)
	(assert (phase choose-action))
	(printout t "I can find no information on " ?person
	"'s parents." crlf))

; ===================================
; defrule incorrect-name 
; If the person is not in the list,
; show a message.
; ===================================


(defrule incorrect-name
	?phase <- (phase select-parent)
	?name <- (get-someone ?person)
	?choice <- (selection ?select)
	(family (mother ?mom) (father ?dad) (daughters $?girl) (sons $?boy))
=>
	(retract ?phase ?name ?choice)
	(assert (phase choose-action))
	(printout t "I know nothing about " ?person "!" crlf))