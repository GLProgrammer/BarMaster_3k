classdef BarMaster
    %BarMaster - Main class of bot
    %   Usefull methods for controlling BarMaster's movement and
    %   functionality

    properties
        ArduinoBoard
        ConnectionPort
        ServoPort
        StepperPort
        Arduino
        Shield
        Servo
        Stepper
    end

    methods
        function this = BarMaster(ConnectionPort, ArduinoBoard, ServoPort, StepperPort)
            this.ArduinoBoard = ArduinoBoard;
            this.ConnectionPort = ConnectionPort;
            this.ServoPort = ServoPort;
            this.StepperPort = StepperPort;
            this.Arduino = arduino(this.ConnectionPort, ArduinoBoard, 'Libraries', 'Adafruit/MotorShieldV2');
            this.Shield = addon(this.Arduino, 'Adafruit/MotorShieldV2');
        end
    end

    %% Connecting to motors
    methods
        function this = ConnectServo(this,ServoNum)
            this.Servo = servo(this.Shield, ServoNum);
            disp("Servo Connected!");
        end

        function this = ConnectStepper(this, StepperMotorNum, StepsPerRevolution)
            this.Stepper = stepper(this.Shield, StepperMotorNum, StepsPerRevolution, "RPM", 1000,"StepType", "Interleave");
            disp("Stepper Connected!");
        end
    end

    %% Moving motors
    methods
        function this = MoveServo(this, angle)
            disp("Moving Servo");
            writePosition(this.Servo, angle);
        end

        function this = MoveStepper(this, Steps)
            disp("Moving Stepper!");
            move(this.Stepper, Steps);
            release(this.Stepper);
        end
    end
end

