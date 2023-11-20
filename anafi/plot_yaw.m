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
    yaw(d).data = readtable(strcat('piloting/yaw_', drones{d}, '.txt'));
end

%%  Transform data

for d = 1:length(drones)
    euler = quat2eul([yaw(d).data.quaternion_w, yaw(d).data.quaternion_x, yaw(d).data.quaternion_y, yaw(d).data.quaternion_z]);
    yaw(d).data.quaternion_x = rad2deg(euler(:,3));
    yaw(d).data.quaternion_y = rad2deg(euler(:,2));
    yaw(d).data.quaternion_z = rad2deg(euler(:,1));

    % shift starting yaw to 0
    yaw(d).data.quaternion_z(2:end) = yaw(d).data.quaternion_z(2:end) - yaw(d).data.quaternion_z(2);

    [yaw(d).computed.time, yaw(d).computed.yaw] = unique(yaw(d).data.time, yaw(d).data.quaternion_z);

    yaw(d).computed.yaw_denormalised = denormalise_angles(yaw(d).computed.yaw);
    yaw(d).computed.yaw = normalise_angles(yaw(d).computed.yaw_denormalised);

    yaw(d).computed.yaw_rate = [0 diff(yaw(d).computed.yaw_denormalised)./diff(yaw(d).computed.time)];
    for j = 5:numel(yaw(d).computed.yaw_rate) - 11
        yaw(d).computed.yaw_rate(j) = median([yaw(d).computed.yaw_rate(j:j + 11)]);
    end
end

%% Plot yaw

f = figure('Name', 'Yaw', 'NumberTitle', 'off', 'Renderer', 'painters');
hold on;
grid on;
h0 = plot(yaw(1).data.time(1:600), yaw(1).data.reference_yaw(1:600), 'color', [0.1 0.1 0.1], 'LineStyle', '--', 'linewidth', 1);
h1 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'linewidth', 2);
for d = 1:length(drones)
    h(d) = plot(yaw(d).computed.time, yaw(d).computed.yaw_rate, 'color', colors(d,:), 'linewidth', 2);
end
set(gca, 'fontsize', font_size);
xlim([0 duration]);
ylim([-300 300]);
xlabel('time [s]', 'interpreter', 'latex', 'fontsize', font_size);
ylabel('$\omega_{\psi}$ [deg/s]', 'interpreter', 'latex', 'fontsize', font_size);

yyaxis right
h2 = plot([0 0], [0 0], 'color', [0.1 0.1 0.1], 'LineStyle', ':', 'linewidth', 2);
for d = 1:length(drones)
    plot(yaw(d).computed.time, yaw(d).computed.yaw, 'color', colors(d,:), 'LineStyle', ':', 'linewidth', 2, 'Marker', 'none');
end
ylim([-180 180]);
yticks(-180:60:180);
ylabel('$\psi$ [deg]', 'interpreter', 'latex', 'fontsize', font_size);

ax = gca;
ax.YAxis(2).Color = 'k';
set(gca, 'TickLabelInterpreter', 'latex');
legend([h0, h1, h2, h], 'reference $\omega_{\psi}$', 'actual $\omega_{\psi}$', 'actual $\psi$', '4K', 'Thermal', 'USA', 'Ai', ...
    'Orientation', 'horizontal', 'Location', 'northeast', 'FontSize', font_size, 'Interpreter', 'latex', 'NumColumns', 1);

set(f, 'Units', 'Inches');
pos = get(f, 'Position');
set(f, 'PaperPositionMode', 'Auto', 'PaperUnits', 'Inches', 'PaperSize', [pos(3), pos(4)]);

print('images\drone_yaw.eps', '-depsc', '-r300');
print('images\drone_yaw.pdf', '-dpdf', '-r300');
print('images\drone_yaw.png', '-dpng', '-r300');

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

%% Denormalise angles

function a = denormalise_angles(a)
    for i = 2:numel(a)
        if abs(a(i) - a(i - 1)) > 180
            a(i) = a(i) - 360*sign(a(i) - a(i - 1));
        end
    end
end

%% Normalise angles

function a = normalise_angles(a)
    for i = 1:numel(a)
        if abs(a(i)) > 180
            a(i) = a(i) - 360*sign(a(i));
        end
    end
end