/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

WUMPUS base loader file

This file contains all the loader code for the simulator and its dependencies.

version: 0.2
*******************************************************************************/


% Init script
:- initialization((
	logtalk_load([
		sflux,
		wwconfigp,
		wwconfig,
		wwsimulatorp,
		wwsimulator,
		wwfeaturep,
		wwfeature,
		wwplacep,
		wwplace,
		wwstatep,
		wwstate,
		wwaction,
		wwpercept,
		server,
		test_cases,
		wwtypes
	],[/*debug(on)*/])
)).
