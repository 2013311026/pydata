h = plot(0,0);
for m = 1:numel(VarName9)
set(h,'XData',linspace(1,m,m),'YData',VarName9(1:m));
drawnow;
pause(0.1);
end