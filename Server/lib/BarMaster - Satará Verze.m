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
        EndstopPort
        Arduino
        Shield
        Servo
        Stepper
        CurrentSteps
    end

    properties
        LogsPath
        LogsTime
    end

    properties
        DatabasePath
    end

    methods
        %Debug states: "NoArduino"
        function this = BarMaster(ConnectionPort, ArduinoBoard, ServoPort, StepperPort, EndstopPort, DatabasePath, LogsPath, DebugStates)
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
                this.EndstopPort = EndstopPort;
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

            this.DatabasePath = DatabasePath;
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
                    this.Stepper = stepper(this.Shield, StepperMotorNum, StepsPerRevolution, "RPM", 5,"StepType", "Double");
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
                    this.CurrentSteps = this.CurrentSteps + Steps;
                    this.Log("Arduino: Stepper moved and released successfully!");
                else
                    this.Log("Arduino: Skipping stepper movement - debug state");
                end
            catch ERR
                disp("Error while moving Stepper");
                this.LogErr(ERR);
            end
        end
    end
    
    %% Endstop state
    methods
        function [this, state] = IsEndstopPressed(this)
            this.Log("Arduino: Reading endstop state");
            state = readDigitalPin(this.Arduino, this.EndstopPort);
        end

        function this = HomeBarBot(this, steps)
            this.Log("Arduino: BarBot is homing itself");

            while ~readDigitalPin(this.Arduino, this.EndstopPort)
                move(this.Stepper, steps);
                disp(readDigitalPin(this.Arduino, this.EndstopPort));
            end
            release(this.Stepper);

            this.CurrentSteps = 0;
            this.Log("Arduino: BarBot is at home position!");
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

    %% Database
    methods
        function [this, Connection] = DBConnection(this)
            try
                this.Log("Database: Creating Connection");
                Connection = sqlite(this.DatabasePath, "connect");
                this.Log("Database: Connection Created");
            catch ERR
                disp("Database: Error while connecting to Database");
                this.LogErr(ERR);
            end
        end

        function [this, Resources] = DBGetResources(this)
                [this, connection] = this.DBConnection();
            try
                this.Log("Database: Getting Resources");
                res = fetch(connection, 'SELECT * FROM `Resources`');
                Resources = Resource.empty(height(res),0);

                for i = 1 : height(res)
                    item = res(i,:);
                    Resources(i) = Resource(item.ID, item.Name, item.AlcoholNum, item.Position);
                end

                close(connection);
            catch ERR
                disp("Database: Error while getting resources");
                this.LogErr(ERR);
            end
        end

        function [this] = DBAddResource(this, Resource)
            [this, connection] = this.DBConnection();
            try
                this.Log("Inserting resource into database");
                insert(connection, 'Resources', {'Name', 'Alcoholic', 'AlcoholNum', 'Position'}, {Resource.GetName(), Resource.IsAlcoholic(), Resource.GetAlcoholNum(), Resource.GetPosition()})
                close(connection);
            catch ERR
                disp("Database: Error inserting resource intro database");
                this.LogErr(ERR);
            end
        end

        function [this, Drinks] = DBGetDrinks(this)
                [this, connection] = this.DBConnection();
            try
                this.Log("Database: Getting Drinks");
                Drinks = fetch(connection, 'SELECT * FROM `Drinks`');
                close(connection);
            catch ERR
                disp("Database: Error while getting Drinks");
                this.LogErr(ERR);
            end
        end
    end

    %% Other Functions
    methods
        function [this, Drinks] = GetValidDrinks(this)
            [this, nonAlcoholic] = this.DBGetResources();
            [this, alcoholic] = this.DBGetDrinks();

            disp(nonAlcoholic);
            disp(alcoholic);
           try
               this.Log("BarMaster: Getting list of valid drinks");
           catch ERR
               disp("BarMaster: Error while getting list of valid drinks");
               this.LogErr(ERR);
           end
        end
    end
end

