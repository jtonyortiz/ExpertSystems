; ===============================
; deftemplates for the program:
; ===============================

(deftemplate parent-of
        (slot parent)
        (slot child))
		
(deftemplate children-of	
		(slot child)
		(slot parent))
		
(deftemplate grandparents-of
		(slot grandparent)
		(slot grandchild))

(deftemplate grandchildren-of 
		(slot grandchild)
		(slot grandparent))
		

		
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



; ================================================
; rule to find parents:
; ================================================

(defrule find-parents

	 (find-parents-of ?child)
     (parent-of (parent ?parent) (child ?child)) 
	 
	 =>

     (printout t ?parent " is the parent of " ?child "." crlf))

; ==================================================
; rule to find child of parent:
; ==================================================

(defrule find-children
	
	(find-children-of ?parent)
    (children-of (child ?child) (parent ?parent)) 
	 
	 =>

     (printout t ?child " is the child of " ?parent "." crlf))
	 
; ====================================================
; rule to find grandparents:
; ====================================================

(defrule find-grandparents

	(find-grandparents-of ?grandchild)
	(grandparents-of (grandparent ?grandparent) (grandchild ?grandchild))

	=>

	(printout t ?grandparent " is the grandparent of " ?grandchild "." crlf))

; =====================================================
; rule to find grandchildren:
; =====================================================

(defrule find-grandchildren

	(find-grandparents-of ?grandchild)
	(grandchildren-of (grandchild ?grandchild) (grandparent ?grandparents))

	=>

	(printout t ?grandchild " is the grandchild of " ?grandparents "." crlf))


