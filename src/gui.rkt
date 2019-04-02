#lang racket

(require 2htdp/image)
(require math/base)

(define screenHeight 432) ;True 16:9
(define screenWidth 768) ;True 16:9

(define debug #t)
(define showFrames #t)
(define showFPS #t)
(define showActualState #t)
(define actualState "Main")
(define showTimeline #t)
(define startFrame 0)
(define endFrame 0)
(define fps 60)
(define count 0)




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

(define (screenBottomY img)
  (- screenHeight (/ (image-height img) 2))
)

(define (drawBackground w img)
  img
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

(define (drawTimeline)
  (above/align "left" (isosceles-triangle 15 -15 "solid" "red")
                      (rectangle 768 15 "outline" "black")
  )
)

(define (drawInterface)
  (beside (rectangle 75 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          (rectangle (gridSizeX) 75 "solid" "red")
          )
)

(define (drawSprite)
  (bitmap/file "assets/img/ui/game.png")
)

(define background (rectangle 768 432 "solid" "white"))

;(define (render w ui sprite)
(define (render ui sprite)
  
                ;Img                   ;X                             ;Y
   (place-image (frame(drawGrid))      (screenCenterX)                (screenCenterY) 
   (place-image (frame sprite)         (screenCenterX)                (screenCenterY)         ; Interface Layer
   (place-image (frame ui)             (screenCenterX)                (screenTopY ui 6)                ; Sprite Layer
   (place-image (frame(drawTimeline))  (screenCenterX)                (screenTopY (drawTimeline) 8) ; Timeline Layer
   (place-image (frame(debugTools 0))  (screenRightX (debugTools 0))  (screenTopY (debugTools 0) 0)    ; Debug Layer
                                       (drawBackground 0 background))))))                             ; Background Layer

)

(render (drawInterface) (drawSprite))