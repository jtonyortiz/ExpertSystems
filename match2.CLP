(deffacts startup
  (vals 10 20 30 20 30 30))

(defrule match2
   (vals $? ?num1 $? ?num1 $?)
=>
  (printout t "Match2" crlf))
