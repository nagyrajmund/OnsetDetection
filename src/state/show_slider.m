function show_slider(~, ~, player, p, to_seconds)
    delete_color(p, 'g');
    
    if player.isplaying
        x = player.CurrentSample * to_seconds;
        plot(p, [x,x], get(p,'YLim'), 'g');
    end
end
