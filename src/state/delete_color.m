function delete_color(axis, c)
    old_marker = findobj(axis, 'Color', c);
    delete(old_marker);
end