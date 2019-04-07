#lang racket

(define estadisticas (vector 6 0))

(define nivelComida    10)
(define nivelBano      10)
(define nivelJuego     10)
(define nivelSalud     10)
(define nivelMusica    10)
(define nivelFelicidad 10)

(vector-ref estadisticas nivelComida); así se llaman los vectores dentro de las funciones


(define-struct MUNDO (vector universe functions)); aquí definé lo que debe tener cada mundo

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

;nivelMusica : + 2 la felicidad,
;              otra vez + 1,
;               una tercera vez disminuye en 1
;              -1 salud

;nivelMuerte: 0 todo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONDICIONES DE IMAGENES;;;;;;;;;;;;;;;;;;;

(define-struct tamagotchi (nombre image estadisticas)) 

(define nombre 0)

(define imagen 0)


(define (eat)  
  (set! image (animacion-eat)) ;cada vez que el usuario presione la tecla destinada para comer, mostrara esta animacion
)

(define (shower)
  (set! image (animacion-shower)) ;cada vez que el usuario presione la tecla destinada para ir al baño, mostrara esta animacion
)

(define (play)
  (set! image (animacion-play)) ;cada vez que el usuario presione la tecla destinada para jugar, mostrara esta animacion
)

(define (music)
  (set! image (animacion-music)) ;cada vez que el usuario presione la tecla destinada para escuchar musica, mostrara esta animacion
)

(define (heal)
  (set! image (animacion-heal)) ;cada vez que el usuario presione la tecla destinada para curar, mostrara esta animacion
)

(define (stateSick)
  (set! image (animacion-sick)) ;cada vez que el estado del tamago llegue a enfermo, mostrara esta animacion
)

(define (stateDed)
  (set! image (animacion-ded)) ; ;cada vez que el estado del tamago llegue a muerto, mostrara esta animacion
 )


;;;;;;;;;;;;;;;;;;;;;;;;;CONDICIONES PARA CAMBIAR DE MUNDO;;;;;;;;;;;;;;;;

(define (estadisticasxd accion n)
  (and (> 1 n) (< 10 n)))


;Nombres de los frames :

;Muerte -> el panda se muere cuando (-1 salud), no tiene interaciòn o la felicidad es 0 

(cond
  [(< nivelSalud 1 (goto (frame stateDed)))]
  [(= nivelFelicidad 0 (goto (frame stateDed)))]
  [( > goto 30000 (got (frame stateDed)))]
  )

;Comer -> Cuando se alimenta a la mascota 1 vez su felicidad aumenta en 1, 2 veces la aumenta en 0 y 3 veces -1, lo enferma.

(cond
  [(+ nivelComida 1)
   (begin
     (cond 
     (+ 1 (vector-ref estadisticas nivelFelicidad) (goto (frame eat)))
     [(repeat (+ nivelComida 1))(+ 0 (vector-ref estadisticas nivelFelicidad) (goto (frame eat)))]
     [(repeat (cond + nivelComida 1)(- 1 (vector-ref estadisticas nivelSalud)(goto (frame stateSickl))))])
     [(- 1 (vector-ref estadisticas nivelBano))(- 1 (vector-ref estadisticas nivelJuego))(- 1 (vector-ref estadisticas nivelSalud))
                                               (- 1 (vector-ref estadisticas nivelMusica))])])
     
  

;Jugar -> Jugar una vez aumenta la felicidad en 2,
     ;jugar 2 veces le aumenta en 1
     ;3 veces no le aumenta ni disminuye felicidad pero le produce hambre disminuyendo su conteo de alimento en 2.

(cond
  [(+ nivelJuego 1)
   (begin
     (cond
       (+ 2 (vector-ref estadisticas nivelFelicidad) (goto (frame play)))
       [(repeat (+ nivelJuego 1))(+ 1 (vector-ref estadisticas nivelFelicidad)(goto (frame play)))]
       [(repeat (+ nivelJuego 1))(- 2 (vector-ref estadisticas nivelComida)(goto (frame play)))])
      [(- 1 (vector-ref estadisticas nivelBano))(- 1 (vector-ref estadisticas nivelComuda))(- 1 (vector-ref estadisticas nivelSalud))
                                               (- 1 (vector-ref estadisticas nivelMusica))])])
     
     
    


;Escuchar música -> una vez aumenta en 2 la felicidad, otra vez le aumenta en 1, y una tercera vez disminuye en 1, lo enferma, debe curarlo.

(cond
  [(+ nivelMusica 1)
   (begin
     (cond
       (+ 2 (vector-ref estadisticas nivelFelicidad)(goto (frame music)))
       [(repeat (+ nivelMusica 1))(+ 1 (vector-ref estadisticas nivelFelicidad)(goto (frame music)))]
       )[(repeat (+ nivelMusica 1))(- 1 (vector-ref estadisticas nivelSalud))(goto (frame stateSick))]
         [(- 1 (vector-ref estadisticas nivelBano))(- 1 (vector-ref estadisticas nivelComuda))(- 1 (vector-ref estadisticas nivelSalud))
                                               (- 1 (vector-ref estadisticas nivelJuego))])])
     
        
  

;El baño le aumenta la felicidad en 2, la segunda vez no lo afecta y la tercera le disminuye en 1 enfermándolo, debe curarlo.

(cond
  [(+ nivelBano 1)
   (begin
     (cond
       (+ 2 (vector-ref estadisticas nivelFelicidad)(goto (frame shower)))
       [(repeat (+ nivelBano 1))(0 goto (frame shower))]
       [(repeat (+ nivelBano 1))(- 1 (vector-ref estadisticas nivelSalud))(goto (frame stateSick))])
     [(- 1 (vector-ref estadisticas nivelMusica))(- 1 (vector-ref estadisticas nivelComuda))(- 1 (vector-ref estadisticas nivelSalud))
                                               (- 1 (vector-ref estadisticas nivelJuego))])])
     
  

;Curar -> una vez le aumenta la felicidad en 3 y más veces no le afecta.

(cond
  [(+ nivelSalud 1)
   (begin
     (cond
       (+ 3 (vector-get estadisticas nivelFelicidad)(goto (frame heal)))
       [(repeat (+ nivelSalud 1))(goto (frame heal))])
     [(- 1 (vector-ref estadisticas nivelMusica))(- 1 (vector-ref estadisticas nivelComuda))(- 1 (vector-ref estadisticas nivelBano))
                                               (- 1 (vector-ref estadisticas nivelJuego))])])
     
     
  
  
;Si el contador de alguna acción llega a 4 la mascota morirá, con excepción de curar.

(cond
  [(>= 4 (estadisticasxd (vector-ref estadisticas nivelSalud)))(goto (frame Normal))]
  [else (estadisticasxd (vector-fef estadisticas n))(goto (frame stateDead))]
  )




