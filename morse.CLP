; ===================================================
; File: morse.CLP
; Date: 11/06/2019
; Author: James Anthony Ortiz
; Description: A morse-code translator
; used through the application of deffacts 
; rules, and templates.
; ===================================================


(deftemplate conversion 
	(slot character) 
	(multislot morse-code))

(deffacts conversions
	(conversion (character A) (morse-code * -))
	(conversion (character B) (morse-code - * * *))
	(conversion (character C) (morse-code - * - *))
	(conversion (character D) (morse-code - * *))
	(conversion (character E) (morse-code *))
	(conversion (character F) (morse-code * * - *))
	(conversion (character G) (morse-code - - *))
	(conversion (character H) (morse-code * * * *))
	(conversion (character I) (morse-code * *))
	(conversion (character J) (morse-code * - - -))
	(conversion (character K) (morse-code - * -))
	(conversion (character L) (morse-code * - * *))
	(conversion (character M) (morse-code - -))
	(conversion (character N) (morse-code - *))
	(conversion (character O) (morse-code - - -))
	(conversion (character P) (morse-code * - - *))
	(conversion (character Q) (morse-code - - * -))
	(conversion (character R) (morse-code * - *))
	(conversion (character S) (morse-code * * *))
	(conversion (character T) (morse-code -))
	(conversion (character U) (morse-code * * -))
	(conversion (character V) (morse-code * * * -))
	(conversion (character W) (morse-code * - -))
	(conversion (character X) (morse-code - * * -))
	(conversion (character Y) (morse-code - * - -))
	(conversion (character Z) (morse-code - - * *)))
	
	
(defrule start
=>
(assert (phase start)))

(defrule enter-message
?phase <- (phase start)
=>
(retract ?phase)
(assert (phase start))
(printout t crlf "Enter a message (<CR> to end): ")
(assert (message (explode$ (readline))/)))


(defrule enter-message2
?phase <- (phase start)
=>
(retract ?phase)
(printout t crlf "Enter a message (<CR> to end): ")
(assert (message (explode$ (readline))/)))


(defrule end
(message /)
?phase <- (phase start)
=>
(retract ?phase))


(defrule translate
?message <- (message $?x / $?rest)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message)
(assert (rest $?rest))
(printout t "The message is " ?letter " " ))



(defrule translate2
?message <- (message $?x / $?rest)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message)
(assert (message $?rest))
(assert (rest $?x)))


(defrule translate3
?message <- (message $?x / $?rest)
?letter <- (letter $?l)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message ?letter)
(assert (message $?rest))
(assert (letter $?l ?letter)))


(defrule translate4
?message <- (message $?x / $?rest)
?letter <- (letter $?l)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message ?letter)
(assert (message $?rest))
(assert (letter $?l ?letter))
(assert (phase print)))

(defrule translate5
?message <- (message $?x / $?rest)
?ltr <- (letter $?l)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message ?ltr)
(assert (message $?rest))
(assert (letter $?l ?letter))
(assert (phase print)))



(defrule rest
?message <- (rest $?x / $?rest)
(conversion (character ?letter) (morse-code $?x))
=>
(retract ?message)
(assert (rest $?rest))
(printout t ?letter " " ))


(defrule rest2
?letters <- (letter $?x)
?phase <- (phase print)
=>
(retract ?letters ?phase)
(printout t "The message is: " $?x ))


(defrule rest3
?letters <- (letter $?x)
?phase <- (phase print)
=>
(retract ?letters ?phase)
(assert (phase start))
(printout t "The message is: " $?x ))


(defrule rest4
?letters <- (letter $?x)
?msg <- (message)
=>
(retract ?letters ?msg)
(assert (phase start))
(printout t "The message is: " (implode$ ?x) ))

(defrule bad-message1
(conversion (morse-code $?y))
(not (or (message $?y)
(message /)
(rest $?y /)))
?message <- (message $?x)
=>
(retract ?message)
(assert (phase start))
(printout t "Can't decode this message." ))


(defrule bad-message2
(conversion (morse-code $?y))
(not (and (or (message $?y)
(message /)
(rest $?y /))))
(or ?message <- (message $?x)
?message <- (rest $?x))
=>
(retract ?message)
(assert (phase start))
(printout t "Can't decode this message." ))


(defrule bad-message3
(conversion (morse-code $?y))
(not (and (or (message $?y)(message /)(rest $?y /)(rest))))
(or ?message <- (message $?x)
?message <- (rest $?x))
=>
(retract ?message)
(assert (phase start))
(printout t "Can't decode this message." ))


(defrule bad-message4
(conversion (morse-code $?y))
(not (and (or (message $?y)
(message /))))
?message <- (message $?x)
=>
(retract ?message)
(assert (phase start))
(printout t "Can't decode this message." ))


(defrule del
?rest <- (rest)
=>
(retract ?rest))
