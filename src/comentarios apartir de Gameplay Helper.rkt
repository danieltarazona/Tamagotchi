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
(define gridX 12)
(define gridY 9)
(define centerPoint (circle 5 "solid" "blue"))

(define actualGUI empty)
(define actualSprite empty)
(define lastAction empty)
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
(define showGrid #f)
(define showSpriteName #t)
(define showGUIName #t)
(define showTimeline #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Game Variables ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define petname "Panda")

(define-struct pet ([name #:mutable] stats))

(define eating    #f)
(define washing   #f)
(define gaming    #f)
(define healing   #f)
(define listening #f)
(define sleeping  #f)

(define totalEat    0)
(define totalWash   0)
(define totalGame   0)
(define totalHeal   0)
(define totalListen 0)

(define statEat     0)
(define statWash    0)
(define statGame    0)
(define statHeal    0)
(define statListen  0)
(define statHappy   0)

(define stats (vector statEat statWash statGame statHeal statListen statHappy))

(define panda (make-pet petname stats))

(define introSong
  (string->path (string-append (path->string (current-directory)) "assets/mp3/epic.mp3"))
)

(define listenSong
  (string->path (string-append (path->string (current-directory)) "assets/mp3/panda.mp3"))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Structs ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct button (name img x y width height) #:transparent)
(define-struct gui (name x y state [frames #:mutable] time ui) #:transparent)
(define-struct sprite (name x y [path   #:mutable] [frames #:mutable] state ext) #:transparent)

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
;;;;;;;;;;;;;; Buttons ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (getButtonImage buttonName)
       (bitmap/file (string-append assets "img/ui/" buttonName ".png"))
)

(define eatButton    (button "Eat"    (getButtonImage "eat")     110 345 50 50))
(define washButton   (button "Wash"   (getButtonImage "wash")    210 345 50 50))
(define gameButton   (button "Game"   (getButtonImage "game")    310 345 50 50))
(define healButton   (button "Heal"   (getButtonImage "heal")    410 345 50 50))
(define listenButton (button "Listen" (getButtonImage "listen")  510 345 50 50))
(define sleepButton  (button "Sleep"  (getButtonImage "sleep")   610 345 50 50))
(define wakeButton   (button "Wake"   (getButtonImage "wake")    340 170 100 100))

(define newGameButton  (button "New Game"
                               (underlay/xy (text "New Game" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 335 220 100 50))

(define continueButton (button "Continue"
                               (underlay/xy (text "Continue" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 335 295 100 50))

(define nextButton (button "Next"
                               (underlay/xy (text "Next" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 335 280 100 50))

(define backButton (button "Back"
                               (underlay/xy (text "Back to Menu" 15 "black") 0 0
                                            (rectangle 100 50 "outline" "black")) 335 345 100 50))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Interface ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (debugUI w)

  (above (if showGUIName
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
         (if musicPlayer
             (text "Music: On" 12 "black")
                (text "Music: Off" 12 "black"))
         (text (string-append "CountSprite: " (number->string count))       12 "black")
         (text (string-append "CountGUI: "    (number->string countGUI))    12 "black")
         (text (string-append "Lifetime: "    (number->string life))        12 "black")
         (text (string-append "TotalEat: "    (number->string totalEat))   12 "black")
         (text (string-append "TotalWash: "   (number->string totalWash))   12 "black")
         (text (string-append "TotalGame: "   (number->string totalGame))   12 "black")
         (text (string-append "TotalHeal: "   (number->string totalHeal))   12 "black")
         (text (string-append "TotalListen: " (number->string totalListen)) 12 "black")
         (if (not (empty? lastAction))
              (text (string-append "LastAction: " (sprite-name lastAction)) 12 "black")
                (text "" 10 "black"))

  )         
)

(define (introUI w)
  (above (text "Valentina" 40 "purple")
         (text "Santiago"  40 "purple")
         (text "Daniel"    40 "purple")
  )
)

(define (titleUI w)
  (set! background (rectangle 768 432 "solid" "white"))
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
     (button-img nextButton) 0 -200 (rectangle 0 0 "outline" "white")
  )
)

(define (sleepUI w)
  (set! background (rectangle 768 432 "solid" "black"))
  (scale 0.5 (button-img wakeButton))
)

(define (renameUI w)
  (overlay/offset
     (above (text "Ingresa el nombre de tu mascota: " 16 'black)
          (text (pet-name panda) 24 'black)
          )
     0 180
     (button-img nextButton)
  )
)

(define (buttonsUI w)
   (overlay/xy
   (overlay/xy 
   (overlay/xy 
   (overlay/xy 
   (overlay/xy (button-img eatButton)
               100 0
               (button-img washButton))
               200 0
               (button-img gameButton))
               300 0
               (button-img healButton))
               400 0
               (button-img listenButton))
               500 0
               (button-img sleepButton)
   )
)

(define (barsUI w)
  (overlay/xy
   (overlay/xy
    (overlay/xy
     (overlay/xy
      (overlay/xy
       (overlay/xy
        (text
         (string-append "Eat "
                        (number->string (vector-ref (pet-stats panda) 0)) "/10")
         12 "black") -25 0
                     (overlay/xy
                      (rectangle (* 10  (vector-ref  (pet-stats panda) 0))  20 "solid" "red")
                      0 0
                      (rectangle 100  20 "outline" "black"))
                     )
       110 0
       (overlay/xy
        (text
         (string-append "Clean "
                        (number->string (vector-ref (pet-stats panda) 1)) "/10")
         12 "black") -25 0
                     (overlay/xy
                      (rectangle (* 10 (vector-ref (pet-stats panda) 1))  20 "solid" "red")
                      0 0
                      (rectangle 100  20 "outline" "black"))
                     )
       )
      220 0
      (overlay/xy
       (text
        (string-append "Game "
                       (number->string (vector-ref (pet-stats panda) 2)) "/10")
        12 "black") -25 0
                    (overlay/xy
                     (rectangle (* 10 (vector-ref (pet-stats panda) 2))  20 "solid" "red")
                     0 0
                     (rectangle 100  20 "outline" "black"))
                    )
     )
     330 0
     (overlay/xy
      (text
       (string-append "Heal "
                      (number->string (vector-ref (pet-stats panda) 3)) "/10")
       12 "black") -25 0
                   (overlay/xy
                    (rectangle (* 10 (vector-ref (pet-stats panda) 3))  20 "solid" "red")
                    0 0
                    (rectangle 100  20 "outline" "black"))
                   )
      )

    440 0
    (overlay/xy
     (text
      (string-append "Listen "
         (number->string (vector-ref (pet-stats panda) 4)) "/10") 12 "black") -25 0
            (overlay/xy
               (rectangle (* 10 (vector-ref (pet-stats panda) 4))  20 "solid" "red")
                   0 0
                (rectangle 100  20 "outline" "black"))
    )
    )
   550 0
   (overlay/xy
    (text
     (string-append "Happy "
                    (number->string (vector-ref (pet-stats panda) 5)) "/10")
     12 "black") -25 0
                 (overlay/xy
                  (rectangle (* 10 (vector-ref (pet-stats panda) 5))  20 "solid" "red")
                  0 0
                  (rectangle 100  20 "outline" "black"))
                 )
   )
)

(define (actionsUI w)
   (set! background (rectangle 768 432 "solid" "white"))
   (overlay/offset (barsUI w) 0 320 (buttonsUI w))
)

(define (gameoverUI w)
  (set! background (rectangle 768 432 "solid" "white"))
  (overlay/offset (barsUI w) 0 210
                  (overlay/offset (text "GAME OVER" 15 "black") 0 240
                                  (button-img backButton)
                  )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; GUIs ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define intro    (gui "Intro"    (screenCenterX) (screenCenterY)    0   680 "next"   introUI))
(define title    (gui "Title"    (screenCenterX) (screenCenterY)    1   680 "next"   titleUI))
(define menu     (gui "Menu"     (screenCenterX) (screenCenterY)    2   120 "pause"  menuUI))
(define rename   (gui "Rename"   (screenCenterX) (screenCenterY)    3   120 "pause"  renameUI))
(define birth    (gui "Birth"    (screenCenterX) (screenCenterY)    4   120 "next"   birthUI))
(define sleep    (gui "Sleep"    (screenCenterX) (screenCenterY)    12  600 "pause"  sleepUI))
(define bars     (gui "Bars"     (screenCenterX) (screenOffsetY 1)  5   420 "idle"   barsUI))
(define actions  (gui "Actions"  (screenCenterX) (screenCenterY)    5   420 "pause"  actionsUI))
(define gameover (gui "GameOver" (screenCenterX) (screenCenterY)    11  120 "pause"  gameoverUI))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; States ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define eggState    (sprite "Egg"    (screenCenterX) (screenCenterY) "" 120 4  ".png"))
(define idleState   (sprite "Idle"   (screenCenterX) (screenCenterY) "" 120 5  ".png"))
(define eatState    (sprite "Eat"    (screenCenterX) (screenCenterY) "" 120 6  ".png"))
(define listenState (sprite "Listen" (screenCenterX) (screenCenterY) "" 420 7  ".png"))
(define healState   (sprite "Heal"   (screenCenterX) (screenCenterY) "" 120 8  ".png"))
(define gameState   (sprite "Game"   (screenCenterX) (screenCenterY) "" 180 9  ".png"))
(define washState   (sprite "Wash"   (screenCenterX) (screenCenterY) "" 240 10 ".png"))
(define deadState   (sprite "Dead"   (screenCenterX) (screenCenterY) "" 120 11 ".png"))
(define emptyState  (sprite "Empty"  (screenCenterX) (screenCenterY) "" 1   0 ".png"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Messages ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define sadMessage    (sprite "SadCloud"    (screenCenterX) (screenCenterY) "" 1   0 ".png"))
(define happyMessage  (sprite "HappyCloud"  (screenCenterX) (screenCenterY) "" 120 0 ".png"))
(define hungryMessage (sprite "HungryCloud" (screenCenterX) (screenCenterY) "" 120 0 ".png"))
(define sickMessage   (sprite "SickCloud"   (screenCenterX) (screenCenterY) "" 120 0 ".png"))
(define dirtyMessage  (sprite "DirtyCloud"  (screenCenterX) (screenCenterY) "" 120 0 ".png"))

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
  (set! count (+ count 1))
)

(define (addOneCountGUI)
  (set! countGUI (+ countGUI 1))
)

(define (lifetime)
  (set! life (+ life 1))
)

(define (setZeroCount)
  (set! count 0)
)

(define (setZeroCountGUI)
  (set! countGUI 0)
)

(define (setZeroLife)
  (set! life 0)
)

(define (restart)
   (setZeroCount)
   (setZeroCountGUI)
)

(define (goTo x)
  (cond [(gui? x) (gui-state x)])
)

(define (isSprite? w sprite)
  (cond [(= w (sprite-state sprite)) #t]
        [else #f])
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

(define (drawGUI w gui)
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
   (place-image
    (frame (drawGrid))               (screenCenterX)             (screenCenterY)    ; Grid Layer
   (place-image
    (frame (debugUI w))              (screenRightX (debugUI w))  (screenOffsetY 4)  ; Debug Layer
   (place-image
    (frame (drawTimeline w))         (screenCenterX)             (screenOffsetY 8)  ; Timeline
   (place-image
    (drawGUI w (gui-ui gui))         (gui-x gui)                 (gui-y gui)        ; GUI Layer
   (place-image
    (frame (drawSprite w sprite))    (sprite-x sprite)           (sprite-y sprite)  ; Sprite Layer
                                     (drawBackground w background))))))]           ; Background

   [(equal? debug #f)
   (place-image
      (drawGUI w (gui-ui gui)) (gui-x gui) (gui-y gui) ; GUI Layer
   (place-image
      (drawSprite w sprite) (sprite-x sprite) (sprite-y sprite) ; Sprite Layer 
         (drawBackground w background)))]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay Helper ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;------------------------------------------------------------------------------------------------------------
;Esta defincion posee como funcion encender el audio, en determinadas partes del video-juego.
(define (onMusicPlayer)
   (cond [(equal? musicPlayer #f) (set! musicPlayer #t)])
)
;------------------------------------------------------------------------------------------------------------
;Esta definicion posee como funcion apagar el audio, para asi hacer que este se detenga.
(define (offMusicPlayer)
   (cond [(equal? musicPlayer #t) (set! musicPlayer #f)])
)
;------------------------------------------------------------------------------------------------------------
;Esta definicion hace el cambio automatico, si esta apagado lo prende y si esta prendio, apaga el audio.
(define (onOffMusicPlayer)
   (cond [(equal? musicPlayer #f) (set! musicPlayer #t)]
         [else (set! musicPlayer #f)]
   )
)
;------------------------------------------------------------------------------------------------------------
;Contrato: stopSprite: num -> num

;Proposito: Esta funcion cumple con detener el sprite justo en el sprite antes del ingresado.

;Ejemplo:
;(stopSprite 120);119

;Cuerpo:
(define (stopSprite sprite)
   (cond [(>= countGUI (sprite-frames sprite))
          (set! count (- (sprite-frames sprite) 1))
         ]
   )
)
;------------------------------------------------------------------------------------------------------------
;Contrato: stopGUI: num -> num

;Proposito: Esta funcion cumple con detener la animacion del gui justo en el gui ingresado.

;Ejemplo:
;(stopGUI 320); 320

;Cuerpo:
(define (stopGUI gui)
   (cond [(>= countGUI (gui-frames gui))
          (set! countGUI (gui-frames gui))
         ]
   )
)
;------------------------------------------------------------------------------------------------------------
;Esta definicion cambia a cero (0) todas las estadisticas de la mascota.
(define (setZeroStats pet)
  (vector-set! (pet-stats pet) 0 0)
  (vector-set! (pet-stats pet) 1 0)
  (vector-set! (pet-stats pet) 2 0)
  (vector-set! (pet-stats pet) 3 0)
  (vector-set! (pet-stats pet) 4 0)
  (vector-set! (pet-stats pet) 5 0)
)
;-------------------------------------------------------------------------------------------------------------
;Contrato: isDead?: pet -> boolean
;Proposito: Esta funcion cumple con el fin de evaluar cuando la mascota esta muerta de acuerdo a sus estadisticas
;Cuerpo:
(define (isDead? pet)
   (cond [(and (= (vector-ref (pet-stats pet) 0) 0)
               (= (vector-ref (pet-stats pet) 1) 0)
               (= (vector-ref (pet-stats pet) 2) 0)
               (= (vector-ref (pet-stats pet) 3) 0)
               (= (vector-ref (pet-stats pet) 4) 0)
               (= (vector-ref (pet-stats pet) 5) 0)) #t]
         [else #f]
   )
)
;---------------------------------------------------------------------------------------------------------------
;Contrato: addStat: num num -> num

;Proposito: Esta funcion tiene como objetivo sumar un numero dado (x) a la posicion (pos) del vector que contiene
;las estadisticas de la mascota.

;Ejemplos:
;(addStat 0 1) ;Eat    +1
;(addStat 1 2) ;Wash   +2
;(addStat 2 1) ;Game   +1
;(addStat 3 1) ;Heal   +1
;(addStat 4 1) ;listen +1
;(addStat 5 1) ;Happy  +1

;Cuerpo:
(define (addStat pos x)
  (cond [(and (>= pos 0) (< pos 5) (= x 1) (<= (vector-ref (pet-stats panda) pos) 9))
         (vector-set! (pet-stats panda) pos (+ (vector-ref (pet-stats panda) pos) x))]

        [(and (>= pos 0) (< pos 5) (= x 2) (<= (vector-ref (pet-stats panda) pos) 8))
         (vector-set! (pet-stats panda) pos (+ (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= x 1) (<= (vector-ref (pet-stats panda) pos) 9))
         (vector-set! (pet-stats panda) pos (+ (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= x 2) (<= (vector-ref (pet-stats panda) pos) 8))
         (vector-set! (pet-stats panda) pos (+ (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= x 3) (<= (vector-ref (pet-stats panda) pos) 7))
         (vector-set! (pet-stats panda) pos (+ (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= (vector-ref (pet-stats panda) pos) 10))
         (vector-set! (pet-stats panda) pos 10)]
        )
)
;--------------------------------------------------------------------------------------------------------------
;Contrato: subStat: num num -> num

;Proposito: Esta funcion tiene como objetivo restar un numero dado (x) a la posicion (pos) del vector que contiene
;las estadisticas de la mascota.

;Ejemplos:
;(subStat 0 1) ;Eat    -1
;(subStat 1 2) ;Wash   -2
;(subStat 2 1) ;Game   -1
;(subStat 3 1) ;Heal   -1
;(subStat 4 1) ;listen -1
;(subStat 5 1) ;Happy  -1

;Cuerpo:
(define (subStat pos x)
  (cond [(and (>= pos 0) (< pos 5) (= x 2) (>= (vector-ref (pet-stats panda) pos) 1))
         (vector-set! (pet-stats panda) pos (- (vector-ref (pet-stats panda) pos) x))]

        [(and (>= pos 0) (< pos 5) (= x 1) (>= (vector-ref (pet-stats panda) pos) 1))
         (vector-set! (pet-stats panda) pos (- (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= x 1) (>= (vector-ref (pet-stats panda) pos) 4))
         (vector-set! (pet-stats panda) pos (- (vector-ref (pet-stats panda) 5) x))]

        [(and (= pos  5) (= x 2) (>= (vector-ref (pet-stats panda) pos) 5))
         (vector-set! (pet-stats panda) pos (- (vector-ref (pet-stats panda) pos) x))]

        [(and (= pos  5) (= (vector-ref (pet-stats panda) pos) 3))
         (vector-set! (pet-stats panda) pos 3)]
        )
)
;--------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Gameplay ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Contrato: gameplay: num -> scene

;Proposito: La funcion gameplay es la cual ejecuta todas las escenas posibles,dependiendo de unas condiciones
;que estan definidas dentro de la misma funcion. Esta recibe un  numero (w) y dependiendo de este numero
;genera una escena.

;Ejemplos:
;(gameplay 0); introScene
;(gameplay 1); titleScene
;(gameplay 2); menuScene
;(gameplay 3); renamescene
;(gameplay 4); eggScene
;(gameplay 5); idleScene
;(gameplay 6); eatScene
;(gameplay 7); listenScene
;(gameplay 8); healScene
;(gameplay 9); washScene
;(gameplay 10); gameScene
;(gameplay 11); deadScene
;(gameplay 12); sleepScene

;Cuerpo:        
(define (gameplay w)
 ;---------------------------------------------------------------------------------------------------
 ;Proposito: esta funcion tiene como objetivo restar uno (1) a cada estado del pandasushi
 ; despues de un tiempo determinado, y es usada cuando la mascota esta en estado de resposo (idleState).
  (define (lifeStats)
     (subStat 0 1)
     (subStat 1 1)
     (subStat 2 1)
     (subStat 3 1)
     (subStat 4 1)
     (subStat 5 1)
  )
 ;-----------------------------------------------------------------------------------------------------
 ;Proposito: esta funcion tiene como fin evaluar cuantas veces se ha hecho la misma accion (comer) de seguido
 ; y asi mismo ejecutar las condiciones que conlleva cada repeticion.
  (define (eatStats)
    (cond [(<= totalEat 3)
           (begin
             (set! totalEat (+ totalEat 1))
             (set! totalWash   0)
             (set! totalGame   0)
             (set! totalListen 0)
             (set! totalHeal   0))
          ]
    )
;Si come una vez, le suma uno (1) a Eat y Happy, mientras que le resta uno (1) al resto de estados.
    (cond [(= totalEat 1)
           (begin
             (addStat 0 1) ;Eat   +1
             (addStat 5 1) ;Happy +1
             (subStat 1 1) ;Wash  -1
             (subStat 3 1) ;Heal -1
             (subStat 2 1) ;Game -1
             (subStat 4 1) ;listen -1
           ) 
          ]
 ;Si come dos veces de seguido, tan solo se le añadira uno (1) a Eat.
          [(= totalEat 2)
           (addStat 0 1) ;Eat   +1
          ]
 ;Si come tres veces de seguido, le aumentara uno (1) en Eat mientras que le restara dos (2) a Happy, lo enferma y lo ensucia.
          [(= totalEat 3)
           (addStat 0 1) ;Eat   +1
           (subStat 5 2) ;Happy -2
           (subStat 3 (vector-ref stats 3)) ;Heal-all
           (subStat 1 (vector-ref stats 1)) ;Wash-all
          ]
     )
  )
;---------------------------------------------------------------------------------------------------------------
;Proposito: esta funcion tiene como fin evaluar cuantas veces se ha hecho la misma accion (bañar) de seguido
; y asi mismo ejecutar las condiciones que conlleva cada repeticion.
  (define (washStats)
     (cond [(= totalEat 3)(addStat 5 1)])

     (cond [(<= totalWash 3)
            (begin
              (set! totalWash (+ totalWash 1))
              (set! totalEat    0)
              (set! totalGame   0)
              (set! totalListen 0)
              (set! totalHeal   0)
            )
           ]
    )
;Si se manda al baño una vez, se le suma dos (2) a Wash y Happy mientras que se le resta
; uno (1) a cada uno de los otros estados.
     (cond [(= totalWash 1)
             (begin
               (addStat 1 2) ;Wash  +2
               (addStat 5 2) ;Happy +2
               (subStat 0 1) ;Eat  -1
               (subStat 3 1) ;Heal -1
               (subStat 2 1) ;Game -1
               (subStat 4 1) ;listen -1
             )
           ]
;Si se baña dos veces de seguido, no hace ningun cambio.
           [(= totalWash 2)
            (addStat 1 0) ;Wash  +0
           ]
;Si se baña tres veces de seguido, se le resta uno (1) a Wash y lo enferma.
           [(= totalWash 3)
            (begin
              (subStat 1 1) ;Wash  -1
              (subStat 3 (vector-ref stats 3));Heal-all
             ) 
           ]
     )
  )
;---------------------------------------------------------------------------------------------------------------------
;;Proposito: esta funcion tiene como fin evaluar cuantas veces se ha hecho la misma accion (jugar) de seguido
; y asi mismo ejecutar las condiciones que conlleva cada repeticion.
  (define (gameStats)
    (cond [(= totalEat 3)(subStat 5 2)])

    (cond [(<= totalGame 3)
           (begin
             (set! totalGame (+ totalGame 1))
             (set! totalEat    0)
             (set! totalWash   0)
             (set! totalListen 0)
             (set! totalHeal   0)
            )]
    )
;Si juega una vez, se le suma uno (1) a Game y dos (2) a Happy, mientras que se le resta uno (1) al resto de estados.
    (cond [(= totalGame 1)
           (begin
             (addStat 2 1) ;Game  +1 
             (addStat 5 2) ;Happy +2
             (subStat 1 1) ;Wash  -1
             (subStat 3 1) ;Heal -1
             (subStat 0 1) ;Eat -1
             (subStat 4 1) ;listen -1
           )
          ]
;Si juegan dos veces de seguido, se le suma uno (1) a Game, Heal, y Happy, mientras que se le resta uno (1) a Wash.
          [(= totalGame 2)
           (begin
             (addStat 2 1) ;Game  +1
             (addStat 3 1) ;Heal  +1
             (addStat 5 1) ;Happy +1
             (subStat 1 1) ;Wash  -1
           )
          ]
;Si juegan tres veces de seguido, se le suma uno (1) a Game y se le resta uno (1) a Wash y dos (2) a Eat.
          [(= totalGame 3)
           (begin
             (addStat 2 1) ;Game  +1
             (subStat 1 1) ;Wash  -1
             (subStat 0 2) ;Eat   -2
           )
          ]
          )
    )
;-------------------------------------------------------------------------------------------------------------------
;;Proposito: esta funcion tiene como fin evaluar cuantas veces se ha hecho la misma accion (curar) de seguido
; y asi mismo ejecutar las condiciones que conlleva cada repeticion.  
  (define (healStats)
    (cond [(= totalEat 3)(subStat 5 2)])

    (cond [(<= totalHeal 3)
           (set! totalHeal (+ totalHeal 1))
           (set! totalEat    0)
           (set! totalWash   0)
           (set! totalListen 0)
           (set! totalGame   0)
           (addStat 3 1) ;Heal  +1
           ]
    )
;Si se cura una vez, se suma uno (1) a Heal y tres (3) a Happy.
    (cond [(= totalHeal 1)
            (addStat 5 3) ;Happy +3
          ]
;No ocurre nada si se cura menos de tres veces de seguido.
    )
 )
;-----------------------------------------------------------------------------------------------------------------------
;;Proposito: esta funcion tiene como fin evaluar cuantas veces se ha hecho la misma accion (escuchar musica) de seguido
; y asi mismo ejecutar las condiciones que conlleva cada repeticion.
  (define (listenStats)
     (cond [(= totalEat 3)(subStat 5 2)])
     (cond [(<= totalListen 3)
            (set! totalListen (+ totalListen 1))
            (set! totalEat    0)
            (set! totalWash   0)
            (set! totalHeal   0)
            (set! totalGame   0)
           ]
     )
;Si escucha musica una vez, suma uno (1) a Listen y dos (2) a Happy, mientras que le resta uno (1) al resto de estados.
     (cond [(= totalListen 1)
            (begin
              (addStat 4 1) ;Listen +1
              (addStat 5 2) ;Happy  +2
              (subStat 1 1) ;Wash  -1
              (subStat 3 1) ;Heal -1
              (subStat 0 1) ;Eat -1
              (subStat 2 1) ;Game -1
             )
           ]
;Si se escucha musica dos veces seguidas, suma uno (1) a Listen y Happy.
           [(= totalListen 2)
            (begin
              (addStat 4 1) ;Listen +1
              (addStat 5 1) ;Happy  +1
             )
           ]
;Si se escucha musica tres veces seguidas, suma uno (1) a listen, le resta uno (1) a Happy y enferma a la mascota
           [(= totalListen 3)
            (begin
              (addStat 4 1) ;Listen +1
              (addStat 5 1) ;Happy  -1
              (subStat 3 (vector-ref (pet-stats panda) 3)) ;Heal -All
            )
           ]
     )
  )
;-------------------------------------------------------------------------------------------------------------------------
;;;Intro and Music;;;
  
;introScene, hace parte de la interfaz grafica del videojuego, es la primera escena que aparece y lo que hace es llamar
;a (render w intro emptystate) que es la encargada de dibujar, mientras enciende el audio elegido para la introduccion
;del videojuego.
  
(define (introScene)
     (cond [(equal? musicPlayer #f)
            (onMusicPlayer) 
            ;(play-sound introSong #t) ;funciona en Windows, linux paila.
        ]
     )
     (render w intro emptyState)
  )
;--------------------------------------------------------------------------------------------------------------------------
;;;Title;;;
  
;titleScene, es la segunda escena del videojuego y cumple con hacer el llamado de (render w title emptystate) que dibuja
;el titulo del juego.
  
(define (titleScene)
     (render w title emptyState)
  )
;---------------------------------------------------------------------------------------------------------------------------------------
;;;Menu;;;

;menuScene, es la tercera escena del videojuego y cumple con llamar a (render w menu emptyState) que dibuja el primer menu del juego,
;y detener el audio.
  
(define (menuScene)
     (cond [(equal? musicPlayer #t)
            (offMusicPlayer)
           ]
     )
     (render w menu emptyState)
  )
;----------------------------------------------------------------------------------------------------------------------------------------
;;;Rename;;;
  
;renameScene,es la cuarta escena del videojuego y cumple con llamar a (render w rename emptyState) que dibuja la opcion para que
; el usuario digite el nombre de su mascota.
  
(define (renameScene)
     (render w rename emptyState)
  )
;----------------------------------------------------------------------------------------------------------------------------------------
;;;EggState;;;

;eggScene, es la quinta escena y es la encargarda de otorgar los valores iniciales de las estadisticas de la mascota y llamar a
; (render w birth eggState) que a su vez, se encarga de dibujar esta escena.
  
(define (eggScene)
     (set-gui-frames! birth 240)
     (vector-set! (pet-stats panda) 0 3)
     (vector-set! (pet-stats panda) 1 3)
     (vector-set! (pet-stats panda) 2 3)
     (vector-set! (pet-stats panda) 3 3)
     (vector-set! (pet-stats panda) 4 3)
     (vector-set! (pet-stats panda) 5 3)
     (render w birth eggState)
  )
;----------------------------------------------------------------------------------------------------------------------------------------------
;;;IdleState and Lifetime;;;

;idleScene, es la encargada de generar la escena en la que se muestran todas las estadisticas de la mascota y tambien en esta se muestra
;todas las acciones que el usuario puede acceder. En si, esta es el estado de reposo.
  
(define (idleScene)
     (cond [(= life 18000) (lifeStats) (setZeroLife)])
     (cond [(isDead? panda)(deadScene)]
           [else (set! eating    #f)
                 (set! gaming    #f)
                 (set! washing   #f)
                 (set! healing   #f)
                 (set! listening #f)
                 (set! sleeping  #f)
                 (set-gui-frames! bars 120)
                 (set-gui-frames! actions 120)
                 (offMusicPlayer)
                 (lifetime)
                 (render w actions idleState)
           ]
     )
  )
;-------------------------------------------------------------------------------------------------------------------------------------------------
;;;EatState;;;

;eatScene, es la encargada de generar la escena en la que la mascota esta comiendo por ende pasa de estado de reposo (idleState) al estado de comida,
;tambien posee la condicion de que si se hace esta misma accion cuatro veces seguidas la mascota morira,
;y si es asi, se genera la escena donde la mascota muere.
  
(define (eatScene)
    (set-gui-frames! bars 240)
    (cond [(equal? eating #f) (eatStats) (set! eating #t)])

    (cond [(= totalEat 4) (deadScene)]
          [else (lifetime) (render w bars eatState)]
    )
  )
;-----------------------------------------------------------------------------------------------------------------------------------------------------
;;;WashState;;;

;washScene, es la encargada de generar la escena en la que la mascota se esta bañado por ende pasa de estado de reposo (idleState) al estado de baño,
;tambien posee la condicion de que si se hace esta misma accion cuatro veces seguidas la mascota morira,
; y si es asi, se genera la escena donde la mascota muere.
  
(define (washScene)
    (set-gui-frames! bars 420)
    (cond [(equal? washing #f) (washStats) (set! washing #t)])

    (cond [(= totalWash 4) (deadScene)]
          [else (lifetime) (render w bars washState)]
    )
  )
;---------------------------------------------------------------------------------------------------------------------------------------------------
;;;ListenState;;;

;listenScene, es la encargada de generar la escena en la que la mascota esta escuchando musica por ende pasa de estado de reposo
;(idleState) al estado de escuchar musica, tambien posee la condicion de que si se hace esta misma accion cuatro veces seguidas la mascota morira,
;y si es asi, se genera la escena donde la mascota muere.
  
(define (listenScene)
    (set-gui-frames! bars 420)

    (cond [(and (equal? eating #f) (equal? musicPlayer #f)) 
           (listenStats)
           (set! eating #t)
           (onMusicPlayer)
           ;(play-sound listenSong #t)
          ]
    )

    (cond [(= totalListen 4) (deadScene)]
          [else (lifetime)(render w bars listenState)]            
    ) 
  )
;--------------------------------------------------------------------------------------------------------------------------------------------
;;;GameState;;;

;gameScene, es la encargada de generar la escena en la que la mascota esta jugando por ende pasa de estado de reposo (idleState) al estado de jugar,
;tambien posee la condicion de que si se hace esta misma accion cuatro veces seguidas la mascota morira,
;y si es asi, se genera la escena donde la mascota muere.
  
(define (gameScene)
    (set-gui-frames! bars 420)
    (cond [(equal? gaming #f) (gameStats) (set! gaming #t)])

    (cond [(= totalGame 4) (deadScene)]
          [else (lifetime) (render w bars gameState)]
    )
  )
;---------------------------------------------------------------------------------------------------------------------------------------------
;;;HealState;;;

;healScene, es la encargada de generar la escena en la que la mascota se cura por ende pasa de estado de reposo (idleState) al estado de cura,
;tambien posee la condicion de que si se hace esta misma accion cuatro veces seguidas la mascota morira.
;y si es asi, se genera la escena donde la mascota muere.
  
  (define (healScene)
    (set-gui-frames! bars 240)
    (cond [(equal? healing #f) (healStats) (set! healing #t)])

    (cond [(= totalHeal 4) (deadScene)]
          [else (lifetime) (render w bars healState)]
    )
  )
;------------------------------------------------------------------------------------------------------------------------------------------------------
;;;SleepState;;;

;eatScene, es la encargada de generar la escena en la que la mascota esta durmiendo por ende pasa de estado de reposo (idleState) al estado de dormir.
  
(define (sleepScene)
    (cond [(equal? sleeping #f) (set! sleeping #t)])
    (lifetime)
    (render w sleep emptyState)
  )
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;;;DeadState;;;

;deadScene, es la encargada de generar la escena en la que la mascota muerde debido a ciertas condiciones antes especificadas.
  
(define (deadScene)
    (set-gui-frames! gameover 120)
    (setZeroStats panda)
    (stopGUI gameover)
    (stopSprite deadState)
    (render w gameover deadState)
  )
;--------------------------------------------------------------------------------------------------------------------------------------------------------
;;;Logic;;;

;estas son las series de condiciones que me comparan el dato de entrada (w) de la funcion, con el estado de cada una de las escenas y dependiendo de esto
;genera una u otra scena.
 
(cond   [(= w (gui-state    intro))       (introScene)]  ;0
        [(= w (gui-state    title))       (titleScene)]  ;1
        [(= w (gui-state    menu))        (menuScene)]   ;2
        [(= w (gui-state    rename))      (renameScene)] ;3
        [(= w (gui-state    birth))       (eggScene)]    ;4
        [(= w (sprite-state idleState))   (idleScene)]   ;5
        [(= w (sprite-state eatState))    (eatScene)]    ;6
        [(= w (sprite-state listenState)) (listenScene)] ;7
        [(= w (sprite-state healState))   (healScene)]   ;8
        [(= w (sprite-state washState))   (washScene)]   ;9
        [(= w (sprite-state gameState))   (gameScene)]   ;10
        [(= w (sprite-state deadState))   (deadScene)]   ;11
        [(= w (gui-state    sleep))       (sleepScene)]  ;12
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Mouse Event Handlers ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-----------------------------------------------------------------------------------------------------------------------------------------
;Contrato: isInside?: number number button -> boolean

;Proposito: La finalidad de esta funcion consiste en verificar si el mouse esta dentro de un boton del viejojuego

;Cuerpo:
(define (isInside? x y button)
   (cond [(and (>= x (button-x button))
               (<= x (+ (button-x button) (button-width button)))
               (>= y (button-y button))
               (<= y (+ (button-y button) (button-height button)))
          ) #t
         ] [else #f]
   )
)
;----------------------------------------------------------------------------------------------------------------------------------
;Contrato: clicl: mouse-event -> boolean

;Proposito: La finalidad de esta funcion esta en tener la opcion de dar click (accion) dentro de la pantalla de juego

;Cuerpo:
(define (click me)
  (cond [(and (mouse-event? me)(equal? me "button-down")) "Click " #t]
        [else #f])
)
;-----------------------------------------------------------------------------------------------------------------------------------
;Contrato: mouse -> num num num mouse-event -> string or number

;Proposito: La finalidad de esta funcion consiste en que si esta activo el modo "debug" mostrar en que posicion esta el mouse
;y mostrar tambien que accion esta haciendo. Aparte de esto es la que le permite al usuario interactuar con los diferentes
;botones del juego, ya que permite poder accionar cada uno de estos. Si el mouse no esta dentro de la ventana, inmediatamente
;la mascota estara el estado dormir.

;Cuerpo:
(define (mouse w x y me)

  (cond [(equal? debug #t)
         (writeln (string-append  "ME:" me))
         (writeln (string-append  "X:" (number->string x) " Y:" (number->string y)))
        ] [else w]
  )

  (cond [(and (isGUI? w menu) (isInside? x y newGameButton)  (click me))
         (writeln "Inside New Game") (+ w 1)]
        [(and (isGUI? w menu) (isInside? x y continueButton) (click me))
         (writeln "Inside Continue") (+ w 1)]

        [(and (isInside? x y nextButton) (click me))
         (writeln "Inside Next") (+ w 1)]

        [(and (isGUI? w actions) (isInside? x y eatButton) (click me))
         (writeln "Inside EatButton") (sprite-state eatState)]
        [(and (isGUI? w actions) (isInside? x y washButton) (click me))
         (writeln "Inside WashButton") (sprite-state washState)]
        [(and (isGUI? w actions) (isInside? x y gameButton) (click me))
         (writeln "Inside GameButton") (sprite-state gameState)]
        [(and (isGUI? w actions) (isInside? x y healButton) (click me))
         (writeln "Inside HealButton") (sprite-state healState)]
        [(and (isGUI? w actions) (isInside? x y listenButton) (click me))
         (writeln "Inside ListenButton") (sprite-state listenState)]
        [(and (isGUI? w actions) (isInside? x y sleepButton) (click me))
         (writeln "Inside SleepButton") (gui-state sleep)]

        [(and (isGUI? w actions) (equal? me "leave")) (gui-state sleep)]

        [(and (isGUI? w gameover) (isInside? x y backButton) (click me))
         (writeln "Inside BackButton") (gui-state menu)]

        [(and (isGUI? w sleep) (isInside? x y wakeButton) (click me))
         (writeln "Inside WakeButton") (sprite-state idleState)]

        [else w]
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Keyboard Event Handlers ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Contrato: keyboard: num key-event -> num or string

;Proposito: La finalidad de esta funcion consiste en que si esta en modo debug muestra en la consola la tecla que se unde.
;Tambien es la que le permite al usuario escribir el nombre que desea otorgarle a su mascota. Por otro lado posee funciones como:
;-Mientras esta en el modo debug se puede ir de un estado al otro tan solo con las flechas del teclado.
;-Es  otra manera de que el usuario interactue con el juego mientras esta jugando.
;-Permite activar el modo debug con la tecla F8
;-Permite volver al principio del juego con la tecla F5
;-Permmite despixelar el juego con la tecla P

;Cuerpo:
(define (keyboard w key)

  (cond [(equal? debug #t) (writeln (string-append "Key: " key))])

  (cond [(isGUI? w rename)
            (cond [(and  (>= (string-length (pet-name panda)) 1) (key=? key "\b")) 
                   (set-pet-name! panda
                   (substring (pet-name panda) 0 (sub1 (string-length (pet-name panda)))))]
                  [(and (not (key=? key "shift"))
                        (not (key=? key "\b"))
                        (not (key=? key "left"))
                        (not (key=? key "right"))
                        (not (key=? key "escape"))
                        (not (key=? key "f8")))
                   (set-pet-name! panda
                               (string-append (pet-name panda) key))]
                  [else w]
            )
        ]
  )           


  (cond [(and (equal? debug #t) (not (isGUI? w intro)) (key=? key "left" )) (restart) (- w 1)]
        [(and (equal? debug #t) (not (isGUI? w sleep)) (key=? key "right")) (restart) (+ w 1)]

        [(and (isGUI? w actions) (not (isGUI? w rename)) (key=? key "z"))
            (restart) (sprite-state eatState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "x"))
            (restart) (sprite-state washState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "c"))
            (restart) (sprite-state gameState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "v"))
            (restart) (sprite-state healState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "b"))
            (restart) (sprite-state listenState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "n"))
            (restart) (gui-state sleep)]

        [(and (isGUI? w sleep) (not (isGUI? w rename))  (key=? key "n"))
            (restart) (sprite-state idleState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "k"))
            (restart) (setZeroStats panda) (sprite-state idleState)]

        [(and (isGUI? w actions) (not (isGUI? w rename))  (key=? key "escape"))
            (restart) (sprite-state idleState)]

        [(key=? key "f5") 0]
        [(key=? key "f8") (onOffDebug) w]
        [(and (not (isGUI? w rename)) (key=? key "p")) (onOffPixelate) w]

        [(and (isGUI? w rename) (key=? key "\r")) (+ w 1)]
        [else w]
  )    
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Engine ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Contrato: engine: num -> num

;Proposito: engine es la funcion que permite avanzar de un estado a otro con la funcion "next",
;tambien permite pausar las escenas con la funcion "pause". Por otro lado tiene la funcion "goto"
;que es la que nos permite dirigirnos a un sprite en especifico.

;Cuerpo:
(define (engine w)

   (define (next w)
     (+ w 1)
   )

   (define (pause w)
     w
   )

   (define (goto sprite)
     (sprite-state sprite)
   )

   (cond [(= (gui-frames actualGUI) countGUI)
          (cond [(equal? (gui-time actualGUI) "idle")  (restart) (goto idleState)]
                [(equal? (gui-time actualGUI) "next")  (restart) (next w)]
                [(equal? (gui-time actualGUI) "pause") (pause w)])
         ][else w]
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Main ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Proposito: esta funcion es la que hace uso de todas las funciones anteriores, para asi hacer posible el videojuego.
(big-bang 0
  (on-tick engine (framerate)) ; Framelimit
  (to-draw gameplay screenWidth screenHeight)
  (on-mouse mouse)
  ;(state #f)
  (on-key keyboard)
  (name "PandaSushi")
)
