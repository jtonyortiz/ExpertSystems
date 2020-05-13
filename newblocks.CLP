; ============================================
; Author: James Anthony Ortiz
; Course: CEN4681 - Expert Systems
; Date: 10/07/2019
; File: newblocks.CLP
; ============================================



(defrule move-to-floor
	(goal-stack $?gtop ?goal $?rest)
	(not (stack $?stop ?goal $?rest))
	?stack <- (stack $?top&:(member$ ?goal ?top) ?rest2)
	=>
	(retract ?stack)
	(assert (stack (first$ (create$ ?top))))
	(assert (stack (rest$ ?top) $?rest2))
	(printout t (implode$ (first$ ?top)) " moved on top of floor" crlf))

(defrule move-correct	
	(declare (salience 99))
	(goal-stack $?top ?block1 ?block2 $?rest)
	?stack1 <- (stack ?block1 $?rest2)
	?stack2 <- (stack ?block2 $?rest)

	=>

	(retract ?stack1 ?stack2)
	(assert (stack $?rest2))
	(assert (stack ?block1 ?block2 ?rest))
	(printout t ?block1 " moved on top of " ?block2 crlf))