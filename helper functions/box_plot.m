function myBoxPlot2(data, x, color)

boxWidth = 0.3;
capWidth = 0.1;
% color = 'k';
LineWidth = 1; 

meanVal = mean(data);
medianVal = median(data);
top = prctile(data, 75);
bottom = prctile(data, 25);
topBar = prctile(data, 90);
bottomBar = prctile(data, 10);

% draw outer box
left = x - boxWidth;
right = x + boxWidth;
plot([left, right], [bottom, bottom], 'Color', color, 'LineWidth', LineWidth); % bottom
hold on
plot([left, right], [top, top], 'Color', color, 'LineWidth', LineWidth); % top
plot([left, left], [top, bottom], 'Color',  color, 'LineWidth', LineWidth); % left
plot([right, right], [top, bottom], 'Color', color, 'LineWidth', LineWidth); % right
plot([x, x], [top, topBar], 'Color', color, 'LineWidth', LineWidth); % top error bar
plot([x, x], [bottom, bottomBar], 'Color', color, 'LineWidth', LineWidth); % bottom error bar
plot([left, right], [medianVal, medianVal], 'Color', color, 'LineWidth', LineWidth); % median
plot([x - capWidth, x + capWidth], [topBar, topBar], 'Color', color, 'LineWidth', LineWidth); % top cap
plot([x - capWidth, x + capWidth], [bottomBar, bottomBar], 'Color', color, 'LineWidth', LineWidth); % lower cap

% plot the mean as a small box
w = 0.03;
plot(x, meanVal, 's', 'Color', color, 'MarkerSize', 5);