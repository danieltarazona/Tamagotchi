#lang racket

(require 2htdp/universe)
(require 2htdp/image)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Global Variables ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct size (height width))
(define screen (make-size 432 768)) ;True 16:9
(define fps 60)
(define totalFrames 30000)
(define assets "assets/")
(define actualState "Main")
(define initialFrame 0)
(define finalFrame 120)

(define debug #t)
(define showFrames #t)
(define showFPS #t)
(define showActualState #t)
(define showTimeline #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct sprite (name [path #:mutable] frames ext) #:transparent)
(define idleState (make-sprite "idle" "" 120 ".png"))

(define-struct gui (name frames ui) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Debugging Tools ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (setTrueFPS)
   (set! showFPS #t)
)

(define (setFalseFPS)
   (set! showFPS #f)
)

(define (setTrueTimeline)
   (set! showTimeline #t)
)

(define (setFalseTimeline)
   (set! showTimeline #f)
)

(define (debugTools w)
  
  (above (if showFrames
             (text (string-append "FRAME: " (number->string w)) 12 "black")
                (text "" 10 "black"))
         (if showActualState
             (text (string-append "STATE: " actualState) 12 "black")
                (text "" 10 "black"))
         (if showFPS
             (text (string-append "FPS: " (number->string fps)) 10 "black")
                (text "" 10 "black"))
         (text (string-append "InitialFrame: " (number->string initialFrame)) 10 "black")
         (text (string-append "FinalFrame: " (number->string finalFrame)) 10 "black")
  )         
)


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

(define (framerate)
  (/ 1 fps)
)

(define (timelapse w a b)
  (cond [(and (and (>= w a) (< w b))) #t]
        [else #f]
  )
)

(define (goto w a)
   (- w (- w a))
)

(define (start w)
   (+ w 1)
)
  
(define (stop w)
   (- w 1)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (engine w)
  
  (start w)
  
  ;(cond [(= w 200) (goto w 0)]
  ;      [(timelapse w 600 700) (stop w)]
  ;      [else (start w)]
  ;)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (introUI)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (titleUI)
  (above (text "Tamagotchi" 100 "purple")
         (text "Play" 40 "purple")
  )
)

(define (menuUI)
  (above (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "New Game" 20 "black"))
         (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "Continue" 20 "black"))
  )
)

(define intro (make-gui "intro" 120 (introUI)))
(define title (make-gui "title" 120 (titleUI)))
(define menu (make-gui "menu" 120 (menuUI)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (background w)
  (cond [(equal? debug #t)
  (underlay/xy
     (underlay/xy
        (underlay/xy
        (rectangle (size-width screen) (size-height screen) "solid" "white") 620 10 (debugTools w)
     )
      0 408
     (rectangle 756 20 "outline" "black"))
     (+ w 1) 395
     (isosceles-triangle 15 -30 "solid" "red"))
     
  ]
  [else (rectangle (size-width screen) (size-height screen) "solid" "white")]
  )
)

(define (renderGUI w ui)
  (cond [(gui? ui) 
     (set! actualState "GUI")
     (underlay/xy (background w) 100 100 (gui-ui ui))
  ])
)

(define (spritePath sprite)
  (cond [(sprite? sprite)
            (string-append assets "sprites/" (sprite-name sprite) "/")]
  )
)

(define (spriteDraw w sprite)
  (set-sprite-path! sprite (spritePath sprite))
  (set! actualState (string-append "Sprite "(sprite-name sprite)))
  (cond [(and (string? (sprite-path sprite)) (not (equal? (sprite-path sprite) "")))
            (bitmap/file (string-append (sprite-path sprite) (number->string w) (sprite-ext sprite)))
        ]
  )
  (cond [(= w 1)(set! initialFrame w)])
)

(define (setSplitFrame w ui)
   (cond [(sprite? ui) (set! finalFrame (+ w (sprite-frames ui))) ]
         [(gui? ui) (set! finalFrame (+ w (gui-frames ui))) ]
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

(define (change w keypress)
  (cond
    [(key=? keypress "left") initialFrame]
    [(key=? keypress "right") finalFrame]
    [else w]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (play w x y ui)
   (setSplitFrame w ui)
   (cond [(and (gui? ui) (timelapse w x y)) (renderGUI w ui)]
         [(and (sprite? ui) (timelapse w x y)) (renderSprite w ui)]
         [else (renderGUI w menu)]
   )
)

(define (gameplay w)
   (play w 0 120 intro)
   (play w 120 240 title)
   ;(play w 240 360 menu)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; MAIN ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(big-bang 0
  (on-tick engine (framerate))
  (to-draw gameplay (size-width screen) (size-height screen))
  (on-mouse interactions)
  (on-key change)
  ;(stop-when stop)
  (state #f)
  (name "PandaSushi")
)
