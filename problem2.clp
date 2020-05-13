(defrule prerequisites
  (initialize-program)
=>
  (assert
    (after COP1000 take COP2000)
    (after COP1001 take COP2001)
    (after MAC1000 take MAC2000)
    (after MAC1001 take MAC2001)
    (after ENG1000 take ENG2000))
)

(defrule Message "Welcome Message for program 2"
	(not (initialize-program)) 
=> 
	(printout t "Welcome to the advising system." crlf)
	(assert (initialize-program))
	)

(defrule Control "Control for output"
	(after ?course1 take ?course2)
	(student ?name $? ?course1 $?)
=>
	(printout t "Since " ?name " has taken " ?course1 ", I suggest taking " ?course2 "." crlf))

