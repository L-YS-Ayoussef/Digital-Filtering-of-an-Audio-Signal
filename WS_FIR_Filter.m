%% 🎯 **Windowed Sinc FIR Filter Design Function**
% This function designs a Windowed Sinc FIR Filter using a specified window type.

function [indices, coeffs, freq_vector, freq_response] = ws_fir_filter(N, fc, window_type, scaleOption)
% INPUTS:
% N           - Filter length (odd integer)
% fc          - Cutoff frequency (Hz, normalized 0 < fc < 0.5)
% window_type - Type of window (1: Rectangular, 2: Blackman, 3: Chebyshev, 4: Kaiser)
% scaleOption - Display scale (1: Linear, 2: Logarithmic)
%
% OUTPUTS:
% indices       - Filter sample indices (0 to N-1)
% coeffs        - Filter coefficients
% freq_vector   - Frequency vector (normalized)
% freq_response - Complex frequency response

    %% 🔹 **1. Validate Inputs**
    if mod(N, 2) == 0
        error('Filter length (N) must be an odd number.');
    end
    if fc <= 0 || fc >= 0.5
        error('Cutoff frequency (fc) must be in the range (0, 0.5).');
    end
    if ~ismember(window_type, [1, 2, 3, 4])
        error('Invalid window_type. Choose 1 (Rectangular), 2 (Blackman), 3 (Chebyshev), or 4 (Kaiser).');
    end
    if scaleOption ~= 1 && scaleOption ~= 2
        error('Invalid scaleOption. Choose 1 (Linear) or 2 (Logarithmic).');
    end

    %% 🔹 **2. Design Ideal Sinc Filter**
    % Create symmetric index vector
    n = -(N-1)/2 : (N-1)/2; 
    % Calculate the ideal sinc function
    h_ideal = sinc(2 * fc * n); 

    %% 🔹 **3. Apply Selected Window Function**
    % List of window functions
    window_names = {'Rectangular', 'Blackman', 'Chebyshev', 'Kaiser'};
    beta = 8; % Kaiser window beta parameter
    ripple = 50; % Chebyshev window ripple parameter (dB)

    switch window_type
        case 1
            w = rectwin(N); % Rectangular window
        case 2
            w = blackman(N); % Blackman window
        case 3
            w = chebwin(N, ripple); % Chebyshev window
        case 4
            w = kaiser(N, beta); % Kaiser window
    end

    % Apply the selected window to the sinc filter
    coeffs = h_ideal .* w';

    %% 🔹 **4. Frequency Response Calculation**
    [freq_response, freq_vector] = freqz(coeffs, 1, 1024, 'whole');
    freq_vector = freq_vector / (2 * pi); % Normalize frequency axis

    %% 🔹 **5. Generate Index Vector**
    indices = 0:(N-1);

    %% 🔹 **6. Plot Frequency Response**
    figure('Name', 'Windowed Sinc FIR Filter');
    if scaleOption == 1
        plot(freq_vector, abs(freq_response)); % Linear scale
        ylabel('Magnitude');
    else
        plot(freq_vector, 20 * log10(abs(freq_response))); % Log scale (dB)
        ylabel('Magnitude (dB)');
    end
    title([window_names{window_type} ' Window']);
    xlabel('Normalized Frequency (\times\pi rad/sample)');
    grid on;
    sgtitle('Windowed Sinc FIR Filter Design');

end
