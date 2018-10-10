clc;
h = plot(0,0);
for m = 1:numel(VarName9)
    set(h,'XData',linspace(1,m,m),'YData',VarName9(1:m));
    pause(0.01);
    frame=getframe(gcf);
    imind=frame2im(frame);
    [imind,cm] = rgb2ind(imind,256);
    if m==1
         imwrite(imind,cm,'an.gif','gif', 'Loopcount',inf,'DelayTime',1e-4);
    else
         imwrite(imind,cm,'an.gif','gif','WriteMode','append','DelayTime',1e-4);
    end
end