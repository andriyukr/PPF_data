%% Clean the workspace
clc
clear all
close all

%% Parameters

font_size = 13;
duration = 9;

colors = linspecer(5, 'sequential');
colors = colors([1,2,4,5],:);

% N = 5;
% X = [0, 1];
% C = linspecer(N, 'sequential');
% hold off;
% for ii=1:N
%     Y = [ii, ii];
%     plot(X,Y,'color',C(ii,:),'linewidth',10);
%     hold on;
% end
% return

colors = lines(7);
colors = colors([5,4,2,1],:);

%% Read data

drones = {'4k', 'thermal', 'usa', 'ai'};
for d = 1:length(drones)
    roll_relative(d).data = readtable(strcat('gimbal/roll_relative_', drones{d}, '.txt'));
    pitch_relative(d).data = readtable(strcat('gimbal/pitch_relative_', drones{d}, '.txt'));
    pitch_absolute(d).data = readtable(strcat('gimbal/pitch_absolute_', drones{d}, '.txt'));
end

%%  Transform data

for d = 1:4
    [roll_relative(d).time, roll_relative(d).roll] = unique(roll_relative(d).data.time, roll_relative(d).data.relative_roll);
    [pitch_relative(d).time, pitch_relative(d).pitch] = unique(pitch_relative(d).data.time, pitch_relative(d).data.relative_pitch);
    [pitch_absolute(d).time, pitch_absolute(d).pitch] = unique(pitch_absolute(d).data.time, pitch_absolute(d).data.absolute_pitch);
end

%% Compute the error



%% Print MAE



%% Plot roll relative

f = figure('Name', 'Roll relative', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(roll_relative(1).data.time, roll_relative(1).data.command_roll, 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
h1 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'linewidth', 2);
for d = 1:length(drones)
    h(d) = plot(roll_relative(d).time, roll_relative(d).roll, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-40 40]);
legend([h0, h1, h], 'reference', 'actual', '4K', 'Thermal', 'USA', 'Ai', 'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 2);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\phi_G$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);
set(gca, 'TickLabelInterpreter', 'latex');

% set(f, 'Units', 'Inches');
% pos = get(f, 'Position');
% set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\gimbal_roll_relative_position.eps', '-depsc', '-r300');
print('images\gimbal_roll_relative_position.png', '-dpng', '-r300');

xlim([duration 2*duration]);
xticks(9:2:18);
xticklabels({'0','2','4','6','8'});

print('images\gimbal_roll_relative_velocity.eps', '-depsc', '-r300');
print('images\gimbal_roll_relative_velocity.png', '-dpng', '-r300');

%% Plot pitch relative

f = figure('Name', 'Pitch relative', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(pitch_relative(1).data.time, pitch_relative(1).data.command_pitch, 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
for d = 1:length(drones)
    h(d) = plot(pitch_relative(d).time, pitch_relative(d).pitch, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-110 140]);
legend([h0, h1, h], 'reference', 'actual', '4K', 'Thermal', 'USA', 'Ai', 'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 2);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\theta_G$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);
set(gca, 'TickLabelInterpreter', 'latex');

% set(f, 'Units', 'Inches');
% pos = get(f, 'Position');
% set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\gimbal_pitch_relative_position.eps', '-depsc', '-r300');
print('images\gimbal_pitch_relative_position.png', '-dpng', '-r300');

xlim([duration 2*duration]);
xticks(9:2:18);
xticklabels({'0','2','4','6','8'});

print('images\gimbal_pitch_relative_velocity.eps', '-depsc', '-r300');
print('images\gimbal_pitch_relative_velocity.png', '-dpng', '-r300');

%% Plot pitch absolute

f = figure('Name', 'Pitch absolute', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(pitch_absolute(1).data.time, pitch_absolute(1).data.command_pitch, 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
for d = 1:length(drones)
    h(d) = plot(pitch_absolute(d).time, pitch_absolute(d).pitch, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-90 90]);
legend([h0, h1, h], 'reference', 'actual', '4K', 'Thermal', 'USA', 'Ai', 'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 2);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\theta_G$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);
set(gca, 'TickLabelInterpreter', 'latex');

% set(f, 'Units', 'Inches');
% pos = get(f, 'Position');
% set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\gimbal_pitch_absolute_position.eps', '-depsc', '-r300');
print('images\gimbal_pitch_absolute_position.png', '-dpng', '-r300');

xlim([duration 2*duration]);
xticks(9:2:18);
xticklabels({'0','2','4','6','8'});

print('images\gimbal_pitch_absolute_velocity.eps', '-depsc', '-r300');
print('images\gimbal_pitch_absolute_velocity.png', '-dpng', '-r300');

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
        if rem(t(i), 3) <= 0.01
            v_filtered(j + 1) = v(i);
            t_filtered(j + 1) = t(i);
            j = j + 1;
        end
    end
end

%% Convert form quaternion to Euler angles

function [roll, pitch, yaw] = quaternion2euler(q_x, q_y, q_z, q_w)
    euler = quat2eul([q_w, q_x, q_y, q_z]);
    roll = rad2deg(euler(:,1));
    pitch = rad2deg(euler(:,2));
    yaw = rad2deg(euler(:,3));

    maxima = find(pitch(1:floor(numel(pitch)/2)) > 87);
    [~, index] = max(diff(maxima));
    t1 = maxima(index);
    t2 = maxima(index + 1);
    pitch(t1 + 1:t2 - 1) = 180 - pitch(t1 + 1:t2 - 1);

    minima = find(pitch(1:floor(numel(pitch)/2)) < -87);
    [~, index] = max(diff(minima));
    t1 = minima(index);
    t2 = minima(index + 1);
    pitch(t1 + 1:t2 - 1) = -180 - pitch(t1 + 1:t2 - 1);
end