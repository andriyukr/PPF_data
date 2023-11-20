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
    roll(d).data = readtable(strcat('piloting/roll_', drones{d}, '.txt'));
end

for d = 1:length(drones)
    roll(d).data.reference_roll = 10*roll(d).data.reference_roll;
    roll(d).data.command_roll = 10*roll(d).data.command_roll;
    roll(d).data.roll = 10*roll(d).data.roll;
    roll(d).data.roll_slow = 10*roll(d).data.roll_slow;
    roll(d).data.speed_y = 10*roll(d).data.speed_y;

    roll(d).data.reference_roll = roll(d).data.reference_roll*1.111;
end

%%  Transform data

for d = 1:length(drones)
    euler = quat2eul([roll(d).data.quaternion_w, roll(d).data.quaternion_x, roll(d).data.quaternion_y, roll(d).data.quaternion_z]);
    roll(d).data.quaternion_x = 10*rad2deg(euler(:,3));
    roll(d).data.quaternion_y = 10*rad2deg(euler(:,2));
    roll(d).data.quaternion_z = 10*rad2deg(euler(:,1));

    % smooth data
%     roll(d).data.quaternion_x = smooth(roll(d).data.quaternion_x);

    [roll(d).computed.time_r, roll(d).computed.roll] = unique(roll(d).data.time, roll(d).data.quaternion_x);
    [roll(d).computed.time_r1, roll(d).computed.roll1] = unique(roll(d).data.time, roll(d).data.roll);
    [roll(d).computed.time_r2, roll(d).computed.roll2] = unique(roll(d).data.time, roll(d).data.roll_slow);
    [roll(d).computed.time_s, roll(d).computed.speed_y] = unique(roll(d).data.time, roll(d).data.speed_y);

    roll(d).computed.roll(2:end) = roll(d).computed.roll(2:end) - roll(d).computed.roll(2);
    roll(d).computed.roll1(2:end) = roll(d).computed.roll1(2:end) - roll(d).computed.roll1(2);
    roll(d).computed.roll2(2:end) = roll(d).computed.roll2(2:end) - roll(d).computed.roll2(2);
    roll(d).computed.speed_y(2:end) = roll(d).computed.speed_y(2:end) - roll(d).computed.speed_y(2);
end

%% Plot pitch

f = figure('Name', 'Roll', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(roll(1).data.time(1:600), roll(1).data.reference_roll(1:600), 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
h_dumm = plot([0 0], [0 0], 'color', [1 1 1], 'linewidth', 2);
h1 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'linewidth', 2);
for d = 1:length(drones)
    h(d) = plot(roll(d).computed.time_r, roll(d).computed.roll, 'color', colors(d,:), 'linewidth', 2);
%     h(d) = plot(pitch(d).computed.time_r2, pitch(d).computed.roll2, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-50 50]);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\phi$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);

yyaxis right
h2 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'LineStyle', ':', 'linewidth', 2);
for d = 1:length(drones)
    plot(roll(d).computed.time_s, roll(d).computed.speed_y, 'color', colors(d,:), 'LineStyle', ':', 'linewidth', 2, 'Marker', 'none');
end
ylim([-10 10]);
ylabel('$v_y$ [m/s]', 'interpreter', 'latex', 'fontsize', font_size);

ax = gca;
ax.YAxis(2).Color = 'k';
set(gca, 'TickLabelInterpreter', 'latex');
legend([h0, h_dumm, h1, h2, h], ...
    'reference $\phi$', '', 'actual $\phi$', 'actual $v_y$', '4K', 'Thermal', 'USA', 'Ai', ...
    'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 2);

set(f, 'Units', 'Inches');
pos = get(f, 'Position');
set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\drone_roll.eps', '-depsc', '-r300');
print('images\drone_roll.pdf', '-dpdf', '-r300');
print('images\drone_roll.png', '-dpng', '-r300');

%% Smooth data

function d_smooth = smooth(d)
    % smooth function
    smooth(1) = 0;
    smooth(002:101) = 0.4:0.4:40;
    smooth(102:201) = 40;
    smooth(201:301) = 40:-0.8:-40;
    smooth(302:401) = -40;
    smooth(401:501) = -40:0.4:0;
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
