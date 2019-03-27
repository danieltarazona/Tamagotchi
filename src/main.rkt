#lang racket

(require 2htdp/universe)
(require 2htdp/image)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions Interface ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (background)
  (rectangle 720 720 "solid" "white")
)

(define (render w interfaceX)
  (underlay/xy (background) 100 100 (interfaceX))
)

(define (clear)
  (nextFrame)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Timer Functions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (waitSeconds x)
  (* x 28)
)

(define (waitMinutes x)
  (* 28 (* x 60))
)

(define (waitHours x)
  (* 24 (* 28 (* x 60)))
)

(define (nextFrame w)
  (+ 1 w)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Interface ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (intro)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (title)
  (above (text "Tamagotchi" 97 "purple")
         ;(bitmap "img/panda.jpg")
         (overlay (rectangle 100 80 "outline" "black")(text "Play" 20 "red"))
  )
)

(define (menu)
  (above (overlay (rectangle 100 80 "outline" "black")(text "New Game" 20 "black"))
         (overlay (rectangle 100 80 "outline" "black")(text "Continue" 20 "black"))
  )
)

(define (gameplay w)
  (cond [(and (> w 0) (< w (waitSeconds 10))) (render w intro) ]
        [(and (> w (waitSeconds 10)) (< w (waitSeconds 20))) (render w title) ]
        [ else (render w menu) ]
  )
)

(define (framerate w)
  (+ 1 w)
)

(define (changeWorldMouse w x y me)
  (cond [(mouse-event? 'left-down) (0)]
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Main ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(big-bang 0
  (on-tick framerate)
  (to-draw gameplay 720 720)
  ;(on-mouse changeWorldMouse)
  ;(stop-when stop)
  (state #t) 
)