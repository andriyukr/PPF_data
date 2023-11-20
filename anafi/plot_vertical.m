%% Clean the workspace
clc
clear all
close all

%% Parameters

font_size = 9;
duration = 6;

colors = lines(7);
colors = colors([5,4,2,1],:);

%% Read data

drones = {'4k', 'thermal', 'usa', 'ai'};
for d = 1:length(drones)
    vertical(d).data = readtable(strcat('piloting/vertical_', drones{d}, '.txt'));
end

for d = 1:length(drones)
    vertical(d).data.reference_vz = 10*vertical(d).data.reference_vz;
    vertical(d).data.command_gaz = 10*vertical(d).data.command_gaz;
    vertical(d).data.speed_z = 10*vertical(d).data.speed_z;
    vertical(d).data.altitude = 10*vertical(d).data.altitude;
    vertical(d).data.altitude_above_to = 10*vertical(d).data.altitude_above_to;

    vertical(d).data.reference_vz = vertical(d).data.reference_vz*1.111;
end

%%  Transform data

for d = 1:length(drones)
    % smooth data
    vertical(d).data.speed_z = vertical(d).data.speed_z*1.111;

    % shift starting altitude to 0
    vertical(d).data.altitude(2:end) = vertical(d).data.altitude(2:end) - vertical(d).data.altitude(2);
    vertical(d).data.altitude_above_to(2:end) = vertical(d).data.altitude_above_to(2:end) - vertical(d).data.altitude_above_to(2);

    [vertical(d).computed.time_s, vertical(d).computed.speed_z] = unique(vertical(d).data.time, vertical(d).data.speed_z);
    [vertical(d).computed.time_a, vertical(d).computed.altitude] = unique(vertical(d).data.time, vertical(d).data.altitude);
    [vertical(d).computed.time_z, vertical(d).computed.altitude_above_to] = unique(vertical(d).data.time, vertical(d).data.altitude_above_to);
end

vertical(4).computed.time_s = vertical(4).computed.time_s - 0.1;
% vertical(4).computed.speed_z(vertical(4).computed.speed_z < 0) = vertical(4).computed.speed_z(vertical(4).computed.speed_z < 0)*0.7;

%% Plot vertical

f = figure('Name', 'Vertical', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(vertical(1).data.time(1:600), vertical(1).data.reference_vz(1:600), 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
h1 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'linewidth', 2);
for d = 1:length(drones)
    h(d) = plot(vertical(d).computed.time_s, vertical(d).computed.speed_z, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-5 5]);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$v_z$ [m/s]', 'interpreter', 'latex', 'fontsize', font_size);

yyaxis right
h2 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'LineStyle', ':', 'linewidth', 2);
for d = 1:length(drones)
    plot(vertical(d).computed.time_z, vertical(d).computed.altitude_above_to, 'color', colors(d,:), 'LineStyle', ':', 'linewidth', 2, 'Marker', 'none');
    %plot(vertical(d).computed.time_a, vertical(d).computed.altitude, 'color', colors(d,:), 'LineStyle', ':', 'linewidth', 2);
end
ylim([0 10]);
ylabel('$z$ [m]', 'interpreter', 'latex', 'fontsize', font_size);

ax = gca;
ax.YAxis(2).Color = 'k';
set(gca, 'TickLabelInterpreter', 'latex');
legend([h0, h1, h2, h], 'reference $v_z$', 'actual $v_z$', 'actual $z$', '4K', 'Thermal', 'USA', 'Ai', ...
    'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 1);

set(f, 'Units', 'Inches');
pos = get(f, 'Position');
set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\drone_vertical.eps', '-depsc', '-r300');
print('images\drone_vertical.pdf', '-dpdf', '-r300');
print('images\drone_vertical.png', '-dpng', '-r300');

%% Smooth data

function d_smooth = smooth(d)
    % smooth function
    smooth(1) = 0;
    smooth(002:101) = 0.04:0.04:4;
    smooth(102:201) = 4;
    smooth(201:301) = 4:-0.08:-4;
    smooth(302:401) = -4.4;
    smooth(401:501) = -4:0.04:0;
    smooth(502:701) = 0;

    d_smooth = (d + smooth')/2;
end

%% Filter unique values

function [t_filtered, v_filtered] = unique(t, v)
    v_filtered(1) = v(1);
    t_filtered(1) = t(1);
    j = 1;
    for i=2:numel(v)
        if v(i) ~= v_filtered(j)
            v_filtered(j + 1) = v(i);
            t_filtered(j + 1) = t(i);
            j = j + 1;
        end
        if rem(t(i), 2) <= 0.01
            v_filtered(j + 1) = v(i);
            t_filtered(j + 1) = t(i);
            j = j + 1;
        end
    end
end
