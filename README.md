# Tamagotchi

# GitHub 
https://github.com/GoVirus/Tamagotchi

## ToDo

## Animation
* Panda comiendo Sushi
* Panda comiendo Bambu
* Panda comiendo Ramen

### Interfaz
* Implementar una funcion que muestra la notificacion como nube del estado actual del Panda
* Implementar una funcion que dibuja el puntero al interior de la ventana anterior
* Implementar el boton stop para cerrar el programa
* Funcion reutilizable de movimiento en el eje X por segundo de un objeto
* Funcion reutilizable de movimiento en el eje Y por segundo de un objeto
* Implementar una funcion que al hacer click mas rápidamente abra el tamago

### Logica
* Implementar una funcion que guarda en texto plano las condiciones actuales de nuestro tamago
* Implementar una función que lee un texto plano las condiciones de un juego previamente guardado

# Frames Table

| Nombre            | Tipo  | State        | Frames |
|-------------------|-------|--------------|--------|
| Intro             | Next  | 0            | 120    |
| Title             | Next  | 1            | 120    |
| Menu              | Pause | 2            | 120    |
| Rename  (Textbox) | Pause | 3            | 120    |
| Egg               | Next  | 4            | 120    |
| Idle Normal       | Pause | 5            | 120    |
| Eat               | Idle  | 6            | 120    |
| Wash              | Idle  | 7            | 120    |
| Game              | Idle  | 8            | 120    |
| Heal              | Idle  | 9            | 120    |
| Listen            | Idle  | 10           | 120    |
| Dead              | Idle  | 11           | 120    |
| Sleep             | Idle  | 12           | 120    |

# Basics

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

# Links and Resources

## Racket Documentation
https://docs.racket-lang.org/

## Racket Universe
https://docs.racket-lang.org/teachpack/2htdpuniverse.html

## Racket Image
https://docs.racket-lang.org/teachpack/2htdpimage.html

## Racket Programmer Structs Transparent and Mutable 
https://docs.racket-lang.org/guide/define-struct.html#%28tech._transparent%29

## Racket Define-Structus
https://docs.racket-lang.org/reference/define-struct.html

## Racket Textbox
https://youtu.be/ayoofXuKqMY?t=1077

## Racket Mutation with Set!
https://www.coursera.org/lecture/programming-languages-part-b/mutation-with-set-dIHCG

## Tamagotchi Original
https://www.playr.org/play/tamagotchi/538

## Topics in Racket
http://zoo.cs.yale.edu/classes/cs201/topics/

## Notes in Typed Racket
http://people.cs.uchicago.edu/~adamshaw/cmsc15100-2017/typed-racket-guide/