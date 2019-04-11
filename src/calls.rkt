#lang racket

(define petname "Panda")

(define-struct pet ([name #:mutable] [stats #:mutable]) #:transparent)

(define statFood   3)
(define statWash   3)
(define statGame   3)
(define statHeal   3)
(define statListen 3)
(define statHappy  5)

(define stats (vector statFood statWash statGame statHeal statListen statHappy))

(define panda (make-pet petname stats))

(vector-ref (pet-stats panda) 0)
(vector-ref (pet-stats panda) 1)
(vector-ref (pet-stats panda) 2)
(vector-ref (pet-stats panda) 3)
(vector-ref (pet-stats panda) 4)
(vector-ref (pet-stats panda) 5)

;(vector-set! (pet-stats panda) 0 (+ (vector-ref (pet-stats panda) statFood) 1)) ;Food
;(vector-set! (pet-stats panda) 1 (+ (vector-ref (pet-stats panda) statWash) 1)) ;Wash
;(vector-set! (pet-stats panda) 2 (+ (vector-ref (pet-stats panda) statGame) 1)) ;Game
;(vector-set! (pet-stats panda) 3 (+ (vector-ref (pet-stats panda) statHeal) 1)) ;Heal
;(vector-set! (pet-stats panda) 4 (+ (vector-ref (pet-stats panda) statListen) 1)) ;Listen
;(vector-set! (pet-stats panda) 5 (+ (vector-ref (pet-stats panda) statHappy) 1)) ;Happy

;(vector-set! (pet-stats panda) 0 10) ;Food
;(vector-set! (pet-stats panda) 1 10) ;Wash
;(vector-set! (pet-stats panda) 2 10) ;Game
;(vector-set! (pet-stats panda) 3 10) ;Heal
;(vector-set! (pet-stats panda) 4 10) ;Listen
;(vector-set! (pet-stats panda) 5 10) ;Happy

panda

;(vector-ref (pet-stats panda) statFood)