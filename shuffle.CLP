(deffacts startup
  (shuffles 0)
  (deck 0 Ace King Queen Jack Ten))

(defrule shuffle
  ?f <- (shuffles ?num&~3)
  (deck ?num ?card1 $?extras ?card2 ?card3)
=>
  (retract ?f)
  (assert (shuffles (+ ?num 1)))
  (assert (deck (+ ?num 1) ?card3 ?card1 ?card2 ?extras)))
  
  
  ;(initial-test)
  ;(deck 0 Ace King Queen Jack Ten)
  ;After 1 run:
  ;(schuffles 1)
  ;(deck 1 Ten Ace Jack King Queen)
  ;After 2 run: 
  ;(schuffles 2)
  ;(deck 2 Queen Ten King Ace Jack)
  ;(shuffles 3)
  ;(deck 3 Jack Queen Ace Ten King)
