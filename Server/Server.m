clc, clear;

addpath lib\

%% Creating Serial connection to BarBot
status = "";

connectionArduino = serialport("COM3", 115200);

configureTerminator(connectionArduino, "CR/LF");
flush(connectionArduino);

configureCallback(connectionArduino, "terminator", @readDataFromSerial);

disp("Waiting For Connection...");


function readDataFromSerial(src, ~)
    data = readline(src);
    if(data ~= "")
        switch data
            case "S200"
                status = "S200";
                data = "";
                StartLogic(src);
        end
    end
end

function StartLogic(conn)
    disp("Connection Estabilished");
    running = true;
    % TODO: OPEN GUI
    data = "STOP";
    while(running) 
        while(data == "")
        end

        switch(data)
            case "STOP"
                disp("STOPPING APP");
        
        end
    end

end

function Home(conn)
    conn.write("H", "string");
    done = false;
    while(~done)
        data = conn.readline();
        data = char(data);
        if(data == "H200")
            done = true;
            return;
        end
    end
    return;
end

function MoveToPosition(conn, position)
    conn.write("M" + position, "string");
    disp("M" + position);
    done = false;
    while(~done)
        data = conn.readline();
        data = char(data);
        if(data == "M200")
            done = true;
            return;
        end
    end
    return;
end
