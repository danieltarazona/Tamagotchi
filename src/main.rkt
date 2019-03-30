#lang racket

(require 2htdp/universe)
(require 2htdp/image)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Global Variables ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct size (height width))

(define screen (make-size 720 720))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (current-directory)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions Engine ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions Sprites ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define assets "assets/")

(define-struct sprite (name [path #:mutable] frames ext) #:transparent)

(define idleState (make-sprite "idle" "" 120 ".png"))

(define (spritePath sprite)
  ;(lambda (w i) (+ w (- w w) 1) w 1)
  (cond [(sprite? sprite)
            (string-append assets "sprites/" (sprite-name sprite) "/")]
  )
)

(define (spriteDraw w sprite)
  (set-sprite-path! sprite (spritePath sprite))
  (sprite-path sprite)
  (cond [(and (string? (sprite-path sprite)) (not (equal? (sprite-path sprite) "")))
            (bitmap/file (string-append (sprite-path sprite) (number->string w) (sprite-ext sprite)))
        ]
  )  
)

(define (renderSprite w sprite)
   (underlay/xy (background w) 100 100 (spriteDraw w sprite))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (interactions w x y me)
  (cond [(and (timelapse w 600 700) (equal? me "button-down")) 700]
        ;[(equal? me "leave") 0]
        [else w]
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gameplay w)
  (cond ;[(timelapse w 0 300) (render w intro) ]
        [(timelapse w 0 300) (renderSprite w idleState) ]
        [(timelapse w 300 600) (render w title) ]
        [else (render w menu)]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; MAIN ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(big-bang 0
  (on-tick engine (fps 60))
  (to-draw gameplay (size-width screen) (size-height screen))
  (on-mouse interactions)
  ;(stop-when stop)
  (state #f)
  (name "PandaSushi")
)
