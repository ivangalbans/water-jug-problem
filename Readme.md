# Los jarros de agua

## Descripción

Se dispone de dos jarros, uno con una capacidad de 3 litros y otro con una capacidad de 4 litros. Ninguno de los dos tiene marcas que permitan medir cantidades que no sean las de sus propias capacidades.

Existe una pila de agua que permite llenar los jarros con agua y un sumidero donde se puede vaciar los mismos. El problema consiste en encontrar cuál es la secuencia de movimientos de llenado, vaciado y trasvase que permite obtener exactamente dos litros de agua en el jarro de 4 litros.

## Solución

### **Representación**

Primeramente pensemos en una forma de representar la solución del problema. En la implementación realizada se utilizó una lista de _string_, en la cual cada _string_ representa una acción a realizar con las jarras. Por ejemplo la lista _Solution_ de abajo contiene una solución válida del problema.

> Solution = ['fill pitcher1', 'pitcher1 to pitcher2', 'fill pitcher1', 'pitcher1 to pitcher2', 'empty pitcher2', 'pitcher1 to pitcher2']

### **Acciones**

Para la solución del problema se considera que existen 6 tipos de acciones entre las jarras a tener en cuenta para la idea del algoritmo; estas son:

1. "**fill pitcher1**": Llenar la primera jarra de la pila de agua.

2. "**fill pitcher2**": Llenar la segunda jarra de la pila de agua.

3. "**empty pitcher1**": Vaciar la primera jarra en el sumidero.

4. "**empty pitcher2**": Vaciar la segunda jarra en el sumidero.

5. "**pitcher1 to pitcher2**": Echar el agua (que se pueda) de la primera jarra en la segunda.

6. "**pitcher2 to pitcher1**": Echar el agua (que se pueda) de la segunda jarra en la primera.

### **Ideal del algoritmo**

Una forma de atacar el problema y fácil de implementar, entender y explicar es, a consideración de los autores, modelando el problema a un problema de la teoría de grafos.

Sea _G_ = _<V, E>_ un grafo dirigido, donde al conjunto de vértices _V_ pertenecen todos los estados posibles en los que pueden estar las dos jarras: el estado de una jarra es la cantidad de litros de agua que hay en ella. Por ejemplo, si en la primera jarra hay _1L_ de agua y en la segunda hay _3L_, entonces el vértice de _G_ que representa a dicho estado será _state(1, 3)_. Las aristas de nuestro grafo serán precisamente el conjunto de pares de vértices _<x, y>_ tal que el estado _y_ se obtiene al realizar una de las 6 acciones anteriores al estado _x_. Por ejemplo, una arista de _G_ es _<state(1, 3), state(0, 4)>_, ya que el estado _state(0, 4)_ es el resultado de aplicar la quinta acción (echar el agua (que se pueda) de la primera jarra en la segunda) al estado _state(1, 3)_.

Como lo que deseamos es encontrar una lista de acciones válidas que permitan, dado las jarras vacías, obtener en la segunda jarra exactamente dos litros, el problema se reduce a encontrar un camino en _G_ desde el vértice _state(0, 0)_ al _state(\_, 2)_. Es evidente que las aristas de un camino en _G_ desde un vértice _u_ a otro _v_ representan una lista de acciones posibles a realizar para llevar las jarras del estado _u_ al _v_.

Para encontrar dicho camino en _G_ podemos realizar tanto un BFS como un DFS. Aprovechando las características de _PROLOG_, la solución presentada realiza un recorrido DFS.

### **Implementación**

```PROLOG
solve(InitialState, FinalState, Actions) :- plan(InitialState, FinalState, Actions, [InitialState]).

plan(State, State, [], _) :- !.
plan(State1, State, [Action|R], States) :-  go(State1, State2, Action),
                                            not(member(State2, States)),
                                            plan(State2, State, R, [State2|States]).

go( state(0, L2) , state(3, L2) , 'fill pitcher1' ).
go( state(L1, 0) , state(L1, 4) , 'fill pitcher2' ).
go( state(L1, L2), state(0, L2) , 'empty pitcher1') :- L1 > 0.
go( state(L1, L2), state(L1, 0) , 'empty pitcher2') :- L2 > 0.

go( state(L1, L2), state(L3, 4), 'pitcher1 to pitcher2') :-  L1 > 0 , L2 < 4 , L2+L1 >= 4 , L3 is L1-(4-L2).
go( state(L1, L2), state(0, L4), 'pitcher1 to pitcher2') :-  L1 > 0 , L2 < 4 , L2+L1 < 4  , L4 is L2+L1.

go( state(L1, L2), state(3, L4), 'pitcher2 to pitcher1') :-  L2 > 0 , L1 < 3 , L1+L2 >= 3 , L4 is L2-(3-L1).
go( state(L1, L2), state(L3, 0), 'pitcher2 to pitcher1') :-  L2 > 0 , L1 < 3 , L1+L2 < 3  , L3 is L1+L2.
```

El predicado principal del código es _solve_, que recibe como parámetros un estado inicial, un estado final y una variable a unificar con una lista de _string_ que será la solución del problema; dicho esto, la _query_ formulada al intérprete para obtener la solución será:

```PROLOG
?- solve(state(0, 0), state(_, 2), Solution).
```

En la implementación podemos ver que el predicado _plan_ contiene un parámetro más que el predicado _solve_. Este último es una lista que contiene a todos los vértices que he visitado hasta el momento con el objetivo de no pasar nuevamente por ellos a través de otro camino de _G_ (técnica comúnmente utilizada en los recorridos de grafos); ese es precisamente el objetivo del cuerpo:

```PROLOG
not(member(State2, States))
```

El predicado _go_ representa las transiciones entre vértices (aristas). Recibe el estado de inicio, estado de fin y un _string_ que indica la acción que fue necesario llevar a cabo para pasar del estado de inicio al estado de fin.

#### Reglas de transición

- Regla asociada a la primera acción

  ```PROLOG
  go( state(0, L2) , state(3, L2) , 'fill pitcher1' ).
  ```

- Regla asociada a la segunda acción

  ```PROLOG
  go( state(L1, 0) , state(L1, 4) , 'fill pitcher2' ).
  ```

- Regla asociada a la tercera acción

  Es necesario comprobar que la primera jarra tenga agua.

  ```PROLOG
  go( state(L1, L2), state(0, L2) , 'empty pitcher1') :- L1 > 0.
  ```

- Regla asociadas a la cuarta acción.

  Es necesario comprobar que la segunda jarra tenga agua.

  ```PROLOG
  go( state(L1, L2), state(L1, 0) , 'empty pitcher2') :- L2 > 0.
  ```

- Reglas asociadas a la quinta acción

  La primera regla abarca el caso en el que la cantidad de litros de la primera jarra es mayor o igual que lo que le falta a la segunda para llenarse. La segunda regla es el caso complementario.

  ```PROLOG
  go( state(L1, L2), state(L3, 4), 'pitcher1 to pitcher2') :-  L1 > 0 , L2 < 4 , L2+L1 >= 4 , L3 is L1-(4-L2).

  go( state(L1, L2), state(0, L4), 'pitcher1 to pitcher2') :-  L1 > 0 , L2 < 4 , L2+L1 < 4  , L4 is L2+L1.
  ```

- Reglas asociadas a la sexta acción

  La primera regla abarca el caso en el que la cantidad de litros de la segunda jarra es mayor o igual que lo que le falta a la primera para llenarse. La segunda regla es el caso complementario.

  ```PROLOG
  go( state(L1, L2), state(3, L4), 'pitcher2 to pitcher1') :-  L2 > 0 , L1 < 3 , L1+L2 >= 3 , L4 is L2-(3-L1).

  go( state(L1, L2), state(L3, 0), 'pitcher2 to pitcher1') :-  L2 > 0 , L1 < 3 , L1+L2 < 3  , L3 is L1+L2.
  ```

## DSL para el problema de los Jarros de Agua

Aprovechando las potencialidades del lenguaje de programación _PROLOG_, se ha implementado un lenguaje de dominio específico (DSL por sus siglas en inglés), con el objetivo de resolver este problema con una sintaxis más cercana al lenguaje natural.

### **Operadores Definidos**

#### Operadores binarios

1. _go_to_: Transición desde un estado (operador izquierdo) a otro (operador derecho).

2. _not_in_: Triunfa si un elemento (operador izquierdo) no pertenece a la lista (operador derecho).

3. _to_

4. _with_

#### Operadores Unarios

1. _fill_

2. _empty_

### **Implementación**

```PROLOG
:-op(800,xfx,go_to).
:-op(800,xfx,not_in).
:-op(900,xfx,to).
:-op(850,yfx,with).
:-op(900,fx,fill).
:-op(900,fx,empty).

X not_in L :- not(member(X, L)).

solve(InitialState, FinalState, Actions) :- plan(FinalState, Actions, [InitialState]).

plan(FinalState, [], [FinalState|_]) :- !.
plan(FinalState, [Action|R], [IniState|States]) :-  IniState go_to NextState with Action,
                                                    NextState not_in States,
                                                    plan(FinalState, R, [NextState, IniState|States]).

state(0, L2) go_to state(3, L2) with (fill pitcher1).
state(L1, 0) go_to state(L1, 4) with (fill pitcher2).

state(L1, L2) go_to state(0, L2) with (empty pitcher1) :- L1 > 0.
state(L1, L2) go_to state(L1, 0) with (empty pitcher2) :- L2 > 0.

state(L1, L2) go_to state(L3, L4) with (pitcher1 to pitcher2) :- L1 > 0, L2 < 4, pour(L1, L2, L3, L4, 4).

state(L1, L2) go_to state(L3, L4) with (pitcher2 to pitcher1) :- L2 > 0, L1 < 3, pour(L2, L1, L4, L3, 3).

pour(L1, L2, L3, Limit, Limit) :- L2 + L1 >= Limit, !, L3 is L1 - (Limit - L2).
pour(L1, L2, 0, L4, _) :- L4 is L2 + L1.
```

## Colaboraciones

Cree un `issue` o envíe un `pull request`

## Autores

Iván Galbán Smith <ivan.galban.smith@gmail.com>

Raydel E. Alonso Baryolo <raydelalonsobaryolo@gmail.com>

4th year Computer Science students, University of Havana
