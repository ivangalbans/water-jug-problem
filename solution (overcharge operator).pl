% solve(state(0, 0), state(_, 2), Solution).

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
