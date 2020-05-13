(defrule WelcomeMessage "Message for program 1"
=>
(printout t "Have a good day!" crlf))

(defrule ruleOne "If student has taken MAC1140, student should take COP3014."
	(I have taken MAC1140)
=> 
	(printout t "You should take COP3014." crlf))

(defrule ruleTwo "If student has taken COP3014, student should take CGS4092."
	(I have taken COP3014)
=>
	(printout t "You should take CGS4092." crlf))

(defrule ruleThree "If student has taken COP3014, and COP3353, student should take COP3330"
	(I have taken COP3014)
	(I have taken COP3353)
=>
	(printout t "You should take COP3330." crlf))

(defrule ruleFour "If student has taken COP3330, student should take COP3252"
	(I have taken COP3330)
=>
	(printout t "You should take COP3252." crlf))

(defrule ruleFive "If student has taken COP3330, and MAD2104, student should take COP4530"
	(I have taken COP3330)
	(I have taken MAD2104)
=>
	(printout t "You should take COP4530." crlf))

