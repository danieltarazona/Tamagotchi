#lang racket

(require 2htdp/universe)
(require 2htdp/image)
(require racket/local)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Global Variables ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct size (height width))

(define screen (make-size 720 720))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions Interface ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (background w)
  (underlay/xy (rectangle 720 720 "solid" "white") 650 10 (framerate w))
)

(define (framerate w)
   (above (text (string-append "Frame " (number->string w)) 10 "black")
          (text "FPS 60" 10 "black")
   )
)

(define (render w gui)
  (underlay/xy (background w) 100 100 (gui))
)

(define (mouse-x me)
  (me)
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

(define (fps x)
  (/ 1 x)
)

(define (timelapse w a b)
  (cond [(and (and (> w a) (< w b))) #t]
        [else #f]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; GUI ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (intro)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (title)
  (above (text "Tamagotchi" 100 "purple")
         (text "Play" 40 "purple")
         ;(bitmap "img/panda.jpg")
  )
)

(define (menu)
  (above (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "New Game" 20 "black"))
         (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "Continue" 20 "black"))
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (engine w)
  
  (define (start w)
    (+ w 1)
  )
  
  (define (stop w)
    (- w 1)
  )
  
  (define (goto w a)
    (- w (- w a))
  )
  
  (cond [(= w 200) (goto w 0)]
        [(timelapse w 600 700) (stop w)]
        [else (start w)]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gameplay w)
  (cond [(timelapse w 0 300) (render w intro) ]
        [(timelapse w 300 600) (render w title) ]
        [else (render w menu)]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (interactions w x y me)
  (cond [(and (timelapse w 600 700) (equal? me "button-down")) 700]
        ;[(equal? me "leave") 0]
        [else w]
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Main ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(big-bang 0
  (on-tick engine (fps 60))
  (to-draw gameplay (size-width screen) (size-height screen))
  (on-mouse interactions)
  ;(stop-when stop)
  (state #f)
  (name "PandaSushi")
)
