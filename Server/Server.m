clc, clear;

addpath lib\

%% Creating connection to BarMaster

connectionPort = "COM3";
board = "Mega2560";

bm = BarMaster(connectionPort, board, "Servo1", "Stepper1");
bm = bm.ConnectStepper(1,200);
bm = bm.ConnectServo(1);
MoveServo(bm, 0.5)
MoveStepper(bm, 1000);