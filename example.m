clc
clear


% Initialize scene
my_scene = simpleGameEngine('ConnectFour.png',86,101);

% Set up variables to name the various sprites
empty_sprite = 1;
red_sprite = 2;
black_sprite = 3;

% Display empty board   
board_display = empty_sprite * ones(6,7);
drawScene(my_scene,board_display)

% Player 1 drops Red chip in Col 1 which drops down to row 6
board_display(6,1) = red_sprite;
drawScene(my_scene,board_display)

% Player 2 drops Black chip in Col 2 which drops down to row 6
board_display(6,2) = black_sprite;
drawScene(my_scene,board_display)

% Player 1 drops Red chip in Col 1 which drops down to row 5
board_display(5,1) = red_sprite;
drawScene(my_scene,board_display)