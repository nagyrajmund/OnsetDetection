function update_status(handles, text)
    set(handles.t_status, 'String', text);  
    drawnow();
end