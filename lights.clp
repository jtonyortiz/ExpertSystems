(defrule red-light
(light red)
=>
(printout t "Stop" crlf))

(defrule green-light
(light green)
=>
(printout t "Go" crlf))