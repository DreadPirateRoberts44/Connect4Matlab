clc;
clear;
close all;
[y,Fs] = audioread('clink_edit.wav');
sound(y,Fs)
% Initialize scene
my_scene = simpleGameEngine('ConnectFour.png',86,101);

% Set the various sprites
empty_sprite = 1;
red_sprite = 2;
black_sprite = 3;

% Display empty board   
board = empty_sprite * ones(6,7);
drawScene(my_scene,board)

name = "Mike";
player = 3;

p1 = HumanPlayer(name, player);

p1.name
p1.player

b = Board;

p1.player_move(b)