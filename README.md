# Tamagotchi

# ToDo
Determinar las condiciones de cambio entre estados
Leer sobre las maquinas de estado en Racket en el apartado 2.4.4.1
https://docs.racket-lang.org/teachpack/2htdpuniverse.html
Podemos usar Pixel-Art para todo el juego convirtiendo imagenes de vectores en pixeles, le da un estilo retro

## Interfaz
* Implementar una funcion que dibuja una ventana de tamaño 720x720
* Implementar una funcion que dibuja el puntero al interior de la ventana anterior
* Implementar el boton stop para cerrar el programa
* Implementar dos botones uno para un nuevo juego y otro para un juego previo
* Implementar una funcion que crea un boton con un texto X en una posn(x,y)
* Funcion reutilizable de movimiento en el eje X por segundo de un objeto
* Funcion reutilizable de movimiento en el eje Y por segundo de un objeto
* Implementar una funcion que dibuja una barra de estado, con nombre X y con valor actual de llenado Y y total posible de llenado Z, mostrar el nombre de la barra debajo de si misma o encima
* Implementar una funcion que muestra una pequeña ventana emergente al iniciar un nuevo juego
* Implementar una pantalla onboard con el nombre del juego
* Implementar una funcion que dibuja el menu principal con el titulo en la parte superior
* Implementar una pantalla despues de selecionar nuevo juego para ingresar el nombre de nuestro tamago
* Implementar una funcion que dibuja el fondo del escenario de juego
* Implementar una funcion que dibuja el tamago
* Implementar una funcion que al hacer click mas rápidamente abra el tamago
* Implementar una funcion que dibuja la apariencia de Gotzilla Chibi (Godzilla bebe)
* Implementar una funcion que dibuja los botones de juego, jugar, bañar, dormir, curar en la parte inferior de la pantalla
* Implementar una funcion qué  dibuja las barras de estado salud, energia, vida, sueño, alimento en la parte superior de la pantalla
* Implementar una funcion que realiza la animacion de juego durante X segundos 
* Implementar una funcion que realiza la animación de bañar durante X segundos
* Implementar una funcion que realiza la animacion de dormir durante X horas rellenar 1 punto de sueño por cada hora hasta 10 puntos
* Implementar una funcion que desactiva o apaga todos los botones de juego
* Implementar una funcion que dibuja un boton que ejecuta la funcion despertar mientras los otros estan desactivados 
* Implementar una funcion que realiza la animacion de curar durante X segundos
* Implementar una funcion que realiza la animacion de enfermo infinitamente
* Implementar una funcion que realiza la animacion de morir
* Implemenrar una funcion que dibuja una lapida
* Implementar una funcion que dibuja un boton de regresar al menu

## Logica
* Implementar Big-bang para determinar el comportamiento de la ventana del juego y del programa en si
* Implementar la funcion stop ejecutada por el boton
* Implementar una funcion que guarda en texto plano las condiciones actuales de nuestro tamago
* Implementar una función que lee un texto plano las condiciones de un juego previamente guardado
* Implementar una funcion que interactua con click con un boton y ejecuta X funcion
* Implementar una funcion que inicialice un tamago con el nombre especificado y con estadísticas a full, esta funcion llama a otras funciones de interfaz
* Implementar un funcion que realice el cambio de estado del tamago usando set!
* Implementar una funcion que realice el cambio de pantalla
* Implementar una funcion que asigne una tecla a un boton de accion de la interfaz

# Resources

## Universe
Simulation opens a canvas and starts a clock that ticks 28 times per second.

```racket
(define (create-UFO-scene height)
  (underlay/xy (rectangle 100 100 "solid" "white") 50 height UFO))
 
(define UFO
  (underlay/align "center"
                  "center"
                  (circle 10 "solid" "green")
                  (rectangle 40 4 "solid" "green")))
```
Every time the clock ticks, Racket applies create-image to the number of ticks passed since this function call.

Animate returns the number of ticks that have passed.

```racket
(animate create-image) 
```

Simulation designates one function, create-image, as a handler for one kind of event: clock ticks. In addition to clock ticks, world programs can also deal with two other kinds of events: keyboard events and mouse events.

World programs can also deal with two other kinds of events: keyboard events and mouse events.

## Worlds

Simulating any dynamic behavior via a world program demands two different activities. First, we must tease out those portions of our domain that change over time or in reaction to actions, and we must develop a data representation for this information. This is what we call WorldState.

## Handler Functions
The teachpack provides for the installation of four **event handlers**: _on-tick_, _on-key_, _on-mouse_, and _on-pad_. A world program must specify a render function, which is called every time your program should visualize the current world, and a _done_ predicate, which is used to determine when the world program should shut down.

Each handler function consumes the current state of the world and optionally a data representation of the event. It produces a new state of the world.

## Big Bang

The only mandatory clause of a big-bang description is ___to-draw___.
A world specification may not contain more than one ___on-tick___, ___to-draw___, or ___register___ clause.

```racket
(to-draw render-expr width-expr height-expr)
```

## Framerate 

```racket 
(on-tick tick-expr rate-expr)
```
Racket call the ___tick-expr___ function on the current world every time the clock ticks. The result of the call becomes the current world. The clock ticks every __rate-expr__ seconds.

## Time Limit Function 

```racket
(on-tick tick-expr rate-expr limit-expr) 
```
Racket call the ___tick-expr___ function on the current world every time the clock ticks. The result of the call becomes the current world. The clock ticks every ___rate-expr___ seconds. The world ends when the clock has ticked more than ___limit-expr___ times.

## Keyboard Function 

```racket 
(on-key key-expr)
```

Racket call the __key-expr__ function on the current world and a KeyEvent for every keystroke the user of the computer makes. The result of the call becomes the current world.


```racket 
(define (change w a-key)
  (cond
    [(key=? a-key "left")  (world-go w -DELTA)]
    [else w]))
```

## Mouse Function

```racket 
(on-mouse mouse-expr)
``` 
Racket call ___mouse-expr___ on the current world, the current x and y coordinates of the mouse, and a MouseEvent for every (noticeable) action of the mouse by the computer user. The result of the call becomes the current world.

## State 

```racket
(state expr)
```
Racket opens a separate window in which the current state is rendered each time it is updated.

# Links

## Racket Universe
https://docs.racket-lang.org/teachpack/2htdpuniverse.html

## Racket Image
https://docs.racket-lang.org/teachpack/2htdpimage.html

## Racket Textbox
https://youtu.be/ayoofXuKqMY?t=1077

## Tamagotchi Original
https://www.playr.org/play/tamagotchi/538