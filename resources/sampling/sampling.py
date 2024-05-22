# consider a 7Hz signal that is being sampled at 500 samples/second
import numpy as np
import matplotlib.pyplot as plt

T = 1  # Period (seconds)
fs = 40_960  # Sampling frequency (Hz)
time = np.linspace(0, T, T * fs)

cosine_wave_150 = np.cos(2 * np.pi * 150 * time);
cosine_wave_20 = np.cos(2 * np.pi * 20 * time);
cosine_wave_2000 = np.cos(2 * np.pi * 2000 * time);

cosine_wave = cosine_wave_150 + cosine_wave_20 + cosine_wave_2000;

magnitude = [];
base_frequency = 40;

output_file = open('output.txt', 'w')
for FFT_STAGE in range(0,1024):
    samples = np.array(list(map(lambda x: x * (1/40_960) * base_frequency * FFT_STAGE, [i for i in range(0, 1023)])))
    # twiddle formula is: (w_N)^k = e^-i*2*pi*(k/fs)*base_frequency
    twiddle_wave_real = np.cos(2 * np.pi * samples);
    twiddle_wave_imag = np.sin(2 * np.pi * samples);
    twiddle_wave = twiddle_wave_real - 1j * twiddle_wave_imag;
    magnitude.append(np.abs(np.dot(cosine_wave[0:1023], twiddle_wave[0:1023])));
    output_file.write(f"DOT PRODUCT OF COSINE WAVE AND TWIDDLE WAVE {base_frequency * FFT_STAGE}Hz: {magnitude[FFT_STAGE - 1]}\n")

# Plot the cosine wave
frequency = np.linspace(0, base_frequency * 1024, 1023);
plt.plot(frequency, magnitude[0:1023])
plt.show()
output_file.close()

# Plot the cosine graph:
plt.plot(time, cosine_wave)
plt.plot(time[0:1023], cosine_wave[0:1023], "bo")

samples = np.array(list(map(lambda x: x * (1/fs) * base_frequency * 4, [i for i in range(0, 1023)])))
# twiddle formula is: (w_N)^k = e^-i*2*pi*(k/fs)*base_frequency
twiddle_wave_real = np.cos(2 * np.pi * samples);
twiddle_wave_imag = np.sin(2 * np.pi * samples);
twiddle_wave = twiddle_wave_real - 1j * twiddle_wave_imag;
plt.plot(time[0:1023], twiddle_wave_real[0:1023], 'go')
plt.show();

