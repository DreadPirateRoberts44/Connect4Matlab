classdef Board
    
    properties
        %the actual state and visual
        board
        scene

        %the sprites used
        empty_sprite
        red_sprite
        black_sprite

        %conditions of the board
        game_won
        full

    end
    
    methods
        
        function obj = Board
            close all
            % Initialize scene
            obj.scene = simpleGameEngine('ConnectFour.png',86,101);
            % Set the various sprites
            obj.empty_sprite = 1;
            obj.red_sprite = 2;
            obj.black_sprite = 3;
            obj.board = obj.empty_sprite * ones(6,7);
        end

        function [dr_win, winner] = diag_right(obj)
        %   Checks wins in a diagonal at a downwards slope
        %   input: board
        %   output: dzr_win: if a diag was detected
        %           winner: which player won
            dr_win = false;
            winner = 0;
            streak = 0;
            player_streak = 0;
        
            start_column = 1;
            start_row = size(obj.board, 1) - 3;
        
            while((start_column < (size(obj.board, 2) - 3) ) && ~dr_win)
                j = start_column;
                i = start_row;
                while(i <= size(obj.board, 1) && j <= size(obj.board, 2) && ~dr_win)
                        if(obj.board(i, j) == 1)
                            streak = 0;
                        elseif(streak == 0)
                            streak = 1;
                            player_streak = obj.board(i,j);
                        elseif(player_streak == obj(i,j))
                            streak = streak + 1;
                        else 
                            streak = 1;
                            player_streak = obj(i,j);
                        end
                        if (streak == 4)
                            dr_win = true;
                            winner = player_streak;
                            break;
                        end
                        j = j + 1;
                        i = i + 1;
                end
                
                if(start_row > 1) 
                    start_row = start_row - 1;
                else
                    start_column = start_column + 1;
                end
            end
        
        end

        function [dl_win, winner] = diag_left(board)
        %   Checks wins in a diagonal at a downwards slope
        %   input: board
        %   output: dzr_win: if a diag was detected
        %           winner: which player won
            dl_win = false;
            winner = 0;
            streak = 0;
            player_streak = 0;
        
            start_column = 1;
            start_row = 4;
        
            while((start_column < (size(board, 2) - 3) ) && ~dl_win)
                j = start_column;
                i = start_row;
                while(i > 0 && j <= size(board, 2) && ~dl_win)
                        if(board(i, j) == 1)
                            streak = 0;
                        elseif(streak == 0)
                            streak = 1;
                            player_streak = board(i,j);
                        elseif(player_streak == board(i,j))
                            streak = streak + 1;
                        else 
                            streak = 1;
                            player_streak = board(i,j);
                        end
                        if (streak == 4)
                            dl_win = true;
                            winner = player_streak;
                            break;
                        end
                        j = j + 1;
                        i = i - 1;
                end
                
                if(start_row < size(board, 1) ) 
                    start_row = start_row + 1;
                else
                    start_column = start_column + 1;
                end
            end
        
        end
        
        function col_full = col_full(obj, col)
            % This function checks to see
            % if a column is full when a user tries to play
            % there, with the purpose of preventing users
            % from playing after the slots are filled
            col_full = obj.board(1,col) ~= 1;
        end
        
        function board_full = board_full(board)
            % This function checks if all the slots have been filled
            % This would be an end condition for the game
            % output: if all entries in the first row are 0 return true; else false
            board_full = true;
            for pos = 1:length(board)
                if(~col_full(board, pos))
                    board_full = false;
                    break;
                end
            end
        end
        
        function [hz_win, winner] = hz_win(board)
        % compartamentalizing the win criteria
        % output: hz_win-true if there's a four in a row, else false
        %         player - if there's a win, return the player who won
            hz_win = false;
            winner = 0;
            streak = 0;
            player_streak = 0;
            i = 1;
            while(i <= size(board, 1) && ~hz_win)
                j = 1;
                while(j <= size(board, 2))
                    if(board(i, j) == 1)
                        streak = 0;
                    elseif(streak == 0)
                        streak = 1;
                        player_streak = board(i,j);
                    elseif(player_streak == board(i,j))
                        streak = streak + 1;
                    else 
                        player_streak = board(i,j);
                        streak = 1;
                    end
                    if (streak == 4)
                        hz_win = true;
                        winner = player_streak;
                        break;
                    end
                    j = j + 1;
                end
                i = i + 1;
            end
        
        end
        
        function [vt_win, winner] = vt_win(board)
        % compartamentalizing the win criteria
        % output: vt_win-true if there's a four in a row, else false
        %         player - if there's a win, return the player who won
            vt_win = false;
            winner = 0;
            streak = 0;
            player_streak = 0;
            i = 1;
            while(i <= size(board, 2) && ~vt_win)
                j = 1;
                while(j <= size(board, 1))
                    if(board(j, i) == 1)
                        streak = 0;
                    elseif(streak == 0)
                        streak = 1;
                        player_streak = board(j,i);
                    elseif(player_streak == board(j,i))
                        streak = streak + 1;
                    else 
                        player_streak = board(i,j);
                        streak = 1;
                    end
                    if (streak == 4)
                        vt_win = true;
                        winner = player_streak;
                        break;
                    end
                    j = j + 1;
                end
                i = i + 1;
            end
        
        end
        
        function [game_won, winner] = check_win(board)
            % Checks if the game has been won
        % Checks the board to see if there are
        % four in a row sequences of non 0 items
        % inputs: the board
        % output: boolean on if the game has been won or not
        % winner: who won
        % could be improved; the game only needs to check around
        % the most recent move; but this logic is simpler
        % and on this scale speed is not an issue.
            [game_won, winner] = hz_win(board);
            if(~game_won)
                [game_won, winner] = vt_win(board);
            end
            if(~game_won)
                [game_won, winner] = diag_right(board);
            end
            if(~game_won)
                [game_won, winner] = diag_left(board);
            end
        end
    end

end