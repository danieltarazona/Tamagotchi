#lang racket

(require 2htdp/universe)
(require 2htdp/image)

(define (background)
  (rectangle 720 720 "solid" "white")
)

(define (worldIntro w)
  (underlay/xy (background) 100 100 (interface1))
)

(define (worldMenu w)
  (underlay/xy (background) 100 100 (interface2))
)

(define (interface1)
  (above (text "Tamagotchi" 97 "purple")
         ;(bitmap "img/panda.jpg")
         (overlay (rectangle 100 80 "outline" "black")(text "Play" 20 "red"))
  )
)

(define (interface2)
  (above (overlay (rectangle 100 80 "outline" "black")(text "New Game" 20 "black"))
         (overlay (rectangle 100 80 "outline" "black")(text "Continue" 20 "black"))
  )
)

;(define (game w)
;  (cond [ (> w 280) (worldMenu w) ]
;        [ else (worldIntro w) ]
;  )
;)

(define (game w)
  (worldIntro w)
)

(define (gameplay w)
  (+ 1 w)
)

(define (changeWorldMouse w x y me)
  (cond [(mouse-event? 'enter) (set! w 1680)]
        [else w]
  )
)

(big-bang 0
  (on-tick gameplay)
  (to-draw game 720 720)
  (on-mouse changeWorldMouse)
  (state #t) 
)
  

  
  