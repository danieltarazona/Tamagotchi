#lang racket

(require 2htdp/universe)
(require 2htdp/image)
;(require racket/draw)


(define (create-UFO-scene height)
	(underlay/xy (rectangle 720 720 "solid" "white") 100 height title1))

(define title1 
	(above (text "Tamagotchi" 97 "purple")
          (bitmap "tamagotchi/src/img/panda.jpg")))
 
	


(big-bang 0
	(on-tick add1 60 1)
	(to-draw create-UFO-scene 720 720))