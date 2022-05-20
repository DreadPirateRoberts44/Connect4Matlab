[y,Fs] = audioread('clink.m4a');


y = y(68000:105800,:);

audiowrite('clink_edit.wav',y,Fs)
sound(y,Fs)
