(defrule match
  ?f <- (test-string ?first $?rest ?first)
=>
  (retract ?f)
  (assert (test-string $?rest))
  (printout t "Match on " ?first crlf))

(defrule even
  (test-string)
=>
  (printout t "Yes" crlf))

(defrule odd
  (test-string ?)
=>
  (printout t "Yes" crlf))

(defrule no-dice
  (test-string ?first $?rest ?last&~?first)
=>
  (printout t "No" crlf))
