
classdef HumanPlayer
    
    properties
        name
        player
    end
    
    methods

        function obj = HumanPlayer(player_name, sprite)
            obj.name = player_name;
            obj.player = sprite;
        end
        
        function row = drop(obj, column, b)
        % Drops the row position to the bottom of the board 
        % in its column
        % requires that the column is not full
        % input: column to place the move, and the board
            row = 1;
            while( (row + 1) < size(b.board, 2) && b.board(row + 1, column) == 1)
                b.board(row, column) = obj.player;
                drawScene(b.scene, b.board);
                pause(0.1);
                row = row + 1;
                b.board(row-1, column) = 1;
            end
            
        end

        function [row, column] = player_move(~, b)
        % This gets the move from a human player
        % inputs: board - the board object
        %         player_no - which player is up
        %
        % outputs: the row and column the move was placed in
            drawScene(b.scene, b.board);
            [~, column] = getMouseInput(b.scene);
            while b.col_full(column)
                [~, column] = getMouseInput(b.scene);
            end
            row = drop(column, b);
        end
        

    end

end