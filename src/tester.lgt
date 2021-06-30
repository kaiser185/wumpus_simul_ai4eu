/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

CARMAS tester for C4IIoT

This file controls all test initialization tasks

version: 0.1
*******************************************************************************/
:- initialization((
	set_logtalk_flag(report, warnings),
	logtalk_load(lgtunit(loader)),
	logtalk_load(loader, [debug(on)]),
	logtalk_load(tests, [hook(lgtunit)]),
	tests::run
)).