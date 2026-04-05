clear,clc,close all;

%% Part I -- Getting files inside the program

%%%% Getting the signals needed from each file

[Short_BBCAudio,Short_BBCAudio_Fs] = audioread('Short_BBCArabic2.wav');
[Short_FM9090Audio,Short_FM9090Audio_Fs] = audioread('Short_FM9090.wav');
Common_Fs = Short_FM9090Audio_Fs;
%%%%% Converting Them to Monophonic signals

Short_BBCAudio_Mono = Short_BBCAudio(:, 1) + Short_BBCAudio(:, 2);
Short_FM9090Audio_Mono = Short_FM9090Audio(:, 1) + Short_FM9090Audio(:, 2);

%%%% Getting the length of each signal

len_Short_BBCAudio_Mono = length(Short_BBCAudio_Mono);
len_FM9090Audio_Mono = length(Short_FM9090Audio_Mono);

%%%% Getting the maximum length

max_len_Audio = max(len_Short_BBCAudio_Mono,len_FM9090Audio_Mono);

%%%% Padding the signals with zeros to have same Length

if max_len_Audio > len_Short_BBCAudio_Mono 
    zeros_needed_Padding = max_len_Audio - len_Short_BBCAudio_Mono;
    Short_BBCAudio_Mono = [Short_BBCAudio_Mono;zeros(zeros_needed_Padding,1)];
end

if max_len_Audio > len_FM9090Audio_Mono 
    zeros_needed_Padding = max_len_Audio - len_FM9090Audio_Mono;
    Short_FM9090Audio_Mono = [Short_FM9090Audio_Mono;zeros(zeros_needed_Padding,1)];
end

%%%% Getting the fft of the signals and getting them on baseband

Short_BBCAudio_Mono_FFT_Shifted = fftshift(fft(Short_BBCAudio_Mono));
Short_FM9090Audio_Mono_FFT_Shifted = fftshift(fft(Short_FM9090Audio_Mono));

%%%% Ploting it in the frequency domain

figure(1)
f = (-max_len_Audio/2 : max_len_Audio/2 - 1) * (Common_Fs/ max_len_Audio);
subplot(1,2,1);
plot(f,abs(Short_BBCAudio_Mono_FFT_Shifted));
title('Frequency Spectrum of Short BBC Audio Mono');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
subplot(1,2,2);
plot(f,abs(Short_FM9090Audio_Mono_FFT_Shifted));
title('Frequency Spectrum of Short FM9090 Audio Mono');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%%%% Calculating the BW of each signal

Short_BBCAudio_Mono_BW = obw(Short_BBCAudio_Mono,Common_Fs);
Short_FM9090Audio_Mono_BW = obw(Short_FM9090Audio_Mono,Common_Fs);

%%%% Displaying the BW of each signal

disp(['Short_BBCAudio_Mono bandwidth is:', num2str(Short_BBCAudio_Mono_BW),' Hz']);
disp(['Short_FM9090Audio_Mono bandwidth is:', num2str(Short_FM9090Audio_Mono_BW),' Hz']);

%% Part II -- AM Modulator

%%%% Fix the Sampling Rate Problem

Interpolation_Factor = 10;
Common_Fs_After_Interpolation = Common_Fs * Interpolation_Factor;
Short_BBCAudio_Interp = interp(Short_BBCAudio_Mono,Interpolation_Factor);
Short_FM9090Audio_Interp = interp(Short_FM9090Audio_Mono,Interpolation_Factor);

%%%% Set the time variable after interpolation

Common_Length_Interp = length(Short_BBCAudio_Interp);
t = (0 : Common_Length_Interp - 1)'*(1/Common_Fs_After_Interpolation);

%%%% Carrier Generatrion part

Fc_BBCAudio = 100000;
Fc_FM9090Audio = 130000;
Carrier_BBCAudio = cos(2*pi*Fc_BBCAudio*t);
Carrier_FM9090Audio = cos(2*pi*Fc_FM9090Audio*t);

%%%% DSB-SC Modulation

Modulated_BBCAudio = Short_BBCAudio_Interp .* Carrier_BBCAudio;
Modulated_FM9090Audio = Short_FM9090Audio_Interp .* Carrier_FM9090Audio;
disp('AM Modulation Phase Finished');

%% Part IV -- RF Stage

%%%% FDM Creation
FDM_Signal_Rx = Modulated_FM9090Audio + Modulated_BBCAudio;
%%%% Specs of filter
F_RF_low = 85000;
F_RF_high = 115000;
%%%% Sharpness of the filter 
Filter_Order = 10;
%%%% filter Design 
RF_Filter_Spec = fdesign.bandpass('N,F3dB1,F3dB2', Filter_Order, F_RF_low, F_RF_high, Common_Fs_After_Interpolation);
RF_Filter = design(RF_Filter_Spec, 'butter');
RF_Filtered_Signal = filter(RF_Filter,FDM_Signal_Rx);

%%%% Ploting the result
RF_Filtered_Signal_FFT = fftshift(fft(RF_Filtered_Signal));
RF_Filtered_Signal_Length = length(RF_Filtered_Signal);
f = (-RF_Filtered_Signal_Length/2 : RF_Filtered_Signal_Length/2 - 1) * (Common_Fs_After_Interpolation/ RF_Filtered_Signal_Length);
figure(2)
plot(f,abs(RF_Filtered_Signal_FFT));
title('Frequency Spectrum of RF filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

%% Part V -- Mixer Stage

F_IF = 15000;
F_Oscillator = Fc_BBCAudio + F_IF;
Oscillator_Signal = cos(2*pi*F_Oscillator*t);
Mixed_Signal = RF_Filtered_Signal .* Oscillator_Signal;

%% Part VI -- IF Stage

%%%% Specs of filter
F_IF_low = 500;
F_IF_high = 30000;
%%%% Sharpness of the filter 
Filter_Order = 10;
%%%% filter Design 
IF_Filter_Spec = fdesign.bandpass('N,F3dB1,F3dB2', Filter_Order, F_IF_low, F_IF_high, Common_Fs_After_Interpolation);
IF_Filter = design(IF_Filter_Spec, 'butter');
IF_Filtered_Signal = filter(IF_Filter,Mixed_Signal);
%%%% Ploting the result
IF_Filtered_Signal_FFT = fftshift(fft(IF_Filtered_Signal));
IF_Filtered_Signal_Length = length(IF_Filtered_Signal);
f = (-IF_Filtered_Signal_Length/2 : IF_Filtered_Signal_Length/2 - 1) * (Common_Fs_After_Interpolation/ IF_Filtered_Signal_Length);
figure(3)
plot(f,abs(IF_Filtered_Signal_FFT));
title('Frequency Spectrum of IF filtered Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');