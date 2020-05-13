; ==========================================
; Author: James Anthony Ortiz
; File: family.CLP
; Date: 09/25/2019
; ==========================================


; ===============================
; deftemplate for the program:
; ===============================

(deftemplate parent-of
        (slot parent)
        (slot child))

		
;=============================================
; deffacts for the program:
;=============================================

(deffacts family-tree
        (parent-of (parent Holt) (child Frances))
        (parent-of (parent Viola) (child Frances))
        (parent-of (parent Walter) (child Norm))
        (parent-of (parent Cora) (child Norm))
        (parent-of (parent Frances) (child Steve))
        (parent-of (parent Frances) (child Norman))
        (parent-of (parent Frances) (child Susan))
        (parent-of (parent Norm) (child Steve))
        (parent-of (parent Norm) (child Norman))
        (parent-of (parent Norm) (child Susan))
        (parent-of (parent Susan) (child Chris))
        (parent-of (parent Susan) (child Melissa))
        (parent-of (parent Charles) (child Chris))
        (parent-of (parent Charles) (child Melissa))
        (parent-of (parent Linda) (child Jonathan))
        (parent-of (parent Linda) (child Kristin))
        (parent-of (parent Linda) (child Stephen))
        (parent-of (parent Steve) (child Jonathan))
        (parent-of (parent Steve) (child Kristin))
        (parent-of (parent Steve) (child Stephen))
        (parent-of (parent Jonathan) (child Grayson))
        (parent-of (parent Amy) (child Grayson))
        (parent-of (parent Kristin) (child RJ))
        (parent-of (parent Ryan) (child RJ))        
		(parent-of (parent Stephen) (child Austin))
        (parent-of (parent Stephen) (child Parker))
        (parent-of (parent Sandy) (child Austin))
        (parent-of (parent Sandy) (child Parker)))



; ===========================================
; rule to find parent of child: (functional)
; ===========================================


(defrule find-parents
	 (find-parents-of ?child)
     (parent-of (parent ?parent) (child ?child)) 
	 
	 =>

     (printout t ?parent " is the parent of " ?child crlf))

; ==============================================
; rule to find children of parent: (functional)
; ==============================================


(defrule find-children
	(find-children-of ?parent)
	(parent-of (parent ?parent) (child ?child))
	
	=>
	
	(printout t ?child " is the child of " ?parent crlf))


; =========================================
; rule to find grandchildren: (functional) 
; =========================================

(defrule find-grandchildren
	(find-grandchildren-of ?grandparent)
	(parent-of (parent ?grandparent) (child ?child))
	(parent-of (parent ?child) (child ?gc))

	=>

	(printout t ?gc " is the grandchild of " ?grandparent crlf))


; ========================================
; rule to find grandparents: (functional)
; ========================================

(defrule find-grandparents 
	(find-grandparents-of ?grandchild)
	(parent-of (parent ?child) (child ?grandchild))
	(parent-of (parent ?grandparents) (child ?child))

	
	=>
	
	(printout t  ?grandparents " is the grandparent of " ?grandchild crlf))
	
