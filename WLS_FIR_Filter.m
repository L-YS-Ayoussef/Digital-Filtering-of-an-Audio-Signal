%% Function Definition
function [indices, coeffs, freq_vector, freq_response] = wls_fir_filter(Wp, Wt, Ws, filter_len, freq_points, pass_freq, stop_freq, scale_option)
% FUNCTION DESCRIPTION:
% Designs a low-pass FIR filter using the Weighted Least Squares (WLS) method.
% INPUTS:
%   Wp           - Weight for passband
%   Wt           - Weight for transition band
%   Ws           - Weight for stopband
%   filter_len   - Length of the filter (odd integer)
%   freq_points  - Number of frequency samples for evaluation
%   pass_freq    - Passband cutoff frequency (Hz)
%   stop_freq    - Stopband start frequency (Hz)
%   scale_option - 1 for Linear scale, 2 for Logarithmic scale
%
% OUTPUTS:
%   indices      - Filter index vector (0 to filter_len-1)
%   coeffs       - FIR filter coefficients
%   freq_vector  - Frequency vector in Hz
%   freq_response- Frequency response of the filter

    %% Step 1: Validate Inputs
    sample_rate = 44100; % Sampling rate (fixed at 44.1 kHz)
    
    % Ensure the filter length is odd for symmetry
    if mod(filter_len, 2) == 0
        warning('Filter length must be odd. Incrementing by 1.');
        filter_len = filter_len + 1;
    end
    
    % Ensure valid frequency range: Passband must be less than Stopband
    if pass_freq >= stop_freq || stop_freq >= sample_rate / 2
        error('Invalid frequency range. Passband must be less than Stopband and below Nyquist frequency.');
    end

    %% Step 2: Frequency Design Grid
    % Generate a normalized frequency grid from 0 to π with freq_points samples
    angular_freq = pi * linspace(0, 1, freq_points); 
    
    % Define the desired frequency response: 1 for passband, 0 for stopband
    desired_response = double(angular_freq <= (2 * pi * pass_freq / sample_rate)); 

    %% Step 3: Assign Weights
    % Initialize a weight array for each frequency point
    weights = zeros(1, freq_points); 
    
    % Assign weights to passband, transition band, and stopband
    weights(angular_freq <= (2 * pi * pass_freq / sample_rate)) = Wp; % Passband weight
    weights(angular_freq > (2 * pi * pass_freq / sample_rate) & angular_freq < (2 * pi * stop_freq / sample_rate)) = Wt; % Transition weight
    weights(angular_freq >= (2 * pi * stop_freq / sample_rate)) = Ws; % Stopband weight

    % Create a diagonal weight matrix for WLS optimization
    weighted_matrix = diag(weights); 

    %% Step 4: Build the Cosine Basis Matrix
    half_len = (filter_len - 1) / 2; % Half-length of the filter for symmetry
    
    % Generate cosine terms for frequency response approximation
    cos_matrix = [ones(freq_points, 1), 2 * cos(angular_freq' * (1:half_len))]; 

    %% Step 5: Solve the Weighted Least Squares Problem
    % Solve (F'WF) * h_half = F'WH for half of the filter coefficients
    coeff_half = (cos_matrix' * weighted_matrix * cos_matrix) \ (cos_matrix' * weighted_matrix * desired_response'); 
    
    % Mirror the coefficients to ensure symmetry
    coeffs = [fliplr(coeff_half(2:end)'), coeff_half']; 

    %% Step 6: Compute Frequency Response
    % Compute the frequency response of the filter
    [freq_response, freq_vector] = freqz(coeffs, 1, freq_points, sample_rate); 
    
    % Generate the filter index vector
    indices = 0:(filter_len - 1); 

    %% Step 7: Plot Frequency Response
    figure('Name', 'Weighted Least Squares FIR Filter');
    if scale_option == 1
        % Linear scale plot
        plot(freq_vector, abs(freq_response));
        ylabel('Magnitude');
    elseif scale_option == 2
        % Logarithmic scale plot (in dB)
        plot(freq_vector, 20 * log10(abs(freq_response)));
        ylabel('Magnitude (dB)');
    else
        error('Invalid scale_option. Use 1 (Linear) or 2 (Log).');
    end
    
    % Add plot labels and grid
    title('Weighted Least Squares FIR Filter Response');
    xlabel('Frequency (Hz)');
    grid on;

end
