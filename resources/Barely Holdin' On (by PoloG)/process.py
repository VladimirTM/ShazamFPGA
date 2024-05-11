from scipy.signal.windows import gaussian
from scipy.io import wavfile
from scipy.signal.windows import hann
from scipy.signal import ShortTimeFFT
import matplotlib.pyplot as plt
import numpy as np
from sound_samples import sound_samples, sound_samples_1_second_version, sound_samples_3_second_version
# NOTE: we will try to match the audacity generated spectogram from the input

# the parameters used for the audacity 11k samples diagram are:
# sampling rate = 11025Hz, FFT size = 1024, FFT windowing method = Hann, zero padding factor = 2

# the generated "sound_samples" values above should have a length of: sampling_rate * song_duration
# checking the song duratinon on the "Barely Holdin' On (by PoloG).wav": 40s
# => length(sound_samples) = 11025 * 40 = 441_000
# DISCLAIMER: Each array (sound_samples, sound_samples_3_second_version) each have a maximum of 30_000 samples (the maximum that can be generated with the "EncodeAudio.exe" software)
# The "sound_samples_1_second_version" array have exactly 10147 samples, close to the chosen frequency 11025 (the errors are caused by manually setting the 1 second window)

print("The length for the 40s sample is:", len(sound_samples))
print("The length for the 3s sample is:", len(sound_samples_3_second_version), " with a min of: ",
      min(sound_samples_3_second_version), " and a max of: ", max(sound_samples_3_second_version))
print("The length for the 1s sample is:", len(sound_samples_1_second_version))


sampling_rate = 1 / 11025
sample_count = 30_000
FFT_size = 1024
real_sample_frequency, real_sound_samples_3_second_version = wavfile.read(
    "3 seconds Barely Holdin' On.wav")

time_indexes = np.arange(sample_count) * \
    sampling_rate  # time indexes for signal
hann_window = hann(FFT_size)
ST_FFT = ShortTimeFFT(hann_window, hop=int(
    FFT_size / 2), fs=1 / sampling_rate, scale_to='magnitude', mfft=FFT_size)

complex_stft_output = ST_FFT.stft(
    np.array(sound_samples_3_second_version))
magnitudes = ST_FFT.spectrogram(np.array(sound_samples_3_second_version))
magnitudes_dB = 10 * np.log10(np.fmax(magnitudes, 1e-4))

print(magnitudes_dB, magnitudes)

# Read the wav file (mono)


file_path = "extracted_data_barely_holdin_on.txt"
with open(file_path, "w") as file:
    output = ""
    for i in range(0, 30_000):
        output += str(real_sound_samples_3_second_version[i]) + "; "
    file.write(output)

# plt.subplot(211)

# plt.plot(time_indexes,sound_samples_3_second_version)

# plt.xlabel('Sample')

# plt.ylabel('Amplitude')


# plt.subplot(211)

# plt.specgram(sound_samples_3_second_version, Fs = 1 / sampling_rate)

# plt.xlabel('Time')

# plt.ylabel('Frequency')

# plt.subplot(212)

# plt.specgram(x = real_sound_samples_3_second_version, Fs = real_sample_frequency)

# plt.xlabel('Time')

# plt.ylabel('Frequency')

fig1, ax1 = plt.subplots(figsize=(6., 4.))  # enlarge plot a bit
t_lo, t_hi = ST_FFT.extent(sample_count)[:2]  # time range of plot
ax1.set_title(rf"STFT {ST_FFT.m_num*ST_FFT.T:g}$\,s$ Hann window")

ax1.set(xlabel=f"Time $t$ in seconds ({ST_FFT.p_num(sample_count)} slices, " +
        rf"$\Delta t = {ST_FFT.delta_t:g}\,$s)",
        ylabel=f"Freq. $f$ in Hz ({ST_FFT.f_pts} bins, " +
        rf"$\Delta f = {ST_FFT.delta_f:g}\,$Hz)",
        xlim=(t_lo, t_hi))

im1 = ax1.imshow(magnitudes_dB, origin='lower', aspect='auto',
                 extent=ST_FFT.extent(sample_count), cmap='viridis')
ax1.plot(time_indexes, 'r--', alpha=.5, label='$f_i(t)$')
fig1.colorbar(im1, label="Magnitude $|S_x(t, f)|$")

# Shade areas where window slices stick out to the side:
for t0_, t1_ in [(t_lo, ST_FFT.lower_border_end[0] * ST_FFT.T),
                 (ST_FFT.upper_border_begin(sample_count)[0] * ST_FFT.T, t_hi)]:
    ax1.axvspan(t0_, t1_, color='w', linewidth=0, alpha=.2)
# mark signal borders with vertical line:
for t_ in [0, sample_count * ST_FFT.T]:
    ax1.axvline(t_, color='y', linestyle='--', alpha=0.5)
ax1.legend()
fig1.tight_layout()
plt.show()
