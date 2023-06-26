function lfm_signal = lfm(t, duration, bandwidth) % Times, Chirp Duration, Center Frequency, Bandwidth, Number of Repeats

    % Calculate the time step
    dt = t(2) - t(1);

    rand_num = randi([1, duration/dt]);

    % Create time vector for a single up-chirp or down-chirp
    t_single_chirp = 0:dt:(duration/2)-dt;

    % Initialize the LFM signal
    lfm_signal = [];

    num_repeats = ceil(t(end) / duration);

    % Generate up-chirp and down-chirp for the specified number of repeats
    for i = 1:num_repeats + 1
        up_chirp = chirp(t_single_chirp, -bandwidth/2, duration/2, bandwidth/2, 'linear', 0, 'complex');
        down_chirp = chirp(t_single_chirp, bandwidth/2, duration/2, -bandwidth/2, 'linear', 0, 'complex');

        % Concatenate the up-chirp and down-chirp to the LFM signal
        lfm_signal = [lfm_signal, up_chirp, down_chirp];
    end

    lfm_signal = lfm_signal(1 + rand_num : length(t) + rand_num);