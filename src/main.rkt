#lang racket

(require 2htdp/universe)
(require 2htdp/image)

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

(define actualGUI empty)
(define actualSprite empty)
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
;;;;;;;;;; Debugging Tools ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (onOffDebug)
   (cond [(equal? debug #t) (set! debug #f)]
         [else (set! debug #t)]
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

(define (screenTopY img)
   (cond  [(image? img) (/ (image-height img) 2)])
)

(define (screenBottomY [x 0])
    (cond [(image? x) (- screenHeight (/ (image-height x) 2))]
          [(number? x) (- screenHeight x)]
          [else screenHeight]
          )
)

(define (screenOffsetY y)
  (* (gridSizeY) y)
)

(define (screenOffsetX x)
  (* (gridSizeX) x)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct posn (x y))
(define-struct button (name img x y width height) #:transparent)

(define-struct gui    (name
                       x y
                      [start  #:mutable]                   
                      [end    #:mutable]
                       ui)    #:transparent)

(define-struct sprite (name
                       x y
                      [path   #:mutable] 
                      [frames #:mutable]
                       ext)   #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; States ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define idleState  (sprite "Idle"  (screenCenterX) (screenCenterY) "" 120  ".png"))
(define emptyState (sprite "Empty" (screenCenterX) (screenCenterY) "" 1    ".png"))
(define eggState   (sprite "Egg"   (screenCenterX) (screenCenterY) "" 120  ".png"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Buttons ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define foodImage (bitmap/file (string-append assets "img/ui/food.png")))
(define gameImage (bitmap/file (string-append assets "img/ui/game.png")))
(define songImage (bitmap/file (string-append assets "img/ui/song.png")))
(define healImage (bitmap/file (string-append assets "img/ui/heal.png")))
(define washImage (bitmap/file (string-append assets "img/ui/wash.png")))

(define eatButton    (button "eat"    foodImage 0 0 75 75))
(define gameButton   (button "game"   gameImage 0 0 75 75))
(define listenButton (button "listen" songImage 0 0 75 75))
(define healButton   (button "heal"   healImage 0 0 75 75))
(define washButton   (button "wash"   washImage 0 0 75 75))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (debugUI w)
  
  (above (if showFrames
             (text (string-append "Frame: " (number->string w)) 12 "black")
                (text "" 10 "black"))
         (if showGUIName
             (text (string-append "GUI: " (gui-name actualGUI)) 12 "black")
                (text "" 10 "black"))
         (if showSpriteName
             (text (string-append "Sprite: " (sprite-name actualSprite)) 12 "black")
                (text "" 10 "black"))
         (if showFPS
             (text (string-append "FPS: " (number->string fps)) 12 "black")
                (text "" 10 "black"))
         (text (string-append "Count: " (number->string count)) 12 "black")
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

(define (renameUI w)
  (above (text "Ingresa el nombre" 16 'black)
         (text petName 24 'black)
  )
)

(define (actionsUI w)
  (overlay/offset
   (overlay/xy 
   (overlay/xy 
   (overlay/xy 
   (overlay/xy (rectangle 100 20 "outline" "black")
               110 0
               (rectangle 100  20 "outline" "black"))
               220 0
               (rectangle 100  20 "outline" "black"))
               330 0
               (rectangle 100  20 "outline" "black"))
               440 0
               (rectangle 100  20 "outline" "black"))
   0 350
   (beside (button-img gameButton)
           (button-img eatButton)
           (button-img listenButton)
           (button-img healButton)
           (button-img washButton)
           )
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; GUIs ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define intro   (gui "Intro"   (screenCenterX) (screenCenterY)   0    360  introUI))
(define title   (gui "Title"   (screenCenterX) (screenCenterY)   360  720  titleUI))
(define menu    (gui "Menu"    (screenCenterX) (screenCenterY)   720  1080 menuUI))
(define rename  (gui "Rename"  (screenCenterX) (screenCenterY)   1080 1360 renameUI))
(define actions (gui "Actions" (screenCenterX) (screenCenterY) 1360 1715 actionsUI))

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

(define (addOneCount)
  (set! count (+ 1 count))
)

(define (setZeroCount)
  (set! count 0)
)

(define (goTo w x)
  (cond [(gui? x)(gui-start x)])
)

(define (timelapse w x)
  (cond [(and (>= w (gui-start x)) (<= w (gui-end x)))  #t]  
        [else #f])
)

(define (isSprite? [x "Main"])
  (cond [(symbol? x)(equal? actualSprite x) #t]
        [(and (sprite? x)(equal? actualSprite (sprite-name x))) #t]
        [else #f]
  )
)

(define (isGUI? w x)
  (cond [(and (>= w (gui-start x)) (<= w (gui-end x)))  #t]  
        [else #f])
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
   (cond [(empty? ui) empty-image]
         [else (ui w)]
   )
)

(define (drawSprite w sprite)
  
   (cond [(equal? debug #t)
            (writeln (string-append "Count: " (number->string count)))
            (writeln (string-append "Frame: " (number->string w)))
         ]
   )
  
   (set-sprite-path! sprite (spritePath sprite))
  
   (cond [(= count (sprite-frames sprite)) (setZeroCount)])
   
   (cond [(and
           (< count (sprite-frames sprite))
           (string? (sprite-path sprite)) (not (equal? (sprite-path sprite) "")))
           (addOneCount)
           (bitmap/file
               (string-append (sprite-path sprite) (number->string count) (sprite-ext sprite))
           )
         ]
   )
)

(define (render w gui sprite)

   (set! actualGUI gui)
   (set! actualSprite sprite)

   (cond [(equal? debug #t)  
                ;Img                             ;X                           ;Y
   (place-image (frame (drawGrid))               (screenCenterX)             (screenCenterY)   ; Grid Layer
   (place-image (frame (debugUI w))              (screenRightX (debugUI w))  (screenOffsetY 1) ; Debug Layer
   (place-image (frame (drawTimeline w))         (screenCenterX)             (screenOffsetY 8) ; Timeline Layer
   (place-image (frame (drawGui w (gui-ui gui))) (gui-x gui)                 (gui-y gui)       ; GUI Layer
   (place-image (frame (drawSprite w sprite))    (sprite-x sprite)           (sprite-y sprite) ; Sprite Layer
                                                 (drawBackground w background))))))            ; Background Layer
         ][(equal? debug #f)
   (place-image (drawGui w (gui-ui gui))         (gui-x gui)                 (gui-y gui)       ; GUI Layer
   (place-image (drawSprite w sprite)            (sprite-x sprite)           (sprite-y sprite) ; Sprite Layer 
                                                 (drawBackground w background)))
   ])
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gameplay w)

    (cond [(timelapse w intro)     (render w intro emptyState)]
          [(timelapse w title)     (render w title emptyState)]
          [(timelapse w menu)      (render w menu emptyState)]
          [(timelapse w rename)    (render w rename emptyState)]
          [(timelapse w actions)   (render w actions idleState)]
          [else (render w actions idleState)]
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Mouse Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (isInside x y button)
  (cond [(or (and
             (>= x (button-x button))
             (<= x (+ (button-x button)(button-width button)))
         )   (and
             (>= y (button-y button))
             (<= y (+ (button-y button)(button-height button)))
             )
         )
         #t]
        [else #f]
   )
)

(define (mouse w x y me)
 
  (cond [(equal? debug #t) (writeln x) (writeln y)]) 
  
  (cond [(and (equal? actualGUI "Menu")
              (equal? me "button-down")) 361]
        [else w]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Keyboard Event Handlers ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (keyboard w key)

  (cond [(equal? debug #t) (writeln (string-append "Key: " key))])

  (cond [(key-event? key)

         (cond
           [(key=? key "left") (gui-start actualGUI)]
           [(key=? key "right") (gui-end actualGUI)]
    
           [(key=? key "f8") (onOffDebug) w]
           [(key=? key "f5") 0]

           [(and (key=? key "\r")(isGUI? w menu)) (goTo w rename)]
    
           [(timelapse w rename)
            (cond
              
              [(and (and  (key=? key "\b")) (not (equal? petName "")))
               (set! petName (substring petName 0 (sub1 (string-length petName))))
               (cond [(equal? debug #t)
                      (writeln (string-append "Key: " key))
                      (writeln (string-append "String: " (string-titlecase petName)))
                      ])
               w
               ]
              [(and (not (key=? key "shift")) (not (key=? key "\b")))
               (set! petName (string-append petName key))
               (cond [(equal? debug #t)
                      (writeln (string-append "Key: " key))
                      (writeln (string-append "String: " (string-titlecase petName)))
                      ])
               w
               ]) 
            ]
           [else w]
           )
         ]
        [else w]
        )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (engine w)

   (define (start w)
      (+ w 1)
   )
  
   (define (pause)
      w
   )

   (start w)

   (cond [(= w 721) (pause)]
         [else (start w)]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Main ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(big-bang 0
  (on-tick engine (framerate)) ; Framelimit
  (to-draw gameplay screenWidth screenHeight)
  ;(on-mouse mouse)
  ;(state #f)
  (on-key keyboard)
  (name "PandaSushi")
)
