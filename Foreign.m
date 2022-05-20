function [dl_win, winner] = diag_left(board, start_row, start_col)
%   Checks wins in a diagonal at a upwards slope
%   input: board
%   output: dzr_win: if a diag was detected
%           winner: which player won
    dl_win = false;
    winner = 0;
    streak = 0;
    player_streak = 0;

    col = max([1, start_col - 3]);
    row = min([size(board, 1), start_row + 3]);

    end_col = min([size(board, 2), start_col + 3]);
    end_row = max(1, start_row - 3);

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
