(deffacts startup
  (vals 10 20 30 20 30 30))

(defrule match3
   (vals $? ?num1 $? ?num2&~?num1 $?)
=>
  (printout t "Match3" crlf))
