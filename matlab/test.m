function test(N)

for n = 1:N
if (~mod(n,2) & ~mod(n,7)) disp('TWO-SEVEN');
elseif (~mod(n,7)) disp('SEVEN');
elseif (~mod(n,2)) disp('TWO');
else disp('NOTHING');
end
end