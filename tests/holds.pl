holds(F, [F|_]).
holds(F, Z) :- Z=[F1|Z1], \+ (F1 == F), holds(F, Z1).