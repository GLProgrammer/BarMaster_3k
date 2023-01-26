clc, clear;

addpath UI\

%% Creating serial connection to BarMaster and waiting for its connection
status = "";
connectionArduino = serialport("COM3", 115200);

configureTerminator(connectionArduino, "CR/LF");
flush(connectionArduino);

configureCallback(connectionArduino, "terminator", @readDataFromSerial);
disp("Waiting For Connection...");

%% Callback function for receiving serial data
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

%% Main logic of BarMaster
function StartLogic(conn)
    disp("Connection Estabilished");
    running = true;
    % Creating new instance of GUI
    gui = GUI_exported(["/Pictures/Drinks/Cuba_libre.jpg",
             "/Pictures/Drinks/Gin_tonic.jpg",
             "/Pictures/Drinks/Vodka_dzus.jpg"], ...
             ["Cuba Libre", "Gin Tonic", "Džus Vodka"]);

    
    while(running)
        % Waiting for button press
        waitfor(gui, 'action');

        switch gui.action
            % Exit button is pressed
            case "end pushed"
                [gui, isOpen] = isGUIopen(gui);
                if(~isOpen)
                    running = false;
                end

            % Mix button is pressed;
            case "mix pushed"
                [gui, selected_drink] = getSelectedDrink(gui);
                gui = resetAction(gui);
                gui = toggleStandby(gui);
                MixDrink(conn, selected_drink);
                gui = toggleStandby(gui);

            % Roulette button is pressed
            case "roulette pushed"
                gui = resetAction(gui);
                gui = toggleStandby(gui);
                MixDrinkRoulette(conn);
                gui = toggleStandby(gui);
        end
    end

    disp("GUI bylo zavřeno");
    delete(gui);
end

%% Function for mixing drinks based on drink name
function MixDrink(conn, drink)
    disp("Míchám nápoj " + drink);
    % Loading positions of liquids from SQLite Database
    positions = loadFromDB(drink);

    % Homing BarMaster
    Home(conn);
    for i=1:length(positions)
        %Moving to position and pouring liquid
        MoveToPosition(conn, positions(i));
        pause(1);
        Pour(conn);
        pause(1);
    end

    disp("Mixing done");
end

%% Functions for running roulette and mixing liquids
function MixDrinkRoulette(conn)
    disp("Aktivována ruleta!");
    positions = roulette();

    Home(conn);
    for i=1:length(positions)
        disp(positions(i));
        MoveToPosition(conn, positions(i));
        pause(1);
        disp("Pouring");
        Pour(conn);
        disp("Done Pouring");
        pause(1);
    end

    disp("Roulette done");
end

function positions = roulette()
    locations = ["A", "B", "C", "D", "E", "F"];
    nums = randi([1 6], 3, 1);
    disp(nums);
    positions = locations(nums);
    disp(positions);
end

%% Function for homing BarMaster
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

%% Function for moving BarMaster to its coresponding locations
function MoveToPosition(conn, position)
    conn.write("M" + position, "string");
    done = false;
    while(~done)
        data = conn.readline();
        data = char(data);
        if(data == "M200")
            done = true;
            data = "";
            return;
        end
    end
    return;
end

%% Function for moving Servo and pouring liquids
function Pour(conn)
    conn.write("P", "string");
    done = false;
    while(~done)
        data = conn.readline();
        data = char(data);
        if(data == "P200")
            done = true;
            data = "";
        end
    end
end

%% Function for loading and parsing drinks from SQLite database
function positions = loadFromDB(drink)
    dbConn = sqlite("Server\resources\Drinks.db");
    positions = fetch(dbConn, "SELECT `Ingredients` FROM `Drinks` WHERE `Name`='" + drink + "'");
    positions = positions.Ingredients;
    disp(positions);
    positions = split(positions, "");
    positions = [positions(2), positions(3)];
end


