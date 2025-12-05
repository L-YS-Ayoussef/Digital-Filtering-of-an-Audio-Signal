%% Function Definition
function [indices, coeffs, freq_vector, freq_response] = ls_fir_filter(filter_len, freq_points, cutoff_freq, scale_option)
% INPUTS:
%   filter_len   - Desired filter length (odd integer)
%   freq_points  - Number of frequency points (must exceed (filter_len-1)/2 + 1)
%   cutoff_freq  - Desired cutoff frequency in Hz (must not exceed Nyquist frequency)
%   scale_option - Display scale: 1 for Linear, 2 for Logarithmic
%
% OUTPUTS:
%   indices        - Filter index vector (0 to filter_len-1)
%   coeffs         - FIR filter coefficients
%   freq_vector    - Frequency vector in Hz
%   freq_response  - Complex frequency response

    %% Validate Inputs
    sample_rate = 44100; % Fixed sampling rate (Hz)

    % Ensure the filter length is odd
    if mod(filter_len, 2) == 0
        warning('Filter length must be odd. Incrementing filter_len by 1.');
        filter_len = filter_len + 1;
    end
    
    % Ensure sufficient frequency points
    if freq_points <= (filter_len - 1) / 2 + 1
        warning('Frequency points insufficient. Using default value.');
        freq_points = (filter_len - 1) / 2 + 2;
    end
    
    % Ensure cutoff frequency is valid
    if cutoff_freq <= 0 || cutoff_freq >= sample_rate / 2
        warning('Invalid cutoff frequency. Defaulting to 5000 Hz.');
        cutoff_freq = 5000;
    end

    %% Frequency Design Grid
    angular_freq = pi * linspace(0, 1, freq_points); % Normalized frequency grid (0 to pi)
    desired_response = double(angular_freq <= (2 * pi * cutoff_freq / sample_rate)); % Desired response

    %% Construct Cosine Matrix
    half_len = (filter_len - 1) / 2; % Half the filter length
    cos_matrix = [ones(freq_points, 1), 2 * cos(angular_freq' * (1:half_len))]; % Basis functions

    %% Solve Least Squares Problem
    coeff_half = (cos_matrix \ desired_response')'; % Solve LS optimization
    coeffs = [fliplr(coeff_half(2:end)), coeff_half]; % Mirror coefficients for symmetry

    %% Frequency Response Calculation
    [freq_response, freq_vector] = freqz(coeffs, 1, freq_points, sample_rate); % Calculate frequency response
    indices = 0:(filter_len - 1); % Index range

    %% Plot Frequency Response
    figure('Name', 'Least Squares FIR Filter');
    if scale_option == 1
        plot(freq_vector, abs(freq_response)); % Linear scale
        ylabel('Magnitude');
    elseif scale_option == 2
        plot(freq_vector, 20 * log10(abs(freq_response))); % Log scale
        ylabel('Magnitude (dB)');
    else
        error('Invalid scale_option. Use 1 (Linear) or 2 (Log).');
    end
    title('Least Squares FIR Filter Frequency Response');
    xlabel('Frequency (Hz)');
    grid on;

end
