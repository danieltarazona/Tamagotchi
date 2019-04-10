#lang racket

(require 2htdp/universe)
(require 2htdp/image)
(require 2htdp/image
         (only-in racket/gui/base play-sound))


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
(define life 0)
(define countGUI 0)
(define count 0)
(define search 0)
(define play 0)
(define musicPlayer #f)
(define pixelate #t)

(define debug #f)
(define showFrames #t)
(define showFPS #t)
(define showSpriteName #t)
(define showGUIName #t)
(define showTimeline #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Game Variables ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define petname "Panda")

(define-struct pet ([name #:mutable] stats))

(define statFood   5)
(define statWash   5)
(define statGame   5)
(define statHeal   5)
(define statListen 5)
(define statHappy  10)

(define stats (vector statFood statWash statGame statHeal statListen statHappy))

(define panda (make-pet petname stats))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct posn (x y))
(define-struct button (name img x y width height) #:transparent)

(define-struct gui (name x y state [frames #:mutable] time ui) #:transparent)

(define-struct sprite (name
                       x y
                      [path   #:mutable] 
                      [frames #:mutable]
                       ext)   #:transparent)

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
;;;;;;;;;;;;;; States ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define emptyState  (sprite "Empty"  (screenCenterX) (screenCenterY) "" 1    ".png"))
(define idleState   (sprite "Idle"   (screenCenterX) (screenCenterY) "" 120  ".png"))
(define eatState    (sprite "Eat"    (screenCenterX) (screenCenterY) "" 120  ".png"))
(define listenState (sprite "Listen" (screenCenterX) (screenCenterY) "" 420  ".png"))
(define eggState    (sprite "Egg"    (screenCenterX) (screenCenterY) "" 120  ".png"))
(define healState   (sprite "Heal"   (screenCenterX) (screenCenterY) "" 120  ".png"))

(define gameState   (sprite "Game"   (screenCenterX) (screenCenterY) "" 120  ".png"))
(define washState   (sprite "Wash"   (screenCenterX) (screenCenterY) "" 120  ".png"))
(define dedState    (sprite "Ded"    (screenCenterX) (screenCenterY) "" 120  ".png"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Messages ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define sadMessage    (sprite "SadCloud"    (screenCenterX) (screenCenterY) "" 1    ".png"))
(define happyMessage  (sprite "HappyCloud"  (screenCenterX) (screenCenterY) "" 120  ".png"))
(define hungryMessage (sprite "HungryCloud" (screenCenterX) (screenCenterY) "" 120  ".png"))
(define sickMessage   (sprite "SickCloud"   (screenCenterX) (screenCenterY) "" 120  ".png"))
(define dirtyMessage  (sprite "DirtyCloud"  (screenCenterX) (screenCenterY) "" 120  ".png"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Buttons ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (getButtonImage buttonName)
       (bitmap/file (string-append assets "img/ui/" buttonName ".png"))
)

(define eatButton    (button "Eat"    (getButtonImage "eat")     0 0 75 75))
(define gameButton   (button "Game"   (getButtonImage "game")    0 0 75 75))
(define listenButton (button "Listen" (getButtonImage "listen")  0 0 75 75))
(define healButton   (button "Heal"   (getButtonImage "heal")    0 0 75 75))
(define washButton   (button "Wash"   (getButtonImage "wash")    0 0 75 75))
(define sleepButton  (button "Sleep"  (getButtonImage "sleep")   0 0 75 75))

(define newGameButton  (button "New Game"
                               (underlay/xy (text "New Game" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 0 0 100 50))

(define continueButton (button "Continue"
                               (underlay/xy (text "Continue" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 0 0 100 50))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (debugUI w)
  
  (above (text (string-append "CountSprite: " (number->string count))     12 "black")
         (text (string-append "Frames: "      (number->string countGUI))  12 "black")
         (if showGUIName
             (text (string-append "GUI: "     (gui-name actualGUI))       12 "black")
                (text "" 10 "black"))
         (if showSpriteName
             (text (string-append "Sprite: "  (sprite-name actualSprite)) 12 "black")
                (text "" 10 "black"))
         (if showFPS
             (text (string-append "FPS: "     (number->string fps))       12 "black")
                (text "" 10 "black"))
         (if showFrames
             (text (string-append "State: "   (number->string w))         12 "black")
                (text "" 10 "black"))    
  )         
)

(define (introUI w)
  (above (text "Valentina" 40 "purple")
         (text "Santiago" 40 "purple")
         (text "Daniel" 40 "purple")
  )
)

(define (titleUI w)
  (set! background (rectangle 768 432 "solid" "black"))
  (cond [(equal? pixelate #t)
            (bitmap/file (string-append assets "/img/background/title-pixel.png"))]
           [else (bitmap/file (string-append assets "/img/background/title.png"))]
  )
)

(define (menuUI w)
  (set! background (rectangle 768 432 "solid" "white"))
  (overlay/offset
     (cond [(equal? pixelate #t)
            (scale 0.75 (bitmap/file (string-append assets "/img/background/title-pixel.png")))]
           [else (scale 0.75 (bitmap/file (string-append assets "/img/background/title.png"))) ]
     )
     0 150
     (overlay/offset
         (button-img newGameButton)
         0 75
         (button-img continueButton)
     )
  )
)

(define (birthUI w)
  (set! background (rectangle 768 432 "solid" "white"))
  (overlay/offset
     (button-img continueButton) 0 -200 (rectangle 0 0 "outline" "white")
  )
)

(define (renameUI w)
  (above (text "Ingresa el nombre de tu mascota: " 16 'black)
         (text (pet-name panda) 24 'black)
  )
)

(define (actionsUI w)
  (overlay/offset
      (overlay/xy
        (overlay/xy
           (overlay/xy
              (overlay/xy
                (overlay/xy
                (overlay/xy  (text
                                (string-append "Food "
                                   (number->string (vector-ref (pet-stats panda) 0)) "/5")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 20 (vector-ref (pet-stats panda) 0))  20 "solid" "red") 0 0
                                        (rectangle 100  20 "outline" "black")))
                110 0
                (overlay/xy  (text
                                (string-append "Clean "
                                   (number->string (vector-ref (pet-stats panda) 1)) "/5")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 20 (vector-ref (pet-stats panda) 1))  20 "solid" "red") 0 0
                                        (rectangle 100  20 "outline" "black"))))
                220 0
                (overlay/xy  (text
                                (string-append "Game "
                                   (number->string (vector-ref (pet-stats panda) 2)) "/5")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 20 (vector-ref (pet-stats panda) 2))  20 "solid" "red") 0 0
                                        (rectangle 100  20 "outline" "black"))))
                330 0
                (overlay/xy  (text
                                (string-append "Heal "
                                   (number->string (vector-ref (pet-stats panda) 3)) "/5")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 20 (vector-ref (pet-stats panda) 3))  20 "solid" "red") 0 0
                                        (rectangle 100  20 "outline" "black"))))
                 440 0
                (overlay/xy  (text
                                (string-append "Listen "
                                   (number->string (vector-ref (pet-stats panda) 4)) "/5")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 20 (vector-ref (pet-stats panda) 4))  20 "solid" "red") 0 0
                                        (rectangle 100  20 "outline" "black"))))
                 550 0
                 (overlay/xy (text
                                (string-append "Happy "
                                   (number->string (vector-ref (pet-stats panda) 5)) "/10")
                                12 "black") -25 0
                             (overlay/xy (rectangle (* 10 (vector-ref (pet-stats panda) 5))  20 "solid" "red") 0 0
                                         (rectangle 100  20 "outline" "black"))))
    0 350
   (overlay/xy
   (overlay/xy 
   (overlay/xy 
   (overlay/xy 
   (overlay/xy (button-img gameButton)
               110 0
               (button-img eatButton))
               220 0
               (button-img listenButton))
               330 0
               (button-img healButton))
               440 0
               (button-img washButton))
               550 0
               (button-img sleepButton))
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; GUIs ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define intro   (gui "Intro"   (screenCenterX) (screenCenterY)  0 680 "next"  introUI))
(define title   (gui "Title"   (screenCenterX) (screenCenterY)  1 300 "next"  titleUI))
(define menu    (gui "Menu"    (screenCenterX) (screenCenterY)  2 300 "pause" menuUI))
(define rename  (gui "Rename"  (screenCenterX) (screenCenterY)  3 600 "pause" renameUI))
(define birth   (gui "Birth"   (screenCenterX) (screenCenterY)  4 600 "pause"  birthUI))
(define actions (gui "Actions" (screenCenterX) (screenCenterY)  5 600 "pause" actionsUI))

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

(define (addOneCountGUI)
  (set! countGUI (+ 1 countGUI))
)

(define (setZeroCount)
  (set! count 0)
)

(define (setZeroCountGUI)
  (set! countGUI 0)
)

(define (goTo x)
  (cond [(gui? x) (gui-state x)])
)

(define (nextState w x)
  (+ w 1)
)

(define (isSprite? [x "Main"])
  (cond [(symbol? x)(equal? actualSprite x) #t]
        [(and (sprite? x)(equal? actualSprite (sprite-name x))) #t]
        [else #f]
  )
)

(define (isGUI? w gui)
  (cond [(= w (gui-state gui)) #t]
        [else #f])
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Helper Functions GUI ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (onOffPixelate)
   (cond [(equal? pixelate #t) (set! pixelate #f)]
         [else (set! pixelate #t)]
   )
)

(define (spritePath sprite)
  (cond [(and (sprite? sprite) (equal? pixelate #f))
            (string-append assets "sprites/" (string-downcase (sprite-name sprite)) "/")]
        [else (string-append assets "sprites/" (string-downcase (sprite-name sprite)) "/pixelart/")]
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

(define (drawNotification w)
  (place-image (isosceles-triangle 15 -15 "solid" "red")
               w screenHeight
               (rectangle 768 15 "outline" "black")
  )
)

(define (drawGui w gui)
   (addOneCountGUI)
   (cond [(empty? gui) empty-image]
         [else (gui w)]
   )
)

(define (drawSprite w sprite)
  (cond [(equal? (sprite-name sprite) "Empty") empty-image]
        [else (set-sprite-path! sprite (spritePath sprite))
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
        ]
   )
)

(define (render w gui sprite [message emptyState])

   (set! actualGUI gui)
   (set! actualSprite sprite)

   (cond [(equal? debug #t)  
                ;Img                             ;X                           ;Y
   (place-image (frame (drawGrid))               (screenCenterX)             (screenCenterY)    ; Grid Layer
   (place-image (frame (debugUI w))              (screenRightX (debugUI w))  (screenOffsetY 1)  ; Debug Layer
   (place-image (frame (drawTimeline w))         (screenCenterX)             (screenOffsetY 8)  ; Timeline Layer
   (place-image (frame (drawGui w (gui-ui gui))) (gui-x gui)                 (gui-y gui)        ; GUI Layer
   (place-image (frame (drawSprite w message))   (sprite-x message)          (sprite-y message) ; Notification Layer
   (place-image (frame (drawSprite w sprite))    (sprite-x sprite)           (sprite-y sprite)  ; Sprite Layer
                                                 (drawBackground w background)))))))            ; Background Layer
         ][(equal? debug #f)
   (place-image (drawGui w (gui-ui gui))         (gui-x gui)                 (gui-y gui)        ; GUI Layer
   (place-image (drawSprite w message)           (sprite-x message)          (sprite-y message) ; Notification Layer
   (place-image (drawSprite w sprite)            (sprite-x sprite)           (sprite-y sprite)  ; Sprite Layer 
                                                 (drawBackground w background))))
   ])
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (onOffMusicPlayer)
   (cond [(equal? musicPlayer #t) (set! musicPlayer #f)]
         [else (set! musicPlayer #t)]
   )
)

(define (gameplay w)
  
  (cond [(and (= w 0) (equal? musicPlayer #f))
           (play-sound (string->path (string-append (path->string (current-directory)) "assets/mp3/epic.mp3")) #t)
           (set! musicPlayer #t)]
        [(= w 0) (render w intro   emptyState)]
  )

  (cond [(= w 2) (onOffMusicPlayer) (render w menu emptyState)])

  (cond [(and (= w 7) (equal? musicPlayer #f))
           (play-sound (string->path (string-append (path->string (current-directory)) "assets/mp3/panda.mp3")) #t)
           (set! musicPlayer #t)]
        [(= w 7) (render w actions listenState)]
  )
           
  (cond [(= w 1) (render w title   emptyState)]
        [(= w 3) (render w rename  emptyState)]
        [(= w 4) (render w birth   eggState)]
        [(= w 5) (render w actions idleState)]
        [(= w 6) (render w actions eatState)]
        [else    (render w actions idleState)]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Mouse Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (isInside? x y button)
              
  (cond [(and (and
             (>= x (- (pinhole-x (center-pinhole (button-img button))) (/ (button-width button) 2)))
             (<= x (+ (- (pinhole-x (center-pinhole (button-img button))) (/ (button-width button) 2)) (button-width button)))
         )   (and
             (>= y (- (pinhole-y (center-pinhole (button-img button))) (/ (button-height button) 2)))
             (<= y (+ (- (pinhole-y (center-pinhole (button-img button))) (/ (button-height button) 2)) (button-height button)))
             )
         )
         #t]
        [else #f]
   )
)

(define (click me)
  
   (cond [(equal? me "button-down") #t]
         [else #t])
)

(define (mouse w x y me)

  (cond [(equal? debug #t)
         (writeln (string-append  "ME:" me))
         (writeln (string-append  "X:" (number->string x) " Y:" (number->string y)))
        ])

  ;(cond [(and (and (isGUI? w menu) (isInside? x y newGameButton)) (click me)) (goTo w rename)])
 
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Keyboard Event Handlers ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (keyboard w key)

  (cond [(equal? debug #t) (writeln (string-append "Key: " key))])


  (cond [(isGUI? w rename)
         (cond [(and  (key=? key "\b")) (not (equal? (pet-name panda) ""))
            (set-pet-name! panda
                           (substring (pet-name panda) 0 (sub1 (string-length (pet-name panda)))))]
        [(and (not (key=? key "shift"))
              (not (key=? key "\b"))
              (not (key=? key "left"))
              (not (key=? key "right")))
            (set-pet-name! panda
                           (string-append (pet-name panda) key))]
        [else w]
  )])

  (cond [(key=? key "left" ) (- w 1)]
        [(key=? key "right") (+ w 1)]
        [(key=? key "c") 6]
        [(key=? key "m") (onOffMusicPlayer) 7]
        [(key=? key "p") (onOffPixelate) w]

        [(key=? key "f5"   ) 0]
        [(key=? key "f8"   ) (onOffDebug) w]

        [(key=? key "\r"   ) (+ w 1)]
        [else w]
  )    
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (engine w)
  
   (define (next w)
     (+ w 1)
   )

   (define (pause w)
     w
   )

   (cond [(= (gui-frames actualGUI) countGUI) 
          (cond [(equal? (gui-time actualGUI) "next" ) (setZeroCountGUI) (next w)]
                [(equal? (gui-time actualGUI) "pause") (setZeroCountGUI) (pause w)]
          )
         ]
         [else w]
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
