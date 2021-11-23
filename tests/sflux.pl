

%% Clause 1
holds(F, [F|_]).
%% Clause 2
%% Original: holds(F, Z) :- Z=[F1|Z1], F\==F1, holds(F, Z1).
holds(F, Z) :- Z=[F1|Z1], \+ (F1 = F), holds(F, Z1).

%% Clause 1
holds(F, [F|Z], Z).
%% Clause 2
%% Original: holds(F, Z, [F1|Zp]) :- Z=[F1|Z1], F\==F1, holds(F, Z1, Zp).
holds(F, Z, [F1|Zp]) :- Z=[F1|Z1], \+ (F1 = F), holds(F, Z1, Zp).

minus(Z, [], Z).
	minus(Z, [F|Fs], Zp) :-
		(\+ holds(F, Z) -> Z1=Z ; holds(F, Z, Z1)),
		minus(Z1, Fs, Zp).

    plus(Z, [], Z).
plus(Z, [F|Fs], Zp) :-
    (\+ holds(F, Z) -> Z1=[F|Z] ; holds(F, Z), Z1=Z),
    plus(Z1, Fs, Zp).

update(Z1, ThetaP, ThetaN, Z2) :-
    minus(Z1, ThetaN, Z), plus(Z, ThetaP, Z2).

execute(A, Z1, Z2) :- /*::perform(A),*/ state_update(Z1, A, Z2).