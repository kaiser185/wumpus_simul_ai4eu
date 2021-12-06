/*******************************************************************************
Author: Jacques Robin, Camilo Correa Restrepo, 2021.

CARMAS tester for C4IIoT

This file controls all test initialization tasks

version: 0.1
*******************************************************************************/
:- initialization((
	%These first two lines enables verbose compilation
	%and load the testing library itself
	set_logtalk_flag(report, warnings),
	logtalk_load(lgtunit(loader)),
	logtalk_load(debugger(loader)),
	%This line loads our application with debugging information
	logtalk_load(loader, [debug(on)]),
	%This line loads our test suite specification, ensuring it is treated as such
	logtalk_load(tests, [debug(on), hook(lgtunit)]),
	%This line automatically executes our test suite after all compilation is done
	tests::run
)).