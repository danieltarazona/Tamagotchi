#lang racket

(require 2htdp/universe)
(require 2htdp/image)


(define (create-tamagotchi-scene height)
  (underlay/xy (rectangle 720 720 "solid" "white") 100 height title1)
)

(define title1
  (above (text "Tamagotchi" 97 "purple")
         (bitmap "img/panda.jpg")
         (overlay (rectangle 100 80 "outline" "black")(text "Play" 20 "red"))
  )
)


(define (changeWorldMouse w x y me)
  (cond [(mouse-event=? me 'left-down) (+ 1 w)]
  )
)



(big-bang 0
  (on-tick add1)
  (to-draw create-tamagotchi-scene 720 720)
  (on-mouse changeWorldMouse)
)
  
  