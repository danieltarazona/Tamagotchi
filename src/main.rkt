#lang racket


(require 2htdp/universe)
(require 2htdp/image)
;(require test-engine/racket-tests)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Global Variables ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define screenHeight 432) ;True 16:9
(define screenWidth 768) ;True 16:9
(define fps 60)
(define totalFrames 30000)
(define assets "assets/")
(define background (rectangle 768 432 "solid" "white"))
(define showGrid #f)
(define gridX 12)
(define gridY 9)
(define centerPoint (circle 5 "solid" "blue"))

(define actualGUI "Main")
(define actualSprite "Main")
(define startFrame 0)
(define endFrame 0)
(define count 0)
(define search 0)

(define debug #f)
(define showFrames #t)
(define showFPS #t)
(define showSpriteName #t)
(define showGUIName #t)
(define showTimeline #t)

(define petName "Panda")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(struct posn (x y))
(struct gui (name x y frames ui) #:transparent)
(struct sprite (name [path #:mutable] x y frames ext) #:transparent)
(struct button (name img x y width height) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Buttons ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define foodImage (bitmap/file (string-append assets "img/ui/food.png")))
(define gameImage (bitmap/file (string-append assets "img/ui/game.png")))
(define songImage (bitmap/file (string-append assets "img/ui/song.png")))
(define healImage (bitmap/file (string-append assets "img/ui/heal.png")))
(define washImage (bitmap/file (string-append assets "img/ui/wash.png")))

(define eatButton (button "eat" foodImage 0 0 75 75))
(define gameButton (button "game" gameImage 0 0 75 75))
(define listenButton (button "listen" songImage 0 0 75 75))
(define healButton (button "heal" healImage 0 0 75 75))
(define washButton (button "wash" washImage 0 0 75 75))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Debugging Tools ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (onOffDebug)
   (cond [(equal? debug #t) (set! debug #f)]
         [(equal? debug #f) (set! debug #t)]
   )
)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; GRID ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gridSizeX)
   (/ screenWidth gridX)
)

(define (gridSizeY)
   (/ screenHeight gridY)
)

(define (midGridSizeX)
   (/ (gridSizeX) 2)
)

(define (midGridSizeY)
   (/ (gridSizeY) 2)
)

(define (drawGrid)
  (define rectX (rectangle (gridSizeX) screenHeight "outline" "red"))
  (define rectY (rectangle screenWidth (gridSizeY) "outline" "red"))
  (overlay/xy
   (overlay/xy
    (beside rectX rectX rectX rectX rectX rectX rectX rectX rectX rectX rectX rectX)
    0 0
    (above rectY rectY rectY rectY rectY rectY rectY rectY rectY)
    )
   (alignScreenCenterX centerPoint) (alignScreenCenterY centerPoint) centerPoint)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; GRID Helper Functions ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (screenZeroX) 0)
(define (screenZeroY) 0)

(define (screenCenterX)
  (/ screenWidth 2)
)

(define (screenCenterY)
  (/ screenHeight 2)
)

(define (alignScreenCenterX img)
  (- (/ screenWidth 2) (/ (image-width img) 2))
)

(define (alignScreenCenterY img)
  (- (/ screenHeight 2) (/ (image-height img) 2))
)

(define (screenLeftX img)
  (+ 0 (/ (image-width img) 2))
)

(define (screenRightX img)
  (- screenWidth (/ (image-width img) 2))
)

(define screenTopY
  (lambda (img [offset 0])
    (+ (* (gridSizeY) offset) (+ 0 (/ (image-height img) 2))))
)

(define (screenBottomY [x 0])
    (cond [(image? x) (- screenHeight (/ (image-height x) 2))]
          [(number? x) (- screenHeight x)]
          [else screenHeight]
          )
  
)

(define (offsetY y)
  (* (gridSizeY) y)
)


(define (offsetX x)
  (* (gridSizeX) x)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (debugUI w)
  
  (above (if showFrames
             (text (string-append "Frame: " (number->string w)) 12 "black")
                (text "" 10 "black"))
         (if showGUIName
             (text (string-append "GUI: " actualGUI) 12 "black")
                (text "" 10 "black"))
         (if showSpriteName
             (text (string-append "Sprite: " actualSprite) 12 "black")
                (text "" 10 "black"))
         (if showFPS
             (text (string-append "FPS: " (number->string fps)) 12 "black")
                (text "" 10 "black"))
         (text (string-append "Count: " (number->string count)) 12 "black")
         (text (string-append "Start: " (number->string startFrame)) 12 "black")
         (text (string-append "End: " (number->string endFrame)) 12 "black")
  )         
)

(define (introUI w)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (titleUI w)
  (above (text "Tamagotchi" 60 "purple")
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

(define (actionsUI w)
  (beside (rectangle 75 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; States ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define idleState  (sprite "idle" ""  (screenCenterX) (screenCenterY) 120 ".png"))
(define emptyState (sprite "empty" "" (screenCenterX) (screenCenterY) 1   ".png"))
(define eggState   (sprite "egg" ""   (screenCenterX) (screenCenterY) 120 ".png"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; GUI Structs ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define intro   (gui "intro"   (screenCenterX) (screenCenterY) 120 introUI))
(define title   (gui "title"   (screenCenterX) (screenCenterY) 120 titleUI))
(define menu    (gui "menu"    (screenCenterX) (screenCenterY) 120 menuUI))
(define rename  (gui "name"    (screenCenterX) (screenCenterY) 120 nameUI))
(define actions (gui "actions" (screenCenterX) (screenBottomY) 120 actionsUI))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (startEndFrames w ui)

  (cond [(equal? debug #t) (writeln startFrame)])
  
  (cond [(= w endFrame) (set! startFrame w)]
        [(gui? ui) (set! endFrame (+ startFrame (gui-frames ui)))]
        [(sprite? ui) (set! endFrame (+ startFrame (sprite-frames ui)))]
  )
)

(define (spritePath sprite)
  (cond [(sprite? sprite)
            (string-append assets "sprites/" (sprite-name sprite) "/")]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Draw Functions GUI ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (drawBackground w img)
  img
)

(define (drawTimeline w)
  (place-image (isosceles-triangle 15 -15 "solid" "red")
               w screenHeight
               (rectangle 768 15 "outline" "black")
  )
)

(define (drawGui w ui)
   (ui w)
)

(define (drawSprite w sprite)
  
   (addOneCount)
   (startEndFrames w sprite)
   (set-sprite-path! sprite (spritePath sprite))
   (set! actualSprite (sprite-name sprite))

   (cond [(equal? debug #t)
            (writeln (string-append "Count: " (number->string count)))
            (writeln (string-append "Frame: " (number->string w)))
         ]
   )
   
   (cond [(= count (sprite-frames sprite)) (setZeroCount)])
   
   (cond [(and (string? (sprite-path sprite)) (not (equal? (sprite-path sprite) "")))
         (bitmap/file (string-append (sprite-path sprite) (number->string count) (sprite-ext sprite)))
         ]
   )
)

(define (render w gui sprite)

   (cond [(equal? debug #t)  
                ;Img                             ;X                           ;Y
   (place-image (frame (drawGrid))               (screenCenterX)             (screenCenterY)                ;Grid Layer
   (place-image (frame (debugUI w))              (screenRightX (debugUI w))  (screenTopY (debugUI w) 0)     ; Debug Layer
   (place-image (frame (drawTimeline w))         (screenCenterX)             (screenTopY (drawTimeline w) 8); Timeline Layer
   (place-image (frame (drawGui w (gui-ui gui))) (gui-x gui)                 (gui-y gui)                    ; GUI Layer
   (place-image (frame (drawSprite w sprite))    (sprite-x sprite)           (sprite-y sprite)              ; Sprite Layer
                                                 (drawBackground w background))))))                         ; Background Layer
         ][(equal? debug #f)
   (place-image (drawGui w (gui-ui gui))         (gui-x gui)                 (gui-y gui)                    ; GUI Layer
   (place-image (drawSprite w sprite)            (sprite-x sprite)           (sprite-y sprite)              ; Sprite Layer 
                                                 (drawBackground w background)))
   ])
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gameplay w)
  
   (cond [(timelapse w 0 120)(render w intro emptyState)]
         [(timelapse w 121 240)(render w title emptyState)]
         [(timelapse w 241 360) (render w menu emptyState)]
         [(timelapse w 361 600) (render w rename emptyState)]
         [(timelapse w 601 720) (render w actions idleState)]
         [else (render w menu emptyState)]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Mouse Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (interactions w x y me)
  (cond [(equal? debug #t) (writeln x) (writeln y)]) 
  
  (cond [(and (timelapse w 241 360) (equal? me "button-down")) 361]
        [else w]
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Keyboard Event Handlers ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (keyboard w key)

   (cond [(equal? debug #t) (writeln (string-append "Key: " key))])
  
   (cond
      [(key=? key "left") startFrame]
      [(key=? key "right") endFrame]
      [(key=? key "f8") (onOffDebug) w]
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
