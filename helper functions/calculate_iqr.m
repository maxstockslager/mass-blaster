function iqr = calculate_iqr(x)
if length(x) == 0
    iqr = 0;
else

    x = sort(x);
    ind1 = ceil(0.25*length(x));
    ind2 = ceil(0.75*length(x));
    iqr = x(ind2)-x(ind1);
end
