from scipy.signal.windows import gaussian
from scipy.io import wavfile
from scipy.signal.windows import hann, boxcar
from scipy.signal import ShortTimeFFT, find_peaks
from scipy.fft import fft, fftfreq
import matplotlib.pyplot as plt
import numpy as np
from sound_samples import first_3_seconds

# NOTE: we will try to match the audacity generated spectrogram using the samples in "sound_samples.py"

# the parameters used for the audacity 11k samples diagram are:
# sampling rate = 11025Hz, FFT size = 1024, FFT windowing method = Hann, zero padding factor = 2

# the generated "sound_samples" values from "sound_samples.py" should have a length of: SAMPLING_RATE * song_duration
# checking the song duratinon on the "Barely Holdin' On (by PoloG).wav": 40s => length(sound_samples_full_song) = 11025 * 40 = 441_000
# DISCLAIMER: Each array (sound_samples_full_song, sound_samples_3_second_version) each have a maximum of 30_000 samples (the maximum that can be generated with the "EncodeAudio.exe" software)

print("The length for the full song (silence) is:", len(first_3_seconds), " with a min of: ",
      min(first_3_seconds), " and a max of: ", max(first_3_seconds), " and an average of: ", sum(first_3_seconds) / len(first_3_seconds))

SAMPLING_RATE = 1 / 11025
FFT_size = 1024


def make_spectrogram(samples, title, sampling_rate):
    sample_count = len(samples)
    time_indexes = np.arange(sample_count) * \
        sampling_rate  # time indexes for signal
    hann_window = hann(FFT_size)
    ST_FFT = ShortTimeFFT(hann_window, hop=int(FFT_size / 2), fs=1 / sampling_rate, scale_to='magnitude', mfft=FFT_size)
    
    magnitudes = ST_FFT.spectrogram(np.array(samples))
    
    magnitudes_dB = 20 * np.log10(np.fmax(magnitudes, 1e-4))
    fig, ax1 = plt.subplots(figsize=(6., 4.))  # enlarge plot a bit
    t_lo, t_hi = ST_FFT.extent(sample_count)[:2]  # time range of plot
    ax1.set_title(title)

    ax1.set(xlabel=f"Time $t$ in seconds ({ST_FFT.p_num(sample_count)} slices, " +
            rf"$\Delta t = {ST_FFT.delta_t:g}\,$s)",
            ylabel=f"Freq. $f$ in Hz ({ST_FFT.f_pts} bins, " +
            rf"$\Delta f = {ST_FFT.delta_f:g}\,$Hz)",
            xlim=(t_lo, t_hi))

    im1 = ax1.imshow(magnitudes_dB, origin='lower', aspect='auto',
                     extent=ST_FFT.extent(sample_count), cmap='viridis')
    ax1.plot(time_indexes, 'r--', alpha=.5, label='$f_i(t)$')
    fig.colorbar(im1, label="Magnitude $|S_x(t, f)|$")

    # Shade areas where window slices stick out to the side:
    for t0_, t1_ in [(t_lo, ST_FFT.lower_border_end[0] * ST_FFT.T),
                     (ST_FFT.upper_border_begin(sample_count)[0] * ST_FFT.T, t_hi)]:
        ax1.axvspan(t0_, t1_, color='w', linewidth=0, alpha=.2)
    # mark signal borders with vertical line:
    for t_ in [0, sample_count * ST_FFT.T]:
        ax1.axvline(t_, color='y', linestyle='--', alpha=0.5)
    ax1.legend()
    fig.tight_layout()
    plt.show()

time_indexes = np.arange(len(first_3_seconds)) * (1 / SAMPLING_RATE)

audacity_recordings_figure = plt.figure()
audacity_recordings_figure.subplots_adjust(
    left=None, bottom=None, right=None, top=None, wspace=None, hspace=0.5)
ax1 = audacity_recordings_figure.add_subplot(111)
ax1.title.set_text("Beginning waveform")
ax1.plot(time_indexes, first_3_seconds)
ax1.xaxis.set_label('Sample')
ax1.yaxis.set_label('Amplitude')
ax1.set_ylim([7, 255])

make_spectrogram(first_3_seconds,
                 "Spectrogram for the 3 second intro version from wav -> data software", SAMPLING_RATE)

SAMPLING_RATE = 11025
SAMPLES_COUNT = 1024

hann_window = hann(FFT_size)
ST_FFT = ShortTimeFFT(hann_window, hop=int(FFT_size / 2), fs= 1 / SAMPLING_RATE, scale_to='magnitude', mfft=FFT_size)
magnitudes = ST_FFT.spectrogram(np.array(first_3_seconds))
magnitudes_dB = 20 * np.log10(np.fmax(magnitudes, 1e-4))

from functools import reduce

def build_1_fft(acc, elem):
    acc.append(elem[23])
    return acc

transform_y = reduce(build_1_fft, magnitudes_dB, list())[0: 512];
transform_y[0] = 0;
transform_y[1] = 0;
transform_y[2] = 0;
transform_x = fftfreq(SAMPLES_COUNT, 1 / SAMPLING_RATE)[:SAMPLES_COUNT//2]

plt.figure()
all_peaks, props = find_peaks(transform_y)
peaks, props = find_peaks(transform_y, prominence=0, distance=1)
print(peaks, props);
n_peaks = 16
# Get the n_peaks largest peaks from the prominences
# This is an argpartition
# Useful explanation: https://kanoki.org/2020/01/14/find-k-smallest-and-largest-values-and-its-indices-in-a-numpy-array/
largest_peaks_indices = np.argpartition(props["prominences"], -n_peaks)[-n_peaks:];


largest_peaks = list(map(lambda i: props['prominences'][i], largest_peaks_indices));

def try_find_peaks (data, number_of_peaks_to_find, iteration_count = 0):
    if(len(data) <= number_of_peaks_to_find):
        return data;
        
    data_length = len(data);
    if(iteration_count == 0):
        min_max_pairs = [];
        for index in range(0, data_length - 1, 2):
            min_ = None
            max_ = None
            if(index != data_length - 2):
                max_ = max([data[index], data[index + 1]]);
                min_ = min([data[index], data[index + 1]]);
            else:
                max_ = data[index];
                min_ = data[index];
            min_max_pairs.append([max_, min_]);
        
        return try_find_peaks(min_max_pairs, number_of_peaks_to_find, iteration_count + 1)
    else:
        min_max_pairs = [];
        for index in range (0, data_length - 1, 2):
            if(index == data_length):
                min_max_pairs.append([data[index], data[index]])
            else:
                pair_1 = data[index]
                pair_2 = data[data_length - 1 - index]
                
                pair_1_max = pair_1[0];
                pair_1_min = pair_1[1];

                pair_2_max = pair_2[0];
                pair_2_min = pair_2[1];

                min_ = None;
                max_ = None
                if(min([pair_1_max, pair_2_max]) < max(pair_1_min, pair_2_min)):
                    # downword slope, modify
                    min_ = min(pair_1_min, pair_2_min)
                else: min_ = max(pair_1_min, pair_2_min)

                max_ = max(pair_1_max, pair_2_max)
                min_max_pairs.append([max_, min_])
        return try_find_peaks(min_max_pairs, number_of_peaks_to_find, iteration_count + 1)

print("DATA", transform_y)
print("PEAKS FOUND BY ALGO:", list(map(lambda x: x[0], try_find_peaks(transform_y, 16))))

detected_maximas = np.array(list(map(lambda x: x[0], try_find_peaks(transform_y, 16))))

largest_peaks = peaks[largest_peaks_indices];
plt.xlabel("Frequency (Hz)")
plt.plot(transform_x, transform_y, label="Spectrum")
plt.scatter(np.array(list(map(lambda i: transform_x[i], largest_peaks))), np.array(list(map(lambda i: transform_y[i], largest_peaks))), color="r", zorder=10, label="Constrained Peaks")
plt.scatter(np.array(list(map(lambda val: transform_x[list(transform_y).index(val)], detected_maximas))), list(map(lambda x: x + 5, detected_maximas)), color="y", zorder=10, label="My Marker")
plt.show()
