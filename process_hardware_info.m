% Read the text file
filename = 'HardwareLogAug13AMChargingPer10.txt';
fid = fopen(filename, 'r');
data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

% Initialize arrays to store the data
timestamps = datetime.empty;
cpu_temp = [];
battery_percentage = [];
battery_voltage_now = [];
battery_voltage_avg = [];
battery_current_now = [];
battery_current_avg = [];
charger_voltage_now = [];
charger_current_now = [];

% Parse each line of the file
for i = 1:length(data{1})
    line = data{1}{i};
    values = strsplit(line, ', ');
    
    % Extract values from each line
    for j = 1:length(values)
        parts = strsplit(values{j}, '=');
        if length(parts) == 2
            key = parts{1};
            value = parts{2};
            switch key
                case 'timestamp'
                    timestamps(end+1) = datetime(value, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
                case 'cpu_temp'
                    cpu_temp(end+1) = str2double(value);
                case 'battery_percentage'
                    battery_percentage(end+1) = str2double(value);
                case 'battery_voltage_now'
                    battery_voltage_now(end+1) = str2double(value);
                case 'battery_voltage_avg'
                    battery_voltage_avg(end+1) = str2double(value);
                case 'battery_current_now'
                    battery_current_now(end+1) = str2double(value);
                case 'battery_current_avg'
                    battery_current_avg(end+1) = str2double(value);
                case 'charger_voltage_now'
                    charger_voltage_now(end+1) = str2double(value);
                case 'charger_current_now'
                    charger_current_now(end+1) = str2double(value);
            end
        end
    end
end

% Calculate averages and new data series
avg_battery_current_avg = mean(battery_current_avg);
avg_charger_current = mean(charger_current_now);
current_difference = charger_current_now - battery_current_now;
power_difference = current_difference .* battery_voltage_avg;
power_battery = battery_current_now .* battery_voltage_avg;

% Calculate average values for new plots
avg_current_difference = mean(current_difference);
avg_power_difference = mean(power_difference);
avg_power_battery = mean(power_battery);

% Create figure
figure('Position', [100, 100, 1200, 1000]);

% Plot CPU temperature
subplot(3, 3, 1);
plot(timestamps, cpu_temp);
title('CPU Temperature');
ylabel('Temperature (°C)');

% Plot Battery Percentage
subplot(3, 3, 2);
plot(timestamps, battery_percentage);
title('Battery Percentage');
ylabel('%');

% Plot Battery Voltage
subplot(3, 3, 3);
plot(timestamps, battery_voltage_now, timestamps, battery_voltage_avg);
title('Battery Voltage');
ylabel('Voltage (V)');
legend('Now', 'Avg');

% Plot Battery Current
subplot(3, 3, 4);
plot(timestamps, battery_current_now, timestamps, battery_current_avg);
hold on;
yline(avg_battery_current_avg, 'r--', 'LineWidth', 2);
title(sprintf('Battery Current (Avg of Avg: %.2f A)', avg_battery_current_avg));
ylabel('Current (A)');
legend('Now', 'Avg', 'Avg of Avg');

% Plot Charger Voltage
subplot(3, 3, 5);
plot(timestamps, charger_voltage_now);
title('Charger Voltage');
ylabel('Voltage (V)');

% Plot Charger Current
subplot(3, 3, 6);
plot(timestamps, charger_current_now);
hold on;
yline(avg_charger_current, 'r--', 'LineWidth', 2);
title(sprintf('Charger Current (Average: %.2f A)', avg_charger_current));
ylabel('Current (A)');
legend('Now', 'Average');

% Plot Current Difference (Charger - Battery)
subplot(3, 3, 7);
plot(timestamps, current_difference);
hold on;
yline(avg_current_difference, 'r--', 'LineWidth', 2);
title(sprintf('Current Difference (Charger - Battery)\nAvg: %.2f A', avg_current_difference));
ylabel('Current (A)');
legend('Difference', 'Average');

% Plot Power Difference
subplot(3, 3, 8);
plot(timestamps, power_difference);
hold on;
yline(avg_power_difference, 'r--', 'LineWidth', 2);
title(sprintf('Power Difference\nAvg: %.2f W', avg_power_difference));
ylabel('Power (W)');
legend('Power', 'Average');

% Plot Battery Power
subplot(3, 3, 9);
plot(timestamps, power_battery);
hold on;
yline(avg_power_battery, 'r--', 'LineWidth', 2);
title(sprintf('Battery Power\nAvg: %.2f W', avg_power_battery));
ylabel('Power (W)');
legend('Power', 'Average');

% Adjust layout and display
sgtitle(filename);
linkaxes(findall(gcf,'Type','axes'), 'x'); % Link x-axes for all subplots

% Format x-axis to show readable dates
datetick('x', 'HH:MM:SS');