classdef GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BarMaster3000UIFigure  matlab.ui.Figure
        image_stand_by         matlab.ui.control.Image
        drink_image            matlab.ui.control.Image
        arrow_r                matlab.ui.control.Button
        arrow_l                matlab.ui.control.Button
        end_prog               matlab.ui.control.Button
        mix                    matlab.ui.control.Button
        ruleta                 matlab.ui.control.Button
        personalised           matlab.ui.control.Button
        Image                  matlab.ui.control.Image
    end

    
    properties (Access = public)
         current_drink % Holds the info about the currently selected drink
         drinks % Vector of all drinks
         drink_array % Vector of relative locations of drink pictures
         action = "" % Action based on button pressed
         running = 1 % Property for storing state of window
    end
    

    % Callbacks that handle component events
    methods (Access = private)
        % Button pushed function: end_prog
        function end_progButtonPushed(app, event)
            app.running = 0;
            app.action = "end pushed";
        end

        % Button pushed function: arrow_r
        function arrow_rButtonPushed(app, event)
            app.drink_array = circshift(app.drink_array, 1);
                app.drinks = circshift(app.drinks, 1);
                app.current_drink = app.drinks(1);
                app.drink_image.ImageSource = imread(pwd + "\UI" + app.drink_array(1));
        end

        % Button pushed function: arrow_l
        function arrow_lButtonPushed(app, event)
            app.drink_array = circshift(app.drink_array, -1);
                app.drinks = circshift(app.drinks, -1);
                app.current_drink = app.drinks(1);
                app.drink_image.ImageSource = imread(pwd + "\UI" + app.drink_array(1));
        end

        % Button pushed function: mix
        function mixButtonPushed(app, event)
            app.current_drink = app.drinks(1);
            app.action = "mix pushed";
        end

        % Button pushed function: roulette
        function rouletteButtonPushed(app, event)
            app.action = "roulette pushed";
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create BarMaster3000UIFigure and hide until all components are created
            app.BarMaster3000UIFigure = uifigure('Visible', 'off');
            app.BarMaster3000UIFigure.Color = [1 1 1];
            app.BarMaster3000UIFigure.Position = [100 100 730 565];
            app.BarMaster3000UIFigure.Name = 'BarMaster 3000';
            app.BarMaster3000UIFigure.Icon = fullfile(pathToMLAPP, 'Pictures', 'Icon.png');
            app.BarMaster3000UIFigure.Resize = 'off';
            app.BarMaster3000UIFigure.HandleVisibility = 'on';

            % Create Image
            app.Image = uiimage(app.BarMaster3000UIFigure);
            app.Image.ScaleMethod = 'fill';
            app.Image.Position = [1 1 730 565];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'Pictures', 'Background_img.jpg');

            % Create personalised
            app.personalised = uibutton(app.BarMaster3000UIFigure, 'push');
            app.personalised.BackgroundColor = [0.1098 0.2784 0.6196];
            app.personalised.FontName = 'Gill Sans MT';
            app.personalised.FontSize = 24;
            app.personalised.FontWeight = 'bold';
            app.personalised.Position = [38 485 144 53];
            app.personalised.Text = 'Vlastní';
            app.personalised.Visible = "off";

            % Create ruleta
            app.ruleta = uibutton(app.BarMaster3000UIFigure, 'push');
            app.ruleta.BackgroundColor = [0.1098 0.2784 0.6196];
            app.ruleta.ButtonPushedFcn = createCallbackFcn(app, @rouletteButtonPushed, true);
            app.ruleta.FontName = 'Gill Sans MT';
            app.ruleta.FontSize = 24;
            app.ruleta.FontWeight = 'bold';
            app.ruleta.Position = [549 485 144 53];
            app.ruleta.Text = 'Ruleta';

            % Create mix
            app.mix = uibutton(app.BarMaster3000UIFigure, 'push');
            app.mix.ButtonPushedFcn = createCallbackFcn(app, @mixButtonPushed, true);
            app.mix.BackgroundColor = [0.1098 0.2784 0.6196];
            app.mix.FontName = 'Gill Sans MT';
            app.mix.FontSize = 24;
            app.mix.FontWeight = 'bold';
            app.mix.Position = [293 48 147 53];
            app.mix.Text = 'Namíchat';

            % Create end_prog
            app.end_prog = uibutton(app.BarMaster3000UIFigure, 'push');
            app.end_prog.ButtonPushedFcn = createCallbackFcn(app, @end_progButtonPushed, true);
            app.end_prog.BackgroundColor = [0.1098 0.2784 0.6196];
            app.end_prog.FontName = 'Gill Sans MT';
            app.end_prog.FontSize = 24;
            app.end_prog.FontWeight = 'bold';
            app.end_prog.FontColor = [0.6353 0.0784 0.1843];
            app.end_prog.Position = [38 36 144 53];
            app.end_prog.Text = 'Ukončit';

            % Create arrow_l
            app.arrow_l = uibutton(app.BarMaster3000UIFigure, 'push');
            app.arrow_l.ButtonPushedFcn = createCallbackFcn(app, @arrow_lButtonPushed, true);
            app.arrow_l.BackgroundColor = [0.1098 0.2784 0.6196];
            app.arrow_l.FontSize = 36;
            app.arrow_l.FontWeight = 'bold';
            app.arrow_l.Position = [148 255 36 57];
            app.arrow_l.Text = '<';

            % Create arrow_r
            app.arrow_r = uibutton(app.BarMaster3000UIFigure, 'push');
            app.arrow_r.ButtonPushedFcn = createCallbackFcn(app, @arrow_rButtonPushed, true);
            app.arrow_r.BackgroundColor = [0.1098 0.2784 0.6196];
            app.arrow_r.FontSize = 36;
            app.arrow_r.FontWeight = 'bold';
            app.arrow_r.Position = [548 255 36 57];
            app.arrow_r.Text = '>';

            % Create drink_image
            app.drink_image = uiimage(app.BarMaster3000UIFigure);
            app.drink_image.Position = [206 123 320 320];
            app.drink_image.ImageSource = fullfile(pathToMLAPP, 'Pictures', 'Drinks', 'Cuba_libre.jpg');

            % Create image_stand_by
            app.image_stand_by = uiimage(app.BarMaster3000UIFigure);
            app.image_stand_by.ScaleMethod = 'fill';
            app.image_stand_by.Visible = 'off';
            app.image_stand_by.Position = [1 1 730 565];
            app.image_stand_by.ImageSource = fullfile(pathToMLAPP, 'Pictures', 'Stand_by.png');

            % Show the figure after all components are created
            app.BarMaster3000UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI_exported(images, drinks)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BarMaster3000UIFigure)
            
            app.drink_array = images;
            app.drinks = drinks;

            if nargout == 0
                clear app
            end
        end

        function [app, isOpen] = isGUIopen(app)
            isOpen = app.running;
        end

        function [app, selectedDrink] = getSelectedDrink(app)
            selectedDrink = app.current_drink;
        end

        function [app, action] = getAction(app)
            action = app.action;
        end

        function app = resetAction(app)
            app.action = "";
        end

        function app = toggleStandby(app)
            if(app.image_stand_by.Visible == "off")
                app.image_stand_by.Visible ="on";
            else
                app.image_stand_by.Visible = "off";
            end
        end
        
        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.BarMaster3000UIFigure)
        end
    end
end