/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

Static World element specification for WUMPUS

Defines the basic element objects in the world

version: 0.1
*******************************************************************************/

:- object(wwplace(_X_,_Y_), implements(wwplacep)).
	x(_X_).
	y(_Y_).
	
:- end_object.

:- object(pit(_X_,_Y_), extends(wwplace(_X_,_Y_))).

:- end_object.

:- object(exit(_X_,_Y_), extends(wwplace(_X_,_Y_))).

:- end_object.

:- object(wall(_X_,_Y_), extends(wwplace(_X_,_Y_))).

:- end_object.