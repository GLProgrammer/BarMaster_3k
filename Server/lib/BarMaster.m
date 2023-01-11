classdef BarMaster
    %BarMaster - Main class of bot
    %   Usefull methods for controlling BarMaster's movement and
    %   functionality  

    properties
        DebugStates

        ArduinoBoard
        ConnectionPort
        ServoPort
        StepperPort
        Arduino
        Shield
        Servo
        Stepper
    end

    properties
        LogsPath
        LogsTime
    end

    properties
        DatabasePath
    end

    methods
        %Debug states: "NoArduino", "NoDatabase"
        function this = BarMaster(ConnectionPort, ArduinoBoard, ServoPort, StepperPort, DatabasePath, LogsPath, DebugStates)
            %Setting up logging and debugging
            this.DebugStates = DebugStates;

            this.LogsPath = LogsPath;
            this.LogsTime = string(datetime("now", "Format","MMM_d_uuuu_HH_mm"));
            if ~exist(this.LogsPath,"dir")
                mkdir(this.LogsPath);
            end

            if exist(this.LogsPath + "\" + this.LogsTime + ".txt", "file")
                delete(this.LogsPath + "\" + this.LogsTime + ".txt")
            end
            
            %Setting Up Arduino connection
                this.ArduinoBoard = ArduinoBoard;
                this.ConnectionPort = ConnectionPort;
                this.ServoPort = ServoPort;
                this.StepperPort = StepperPort;
            if(~DebugStates.contains("NoArduino"))
                this.Log("Arduino: Setting up connection");
                try      
                    this.Arduino = arduino(this.ConnectionPort, ArduinoBoard, 'Libraries', 'Adafruit/MotorShieldV2');
                    this.Shield = addon(this.Arduino, 'Adafruit/MotorShieldV2');
                    this.Log("Arduino: Connected!");
                catch ERR
                    disp("Error while connecting to Arduino");
                    this.LogErr(ERR);
                end
            else
                this.Log("Arduino: Skipping Connection - debug state");
            end


            %Setting Up Database connection
            this.DatabasePath = DatabasePath;
            if(~DebugStates.contains("NoDatabase"))
            else
                this.Log("Database: Skipping Connection - debug state");
            end
        end
    end

    %% Connecting to motors
    methods
        function this = ConnectServo(this,ServoNum)
            try
                if(~this.DebugStates.contains("NoArduino"))
                    this.Log("Arduino: Connecting servo");
                    this.Servo = servo(this.Shield, ServoNum);
                    this.Log("Arduino: Servo Connected!");
                else
                    this.Log("Arduino: Skipping servo connection - debug state");
                end
            catch ERR
                disp("Error while connecting Servo");
                this.LogErr(ERR);
            end
        end

        function this = ConnectStepper(this, StepperMotorNum, StepsPerRevolution)
            try
                if(~this.DebugStates.contains("NoArduino"))
                    this.Log("Arduino: Connecting stepper");
                    this.Stepper = stepper(this.Shield, StepperMotorNum, StepsPerRevolution, "RPM", 1000,"StepType", "Interleave");
                    this.Log("Arduino: Stepper Connected!");
                else
                    this.Log("Arduino: Skipping stepper connection - debug state");
                end
            catch ERR
                disp("Error while connecting Stepper");
                this.LogErr(ERR);
            end
        end
    end

    %% Moving motors
    methods
        function this = MoveServo(this, angle)
            try
                if(~this.DebugStates.contains("NoArduino"))
                    this.Log("Arduino: Moving Servo to: " + string(angle));
                    writePosition(this.Servo, angle);
                    this.Log("Arduino: Servo moved successfully!");
                else
                    this.Log("Arduino: Skipping servo movement - debug state");
                end
            catch ERR
                disp("Error while moving Servo");
                this.LogErr(ERR);
            end
        end

        function this = MoveStepper(this, Steps)
            try
                if(~this.DebugStates.contains("NoArduino"))
                    this.Log("Arduino: Moving stepper by " + string(Steps) + " steps");
                    move(this.Stepper, Steps);
                    release(this.Stepper);
                    this.log("Arduino: Stepper moved and released successfully!");
                else
                    this.Log("Arduino: Skipping stepper movement - debug state");
                end
            catch ERR
                disp("Error while moving Stepper");
                this.LogErr(ERR);
            end
        end
    end
    
    %% Logging
    methods
        function this = Log(this, message)
            writelines(message, this.LogsPath + "\" + this.LogsTime + ".txt", "WriteMode","append");
        end

        function this = LogErr(this, error)
            writelines("ERROR: " + error.message, this.LogsPath + "\" + this.LogsTime + ".txt", "WriteMode","append");
        end
    end
end

