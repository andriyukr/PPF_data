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
    pitch(d).data = readtable(strcat('piloting/pitch_', drones{d}, '.txt'));
end

for d = 1:length(drones)
    pitch(d).data.reference_pitch = 10*pitch(d).data.reference_pitch;
    pitch(d).data.command_pitch = 10*pitch(d).data.command_pitch;
    pitch(d).data.pitch = 10*pitch(d).data.pitch;
    pitch(d).data.pitch_slow = 10*pitch(d).data.pitch_slow;
    pitch(d).data.speed_x = 10*pitch(d).data.speed_x;

    pitch(d).data.reference_pitch = pitch(d).data.reference_pitch*1.111;
end

%%  Transform data

for d = 1:length(drones)
    euler = quat2eul([pitch(d).data.quaternion_w, pitch(d).data.quaternion_x, pitch(d).data.quaternion_y, pitch(d).data.quaternion_z]);
    pitch(d).data.quaternion_x = 10*rad2deg(euler(:,3));
    pitch(d).data.quaternion_y = 10*rad2deg(euler(:,2));
    pitch(d).data.quaternion_z = 10*rad2deg(euler(:,1));

    % smooth data
    pitch(d).data.quaternion_y = smooth(pitch(d).data.quaternion_y);

    [pitch(d).computed.time_p, pitch(d).computed.pitch] = unique(pitch(d).data.time, pitch(d).data.quaternion_y);
    [pitch(d).computed.time_p1, pitch(d).computed.pitch1] = unique(pitch(d).data.time, pitch(d).data.pitch);
    [pitch(d).computed.time_p2, pitch(d).computed.pitch2] = unique(pitch(d).data.time, pitch(d).data.pitch_slow);
    [pitch(d).computed.time_s, pitch(d).computed.speed_x] = unique(pitch(d).data.time, pitch(d).data.speed_x);

    pitch(d).computed.pitch(2:end) = pitch(d).computed.pitch(2:end) - pitch(d).computed.pitch(2);
    pitch(d).computed.pitch1(2:end) = pitch(d).computed.pitch1(2:end) - pitch(d).computed.pitch1(2);
    pitch(d).computed.pitch2(2:end) = pitch(d).computed.pitch2(2:end) - pitch(d).computed.pitch2(2);
    pitch(d).computed.speed_x(2:end) = pitch(d).computed.speed_x(2:end) - pitch(d).computed.speed_x(2);
end


%% Plot pitch

f = figure('Name', 'Pitch', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(pitch(1).data.time(1:600), pitch(1).data.reference_pitch(1:600), 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
h1 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'linewidth', 2);
for d = 1:length(drones)
    h(d) = plot(pitch(d).computed.time_p, pitch(d).computed.pitch, 'color', colors(d,:), 'linewidth', 2);
%     h(d) = plot(pitch(d).computed.time_p2, pitch(d).computed.pitch2, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-50 50]);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\theta$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);

yyaxis right
h2 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'LineStyle', ':', 'linewidth', 2);
for d = 1:length(drones)
    plot(pitch(d).computed.time_s, pitch(d).computed.speed_x, 'color', colors(d,:), 'LineStyle', ':', 'linewidth', 2, 'Marker', 'none');
end
ylim([-10 10]);
ylabel('$v_x$ [m/s]', 'interpreter', 'latex', 'fontsize', font_size);

ax = gca;
ax.YAxis(2).Color = 'k';
set(gca, 'TickLabelInterpreter', 'latex');
legend([h0, h1, h2, h], 'reference $\theta$', 'actual $\theta$', 'actual $v_x$', '4K', 'Thermal', 'USA', 'Ai', ...
    'Orientation', 'horizontal', 'Location', 'southwest', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 1);

set(f, 'Units', 'Inches');
pos = get(f, 'Position');
set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\drone_pitch.eps', '-depsc', '-r300');
print('images\drone_pitch.pdf', '-dpdf', '-r300');
print('images\drone_pitch.png', '-dpng', '-r300');

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
