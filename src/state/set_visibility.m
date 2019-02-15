function set_visibility(buttons, value)
    for i = 1 : length(buttons)
        try
            set(buttons(i),'Visible',value);
        catch
            warning('Invalid button passed to set_visibility()');
        end
    end
end
