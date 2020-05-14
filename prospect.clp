; name of deftemplate relation

(deftemplate prospect
	;optional comment in quotes
	"vital information"
	; name of field
	(slot name
	; type of field
	(type STRING)
	; default value of field name
	(default ?DERIVE))
	; name of field
	(slot assets
	; type of field 
	(type SYMBOL)
	; default value of field assets 
	(default rich))
	; name of field 
	(slot age
	; type . NUMBER can be an INTEGER or FLOAT
	(type NUMBER)
	; default value of field age
	(default 80)))
