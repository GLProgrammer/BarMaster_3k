classdef Resource

    properties (Access = private)
        ID
        Name
        AlcoholNum
        Position
    end
    
    methods
        function this = Resource(ID, Name, AlcoholNum, Position)
            this.ID = ID;
            this.Name = Name;
            this.AlcoholNum = AlcoholNum;
            this.Position = Position;
        end
        
        function [this, ID] = GetID(this)
            ID = this.ID;
        end

        function [this, Name] = GetName(this)
            Name = this.Name;
        end
        
        function [this, Alcoholic] = IsAlcoholic(this)
            if this.AlcoholNum > 0
                Alcoholic = true;
            else
                Alcoholic = false;
            end
        end

        function [this, AlcoholNum] = GetAlcoholNum(this)
            AlcoholNum = this.AlcoholNum;
        end

        function [this, Position] = getPosition(this)
            Position = this.Position;
        end

        function [this, Active] = IsActive(this)
            if this.Position > 0
                Active = 1;
            else
                Active = 0;
            end
        end

        function [this] = Activate(this, Position)
            this.Position = Position;
        end

        function [this] = Deactivate(this)
            this.Position = 0;
        end
    end
end

