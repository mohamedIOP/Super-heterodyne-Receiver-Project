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