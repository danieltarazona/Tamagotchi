#lang racket


(require 2htdp/universe)
(require 2htdp/image)
;(require test-engine/racket-tests)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Global Variables ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define screenHeight 432) ;True 16:9
(define screenWidth 768) ;True 16:9
(define fps 60)
(define totalFrames 30000)
(define assets "assets/")
(define actualState "Main")
(define startFrame 0)
(define endFrame 0)
(define count 0)
(define search 0)
(define petName "Panda")

(define debug #t)
(define showFrames #t)
(define showFPS #t)
(define showActualState #t)
(define showTimeline #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct gui (name frames ui) #:transparent)
(define-struct sprite (name [path #:mutable] frames ext) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; States ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define idleState (make-sprite "idle" "" 120 ".png"))

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
             (text (string-append "Frame: " (number->string w)) 12 "black")
                (text "" 10 "black"))
         (if showActualState
             (text (string-append "State: " actualState) 12 "black")
                (text "" 10 "black"))
         (if showFPS
             (text (string-append "FPS: " (number->string fps)) 12 "black")
                (text "" 10 "black"))
         (text (string-append "Count: " (number->string count)) 12 "black")
         (text (string-append "Start: " (number->string startFrame)) 12 "black")
         (text (string-append "End: " (number->string endFrame)) 12 "black")
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
  (cond [(and (>= w a) (<= w b)) #t]
        [else #f]
  )
)

(define (addOneCount)
  (set! count (+ 1 count))
)

(define (setZeroCount)
  (set! count 0)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (background w)
  (cond
     [(equal? debug #t)
        (underlay/xy
        (underlay/xy
        (underlay/xy
        (rectangle screenWidth screenHeight "solid" "white") 620 10 (debugTools w))
        0 408
     (rectangle 756 20 "outline" "black"))
     (+ w 1) 395
     (isosceles-triangle 15 -30 "solid" "red"))]
     
  [else (rectangle screenWidth screenHeight "solid" "white")]
  )
)

(define (introUI w)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (titleUI w)
  (above (text "Tamagotchi" 100 "purple")
         (text "Play" 40 "purple")
  )
)

(define (menuUI w)
  (above (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "New Game" 20 "black"))
         (underlay/xy (rectangle 100 80 "outline" "black") 0 0 (text "Continue" 20 "black"))
  )
)

(define (nameUI w)
  (above (text "Ingresa el nombre" 16 'black)
         (text petName 24 'black)
  )
)

(define intro (gui "intro" 120 introUI))
(define title (gui "title" 120 titleUI))
(define menu (gui "menu" 120 menuUI))
(define rename (gui "name" 120 nameUI))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (startEndFrames w ui)

  ; (cond [(equal? debug #t) (writeln startFrame)])
  
  (cond [(= w endFrame) (set! startFrame w)]
        [(gui? ui) (set! endFrame (+ startFrame (gui-frames ui)))]
        [(sprite? ui) (set! endFrame (+ startFrame (sprite-frames ui)))]
  )
)

(define (render w ui)

  (startEndFrames w ui)
  
  (cond [(sprite? ui)
          (set-sprite-path! ui (spritePath ui))
          (set! actualState (string-append "SPRITE "(sprite-name ui)))
          (underlay/xy (background w) 300 150 (spriteDraw w ui))
        ]

        [(gui? ui)
          (set! actualState "GUI")
          (underlay/xy (background w) 300 150 (guiDraw w (gui-ui ui)))
        ]
  )
)

(define (guiDraw w ui)
    (ui w)
)

  
(define (spritePath sprite)
  (cond [(sprite? sprite)
            (string-append assets "sprites/" (sprite-name sprite) "/")]
  )
)

(define (spriteDraw w sprite)
  
   (addOneCount)

   (cond [(equal? debug #t)
            (writeln (string-append "Count: " (number->string count)))
            (writeln (string-append "W: " (number->string w)))
         ]
   )
   
   (cond [(= count (sprite-frames sprite)) (setZeroCount)])
   
   (cond [(and (string? (sprite-path sprite)) (not (equal? (sprite-path sprite) "")))
         (bitmap/file (string-append (sprite-path sprite) (number->string count) (sprite-ext sprite)))
         ]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Mouse Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (interactions w x y me)
  (writeln x)
  (writeln y)
  
  
  (cond [(and (timelapse w 241 360) (equal? me "button-down")) 361]
        [else w]
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Keyboard Event Handlers ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (keyboard w key)

   (writeln (string-append "Key: " key))

   (cond
      [(key=? key "left") startFrame]
      [(key=? key "right") endFrame]
      [(and  (key=? key "s") (not (timelapse w 361 600))) 0]

       
      [(and (key=? key "\r") (timelapse w 361 600) ) 601]
      [(and (and  (key=? key "\b") (timelapse w 361 600)) (not (equal? petName "")))
                 (set! petName (substring petName 0 (sub1 (string-length petName))))
                 (writeln (string-append "Key: " key))
                 (writeln (string-append "String: " (string-titlecase petName)))
                 w
      ]
      [(and (not (key=? key "shift"))(not (key=? key "\b")))
                 (set! petName (string-append petName key))
                 (writeln (string-append "Key: " key))
                 (writeln (string-append "String: " (string-titlecase petName)))
                 w
      ]
      [else w]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gameplay w)
   (cond [(timelapse w 0 120)(render w intro)]
         [(timelapse w 121 240)(render w title)]
         [(timelapse w 241 360) (render w menu)]
         [(timelapse w 361 600) (render w rename)]
         [(timelapse w 601 720) (render w idleState)]
         [else (render w menu)]
   )
)       

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (engine w)
  
   (define (goto w a)
      (- w (- w a))
   )

   (define (start w)
      (+ w 1)
   )
  
   (define (pause)
      w
   )

   (start w)

   (cond [(= w 241) (pause)]
         [(= w 361) (pause)]
         [(= w 601) (pause)]
         [else (start w)]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Main ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(big-bang 0
  (on-tick engine (framerate)) ; Framelimit
  (to-draw gameplay screenWidth screenHeight)
  (on-mouse interactions)
  ;(stop-when stop)
  (state #f)
  (on-key keyboard)
  (name "PandaSushi")
)

(keyboard 0 "s")
