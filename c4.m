clc
clear
close all


% Load audio
[y,Fs] = audioread('clink_edit.wav');

% Initialize scene
my_scene = simpleGameEngine('ConnectFour.png',86,101);

% Set the various sprites
empty_sprite = 1;
red_sprite = 2;
black_sprite = 3;

% Set the human/computer player val
human = 1;
computer = 2;

% Set Game difficulty
difficulty = 6;
streak = 0;
play = 1;

game_modes = ["PVP", "AI Human First", "AI First"];
last_mode = game_modes(2);

while(play)
    
    % Set up the order of the players   % would like this to have a better UI
    mode = questdlg("Pick Mode", "Game Setup", ...
        game_modes(1), game_modes(2), game_modes(3), last_mode);
    switch mode
        case game_modes(2)
            players = [human, computer];
            last_mode = game_modes(2);
        case game_modes(3)
            players = [computer, human];
            last_mode = game_modes(3);
        
        case game_modes(1) % if they don't want a computer,
                           % both players are humans
            players = [human, human];
            last_mode = game_modes(1);
            streak = 0;
    end
    
    % create a similar structure for the sprites
    player_sprites = [red_sprite, black_sprite];
    
    % Display empty board   
    board = empty_sprite * ones(6,7);
    drawScene(my_scene,board)
    
    game_won = false;
    full = false;
    
    current_player = 0;
    
    turn_num = 1;
    while (~game_won && ~full)
       
        % check if current player is human or cpu
        % and call approiate move
        if(players(current_player + 1) == human)
            [row,col] = player_move(board, my_scene, player_sprites(current_player + 1));
        else
            open_moves = get_moves(board);
            [row, col] = com_turn(open_moves, board, player_sprites(current_player + 1), difficulty, turn_num);
            drop(col, board, player_sprites(current_player + 1), my_scene);
        end

        % Play drop sound: 
        sound(y, Fs);
        
        % update and display board
        board(row, col) = player_sprites(current_player + 1);
        drawScene(my_scene, board)
        
        pause(.05); % this hides some of the compute time of the cpu
                    % (the players move would actually pause for a moment
                    %   while cpu thinks)
    
        [game_won, winner] = check_win(board, row, col); %reset end conditions
        full = board_full(board);
    
        % Switch current player and sprite position
        current_player = mod(current_player + 1, 2);
        turn_num = turn_num + 1;
    end
    winner = winner - 1;
    
    reprompt_text = "Play Again?";
    % output appropriate win message
    % and update the streak
    if(winner == -1)
        reprompt_text = "It's a draw! " + reprompt_text;
    elseif (players(winner) == computer)
        
        streak = streak - 1;
 
        reprompt_text = "Computer Wins " + reprompt_text;
    else 
        if(streak < 0)
            streak = 0;
        else 
            streak = streak + 1; % will be reset if they switch to a pvp
        end
        reprompt_text = "Player " + winner + " wins! " + reprompt_text;
    end
close all

    % if the player builds enough of a win/lose streak
    % adjust the difficulty and reset the streak
    if(ismember(computer, players))
        if(streak > 0 && difficulty < 6)
            %fprintf("Time to step it up!\n")
            %hide difficulty curve
            difficulty = difficulty + 1;
            streak = 0;
        elseif(streak < -2 && difficulty > 1)
            %fprintf("Let's ease up a bit\n");
            %hide difficulty curve
            difficulty = difficulty - 1;
            streak = 0;
        end
    end
    if(questdlg(reprompt_text, "Restart", "Yes", "No", "Yes") == "No")
        play = 0;
    end
    
end

function [dr_win, winner] = diag_right(board, start_row, start_col)
%   Checks wins in a diagonal at a downwards slope
%   input: board
%   output: dzr_win: if a diag was detected
%           winner: which player won
    dr_win = false;
    winner = 0;
    player_streak = 0;
    streak = 0;

    % find the start and ending positions needed to search
    % for the given move
    if (start_col < start_row)
        col = max([1, start_col - 3]);
        row = max([1, start_row - (start_col - col)]);
        end_col = min([size(board, 2), start_col + 3]);
        end_row = min([size(board, 1), start_row + (end_col - start_col)]);
    else
        row = max([1, start_row - 3]);
        col = max([1, start_col - (start_row - row)]);
        end_row = min([size(board, 1), start_row + 3]);
        end_col = min([size(board, 2), start_col + (end_row - start_row)]);
    end

    while(col <= end_col && row <= end_row)
        if(board(row, col) == 1)
            streak = 0;
        elseif(streak == 0)
            streak = 1;
            player_streak = board(row,col);
        elseif(player_streak == board(row,col))
            streak = streak + 1;
        else 
            player_streak = board(row,col);
            streak = 1;
        end
        if (streak == 4)
            dr_win = true;
            winner = player_streak;
            break;
        end
        row = row + 1;
        col = col + 1;
    end    

end

function [dl_win, winner] = diag_left(board, start_row, start_col)
%   Checks wins in a diagonal at a upwards slope
%   input: board
%   output: dzr_win: if a diag was detected
%           winner: which player won
    dl_win = false;
    winner = 0;
    streak = 0;
    player_streak = 0;
    
    
    col_dif = start_col - 1;
    row_dif = 6 - start_row;
    
    if (col_dif < row_dif)
        col = max([1, start_col - 3]);
        row = max([1, start_row + (start_col - col)]);
        end_col = min([size(board, 2), start_col + 3]);
        end_row = max([1, start_row - (end_col - start_col)]);
    else
        row = min([size(board, 1), start_row + 3]);
        col = max([1, start_col - (row - start_row)]);
        end_row = max([1, start_row - 3]);
        end_col = min([size(board, 2), start_col + (start_row - end_row)]);
    end

    while(col <= end_col && row >= end_row)
        if(board(row, col) == 1)
            streak = 0;
        elseif(streak == 0)
            streak = 1;
            player_streak = board(row,col);
        elseif(player_streak == board(row,col))
            streak = streak + 1;
        else 
            player_streak = board(row,col);
            streak = 1;
        end
        if (streak == 4)
            dl_win = true;
            winner = player_streak;
            break;
        end
        row = row - 1;
        col = col + 1;
    end  

end

function col_full = col_full(board, col)
    % This function checks to see
    % if a column is full when a user tries to play
    % there, with the purpose of preventing users
    % from playing after the slots are filled
    col_full = board(1,col) ~= 1;
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

function [hz_win, winner] = hz_win(board, row, start_col)
% compartamentalizing the win criteria
% output: hz_win-true if there's a four in a row, else false
%         player - if there's a win, return the player who won
    hz_win = false;
    winner = 0;
    streak = 0;
    player_streak = 0;
    col = max([start_col - 3, 1]);
    last = min([start_col + 3, size(board,2)]);
    while(col <= last)
        if(board(row, col) == 1)
            streak = 0;
        elseif(streak == 0)
            streak = 1;
            player_streak = board(row,col);
        elseif(player_streak == board(row,col))
            streak = streak + 1;
        else 
            player_streak = board(row,col);
            streak = 1;
        end
        if (streak == 4)
            hz_win = true;
            winner = player_streak;
            break;
        end
        col = col + 1;
    end    
end

function [vt_win, winner] = vt_win(board, start_row, col)
% compartamentalizing the win criteria
% output: vt_win-true if there's a four in a row, else false
%         player - if there's a win, return the player who won
    vt_win = false;
    winner = 0;
    streak = 0;
    player_streak = 0;
    row = max([start_row - 3, 1]);
    last = min([size(board, 1), start_row + 3]);
    while(row <= last)
        if(board(row, col) == 1)
            streak = 0;
        elseif(streak == 0)
            streak = 1;
            player_streak = board(row,col);
        elseif(player_streak == board(row,col))
            streak = streak + 1;
        else 
            player_streak = board(row,col);
            streak = 1;
        end
        if (streak == 4)
            vt_win = true;
            winner = player_streak;
            break;
        end
        row = row + 1;
    end
end

function [game_won, winner] = check_win(board, row, col)
% Checks if the game has been won
% Checks the board to see if there are
% four in a row sequences of non 0 items
% inputs: the board
%         row, col - the position of the last move
% output: boolean on if the game has been won or not
% winner: who won
    [game_won, winner] = hz_win(board, row, col);
    if(~game_won)
        [game_won, winner] = vt_win(board, row, col);
    end
    if(~game_won)
        [game_won, winner] = diag_right(board, row, col);
    end
    if(~game_won)
        [game_won, winner] = diag_left(board, row, col);
    end
end

function row = drop(column, board, player, scene)
% Drops the row position to the bottom of the board 
% in its column
% requires that the column is not full
% input: column to place the move, and the board
    row = 1;
    while( (row + 1) < size(board, 2) && board(row + 1, column) == 1)
        board(row, column) = player;
        drawScene(scene, board);
        pause(0.05);
        row = row + 1;
        board(row-1, column) = 1;
    end
    
end

function [row, column] = player_move(board, scene, player)
% This gets the move from a human player
% inputs: board - the board object
%         player_no - which player is up
%
% outputs: the row and column the move was placed in

    [~, column] = getMouseInput(scene);
    while col_full(board, column)
        [~, column] = getMouseInput(scene);
    end
    row = drop(column, board, player, scene);
end

function row = bottom(column, board)
% Drops the row position to the bottom of the board 
% in its column
% requires that the column is not full
% input: column to place the move, and the board
    row = 1;
    while( (row + 1) < size(board, 2) && board(row + 1, column) == 1)
        row = row + 1;
    end
    
end

function [open_moves] = get_moves(board)
% Gets all the open moves on the board
% Input: board object
% Output: open_moves - N X 2 matrix, where each
%                      row is the (row, column) coordinate
%                      representing a move
    open_moves = [];
    column = 1;
    while column <= size(board, 2)
        
        if ~col_full(board, column)
            open_moves(end + 1,:) = [bottom(column, board), column];
        end
        column = column + 1;
    end


end

% This function was abandoned for a true AI algorithm.
%{
function [priority] = calc_priority(board, row, col, sprite)
% Determines a priority for the AI
% The highest priority is if a move wins the game
% Then if a move stops the opponent from winning the game
% Then if it is below a winning move
% Then a value based on sum of streaks it would create for itself
% Then a value based on sum of streaks it stops for the oppnonent
% Should also favor the lower center of the board
% The last three criteria are open to change
% Inputs: the board row and column
% An integer representation of the priority of the move
    
    priority = 0;
    [game_won, winner] = check_win(board, row, col);
    % add priorty if game was won(higher if computer wins)
    if (game_won)
        if(winner == sprite)
            priority = 10;
        else
            priority = 9;
        end
        return; % no point in checking anything else
                % if this wins the game play it, and if it stops a win
                % the only thing taking priority
                % would be another space winning, but the rest of this 
                % spaces properties wouldn't matter
    end

    % check if playing below a winning move
    if(row > 1)
        [below_win, winner] = check_win(row - 1, col);
        if(below_win)
            if(winner ~= sprite)
               priority = -10; 
               return; % no need to check anything, 
                       % playing here gives oppenent a win
            else
                priority = -3; % not a deal breaker, but 
                               % ideally avoided
            end
        end
    end
end
%}

function [priority] = calc_priority(board, row, col, active_player, ...
                                        depth, turns_player)
% Play the game several moves in advance, for all possible moves
% 
% Input: board
%       row, col - position of potential move
%       active_player - who is making this hypothetical move
%       depth - used as a limit on foresight
%       turns_player - the player that is actually doing this analysis
% If the player using this method wins, return 0, if the other player wins
% subtract 2
% ties are worth -1
    
    priority = 0;
    
    % leave after certain depth(in case computation is too slow)
    if (depth == 0)
        return;
    else
        depth = depth - 1;
    end

    board(row, col) = active_player; % play the current move

    [won, winner] = check_win(board, row, col);
    
    % if the game was won, return 0 if the winner
    % is the player doing this search(computer)
    % and -2 if the other player wins
    % -1 on tie
    if(won || board_full(board))
        
        if(winner == turns_player)
            priority = 0;
        elseif(winner ~= 0)
            priority = -2;
        else
            priority = -1;
        end
        return; % no further action needed win/full is an end condition
    end
    
    %switch the active player
    if active_player == 2
        active_player = 3;
    else
        active_player = 2;
    end

    moves = get_moves(board);
    
    % Make recursive calls for all open moves
    for i = 1:size(moves, 1)
        priority = priority + calc_priority(board, moves(i, 1), ...
            moves(i, 2), active_player, depth, turns_player);
    end
    
    priority = priority / 10;

end

function value = max(board, )

function [row, col] = com_turn(open_moves, board, player_num, difficulty, ...
                                turn_num)
% Returns the row and column the computer
% player plays at
% Input: open_moves - list of possible moves
%        board
%        player_num - which player is playing
%        difficulty - how many moves ahead the player looks
%        turn_num - which turn of the game this is(really only needed for 
%                                                  the first turn)
% Output: row and col of move made
    
    % if making the first move, play in the middle
    if(turn_num == 1)
        row = size(board, 1);
        col = round((size(board, 2) / 2));
        return;
    end

    priorities = [];
    depth = difficulty;

    % Take the priority for each available move
    for i = 1:size(open_moves, 1)
        priorities(i) = calc_priority(board, open_moves(i, 1), ...
            open_moves(i, 2), player_num, depth, player_num);
    end
    
    % Use the highest priority move
    [~, index] = max(priorities);
    row = open_moves(index, 1);
    col = open_moves(index, 2);

end
