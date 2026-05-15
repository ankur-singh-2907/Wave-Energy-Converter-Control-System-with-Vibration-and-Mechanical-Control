% Define PID gain ranges
kp_range = linspace(1, 50, 10);
ki_range = linspace(0, 10, 5);
kd_range = linspace(0, 10, 5);

% Initialize dataset
dataset = [];

% Loop over all combinations
for kp = kp_range
    for ki = ki_range
        for kd = kd_range
            % Assign PID values to base workspace
            assignin('base', 'Kp', kp);
            assignin('base', 'Ki', ki);
            assignin('base', 'Kd', kd);

            % Simulate the model
            simOut = sim('DL_Project', ...  % <-- change if model name is different
                'StopTime', '20', ...
                'SaveOutput', 'on', ...
                'SaveFormat', 'Dataset', ...
                'ReturnWorkspaceOutputs', 'on');

            % Extract 'logsout' data
            logsout = simOut.get('logsout');
            power_data = [];

            % Search for 'POWER' signal
            for i = 1 : logsout.numElements
                signal = logsout.get(i);
                if strcmp(signal.Name, 'POWER')
                    power_data = signal.Values.Data;
                    break;
                end
            end

            % Compute average power
            if ~isempty(power_data)
                avg_power = mean(power_data);
            else
                warning('POWER signal not found for Kp=%.2f, Ki=%.2f, Kd=%.2f. Using NaN.', kp, ki, kd);
                avg_power = NaN;
            end

            % Append to dataset
            dataset = [dataset; kp, ki, kd, avg_power];
        end
    end
end

% Remove NaN rows
dataset_clean = dataset(~isnan(dataset(:, 4)), :);

% Write to CSV
csvwrite('pid_power_dataset.csv', dataset_clean);

disp('✅ CSV file "pid_power_dataset.csv" generated successfully.');
