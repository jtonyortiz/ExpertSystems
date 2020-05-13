(deffacts startup
  (vals 10 20 30 20 30 30))

(defrule match1
   (vals $? ?num1 $? ?num2 $?)
=>
  (printout t "Match1" crlf))

