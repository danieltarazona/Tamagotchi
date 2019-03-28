#lang racket

(define estadisticas (vector 5 0))

(define nivelComida 0)
(define nivelBano 1)
(define nivelJuego 2)
(define nivelSalud 3)
(define nivelMusica 4)

(vectro-ref estadisticas nivelComida); así se llaman los vectores dentro de las funciones


(define-struc (MUNDO vector universe functions)); aquí definé lo que debe tener cada mundo

;;Definí lo que aumenta y disminuye con cada estado;;;;

;nivelComida : +1 apetito
;              +1 felicidad
;              -1 salud
;              -1 higiene

;nivelJugar :  -1 apetito
;              +1 felicidad
;              +1 salud
;              -1 higiene
;              -1 energia 

;nivelSalud :
;              -1 felicidad
;              +1 salud

;nivelBano :   +2 higiene 