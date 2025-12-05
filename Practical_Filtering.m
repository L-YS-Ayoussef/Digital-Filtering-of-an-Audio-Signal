%% Audio Filtering Project using FIR Filter Design Methods

% Clear the workspace and close figures
clc; clear; close all;

%% **Step 1: Read an Audio File**
% User selects an audio file for processing
[audio, fs] = audioread('belady.wav'); % Replace with your file path
audio = audio(:,1); % Use only one channel if the audio is stereo
audio_len = length(audio);
time = (0:audio_len-1) / fs; % Time vector for plotting

% Plot Frequency Spectrum
freqz(audio, 1, 1024, fs); 

% Plot the original audio in the time domain
figure;
plot(time, audio);
title('Original Audio Signal (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Play the original audio
disp('Playing Original Audio...');
sound(audio, fs);
pause(length(audio)/fs + 1);

%% **Step 2: Upsample the Audio Signal by a Factor of 2**
fs_new = fs * 2; % New sampling frequency after upsampling
audio_upsampled = resample(audio, 2, 1); % Upsample by factor of 2

% Plot Frequency Spectrum Before and After Upsampling
figure;
subplot(2,1,1);
freqz(audio, 1, 1024, fs);
title('Frequency Spectrum of Original Audio');
subplot(2,1,2);
freqz(audio_upsampled, 1, 1024, fs_new);
title('Frequency Spectrum After Upsampling');

% Play the upsampled audio
disp('Playing Upsampled Audio...');
sound(audio_upsampled, fs_new);
pause(length(audio_upsampled)/fs_new + 1);

%% **Step 3: Add Sinusoidal Interference**
% Define interference parameters
interference_freq = 18000; % Interference frequency (Hz)
interference_amplitude = 0.2; % Interference amplitude

% Generate sinusoidal interference signal
interference = interference_amplitude * sin(2 * pi * interference_freq * (0:length(audio_upsampled)-1) / fs_new)';

% Add interference to the upsampled audio signal
audio_with_interference = audio_upsampled + interference;

% Combined Plot with Improved Transparency and Separation
figure;
plot((0:length(audio_with_interference)-1) / fs_new, audio_with_interference, 'k');
hold on;
plot((0:length(audio_upsampled)-1) / fs_new, audio_upsampled, 'b', 'LineWidth', 0.8);
plot((0:length(interference)-1) / fs_new, interference, 'r', 'LineWidth', 0.8);
hold off;
title('Audio Signal with Interference (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Audio + Interference', 'Audio Signal', 'Interference Signal');
grid on;

% Plot Frequency Spectrum
figure;
freqz(audio_with_interference, 1, 1024, fs_new);
title('Frequency Spectrum of Audio with Interference');

% Play the audio with interference
disp('Playing Audio with Interference...');
sound(audio_with_interference, fs_new);
pause(length(audio_with_interference)/fs_new + 1);


%% **Step 4: Choose Filter Design Method**
disp('Choose Filter Design Method:');
disp('1: Windowed Sinc (WS)');
disp('2: Least Squares (LS)');
disp('3: Weighted Least Squares (WLS)');
method_choice = input('Enter the number of your chosen method (1, 2, or 3): ');

switch method_choice
    case 1 % Windowed Sinc
        disp('Windowed Sinc Method Selected');
        N = input('Enter the length of the filter impulse response (odd number): ');
        fc = input('Enter the cutoff frequency Normalized (0, 0.5): ');
        window_type = input('Choose window type (1: Rectangular, 2: Blackman, 3: Chebyshev, 4: Kaiser): ');
        scale_option = input('Enter 1 for Linear scale, 2 for Logarithmic scale: ');
        
        % Call Windowed Sinc Function
        [indices, coeffs, freq_vector, freq_response] = ws_fir_filter(N, fc, window_type, scale_option);
        
    case 2 % Least Squares
        disp('Least Squares Method Selected');
        filter_len = input('Enter filter length (odd integer): ');
        freq_points = input('Enter number of frequency points: ');
        cutoff_freq = input('Enter cutoff frequency (Hz): ');
        scale_option = input('Enter 1 for Linear scale, 2 for Logarithmic scale: ');
        
        % Call Least Squares Function
        [indices, coeffs, freq_vector, freq_response] = ls_fir_filter(filter_len, freq_points, cutoff_freq, scale_option);
        
    case 3 % Weighted Least Squares
        disp('Weighted Least Squares Method Selected');
        Wp = input('Enter passband weight: ');
        Wt = input('Enter transition band weight: ');
        Ws = input('Enter stopband weight: ');
        filter_len = input('Enter filter length (odd integer): ');
        freq_points = input('Enter number of frequency points: ');
        pass_freq = input('Enter passband cutoff frequency (Hz): ');
        stop_freq = input('Enter stopband start frequency (Hz): ');
        scale_option = input('Enter 1 for Linear scale, 2 for Logarithmic scale: ');
        
        % Call Weighted Least Squares Function
        [indices, coeffs, freq_vector, freq_response] = wls_fir_filter(Wp, Wt, Ws, filter_len, freq_points, pass_freq, stop_freq, scale_option);
        
    otherwise
        error('Invalid selection. Please choose 1, 2, or 3.');
end

%% **Step 5: Filter the Audio Signal with Interference**
audio_filtered = filter(coeffs, 1, audio_with_interference);

% Plot Frequency Spectrum After Filtering
figure;
freqz(audio_filtered, 1, 1024, fs_new);
title('Frequency Spectrum After Filtering');

% Play the Filtered Audio
disp('Playing Filtered Audio...');
sound(audio_filtered, fs_new);
pause(length(audio_filtered)/fs_new + 1);

%% **Step 6: Save Filtered Audio (Optional)**
audiowrite('filtered_audio_wls_case3.wav', audio_filtered, fs_new);
disp('Filtered audio saved as filtered_audio.wav');

