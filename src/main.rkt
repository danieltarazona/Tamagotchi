#lang racket

(require 2htdp/universe)
(require 2htdp/image)


(define (create-UFO-scene height)
	(underlay/xy (rectangle 720 720 "solid" "white") 100 height title1))

(define title1 
	(above (text "Tamagotchi" 97 "purple")
          (bitmap "img/panda.jpg")
          (overlay (rectangle 100 80 "outline" "black")(text "Play" 20 "red"))))

(define (WorldChange w)
  (cond
    [(mouse-event=? "enter")(world-

(define (click w mouse)
  (cond
   [(mouse-event=? "enter")

(big-bang 0
  (on-tick add1 60 1)
  (define (
  (to-draw create-UFO-scene 720 720))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  