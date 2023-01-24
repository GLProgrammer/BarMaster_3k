clc, clear;

addpath lib\

%% Creating connection to BarMaster

connectionPort = "COM3";
board = "Mega2560";

homePath = pwd;

bm = BarMaster(connectionPort, board, "Servo1", "Stepper1", "D44", homePath + "\resources\Drinks.db", homePath + "\logs", [""]);
[bm, Drinks] = bm.DBGetResources();
bm = bm.ConnectStepper(1,200);
bm = bm.HomeBarBot(20);
% bm = bm.ConnectServo(1);