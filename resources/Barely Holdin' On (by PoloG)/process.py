from scipy.signal.windows import gaussian
from scipy.io import wavfile
from scipy.signal.windows import hann
from scipy.signal import ShortTimeFFT
import matplotlib.pyplot as plt
import numpy as np
from sound_samples import sound_samples_full_song, sound_samples_3_second_version, arduino_sound_samples

# NOTE: we will try to match the audacity generated spectrogram using the samples in "sound_samples.py"

# the parameters used for the audacity 11k samples diagram are:
# sampling rate = 11025Hz, FFT size = 1024, FFT windowing method = Hann, zero padding factor = 2

# the generated "sound_samples" values from "sound_samples.py" should have a length of: SAMPLING_RATE * song_duration
# checking the song duratinon on the "Barely Holdin' On (by PoloG).wav": 40s => length(sound_samples_full_song) = 11025 * 40 = 441_000
# DISCLAIMER: Each array (sound_samples_full_song, sound_samples_3_second_version) each have a maximum of 30_000 samples (the maximum that can be generated with the "EncodeAudio.exe" software)

print("The length for the full song (silence) is:", len(sound_samples_full_song), " with a min of: ",
      min(sound_samples_full_song), " and a max of: ", max(sound_samples_full_song), " and an average of: ", sum(sound_samples_full_song) / len(sound_samples_full_song))
print("The length for the 3s sample is:", len(sound_samples_3_second_version), " with a min of: ",
      min(sound_samples_3_second_version), " and a max of: ", max(sound_samples_3_second_version), " and an average of: ", sum(sound_samples_3_second_version) / len(sound_samples_3_second_version))
print("The length for the 3s sample FROM ARDUINO is:", len(arduino_sound_samples), " with a min of: ",
      min(sound_samples_full_song), " and a max of: ", max(arduino_sound_samples), " and an average of: ", sum(arduino_sound_samples) / len(arduino_sound_samples))

arduino_sample_count = len(arduino_sound_samples)
ARDUINO_SAMPLE_RATE = 1 / 7462
SAMPLING_RATE = 1 / 11025
FFT_size = 1024


def make_spectrogram(samples, title, sampling_rate):
    sample_count = len(samples)
    time_indexes = np.arange(sample_count) * \
        sampling_rate  # time indexes for signal
    hann_window = hann(FFT_size)
    ST_FFT = ShortTimeFFT(hann_window, hop=int(
        FFT_size / 2), fs=1 / sampling_rate, scale_to='magnitude', mfft=FFT_size)
    magnitudes = ST_FFT.spectrogram(np.array(samples))
    magnitudes_dB = 10 * np.log10(np.fmax(magnitudes, 1e-4))
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


real_sample_frequency, real_sound_samples_3_second_version = wavfile.read(
    "3 seconds Barely Holdin' On.wav")

time_indexes_arduino = np.arange(arduino_sample_count) * \
    ARDUINO_SAMPLE_RATE  # time indexes for signal

arduino_figure = plt.figure()
ax_arduino = arduino_figure.add_subplot(111)
ax_arduino.title.set_text("Arduino recording waveform")
ax_arduino.plot(time_indexes_arduino, arduino_sound_samples)
ax_arduino.xaxis.set_label('Sample')
ax_arduino.yaxis.set_label('Amplitude')
ax_arduino.set_ylim([7, 255])


time_indexes = np.arange(len(sound_samples_full_song)) * (1 / SAMPLING_RATE)

audacity_recordings_figure = plt.figure()
audacity_recordings_figure.subplots_adjust(
    left=None, bottom=None, right=None, top=None, wspace=None, hspace=0.5)
ax1 = audacity_recordings_figure.add_subplot(211)
ax2 = audacity_recordings_figure.add_subplot(212)
ax1.title.set_text("Beginning (silence) waveform")
ax1.plot(time_indexes, sound_samples_full_song)
ax1.xaxis.set_label('Sample')
ax1.yaxis.set_label('Amplitude')
ax1.set_ylim([7, 255])

ax2.title.set_text("Intro (humming) waveform")
ax2.plot(time_indexes, sound_samples_3_second_version)
ax2.xaxis.set_label('Sample')
ax2.yaxis.set_label('Amplitude')

make_spectrogram(sound_samples_3_second_version,
                 "Spectrogram for the 3 second intro version from wav -> data software", SAMPLING_RATE)
make_spectrogram(arduino_sound_samples,
                 "Spectrogram for the 3 second intro version from arduino", SAMPLING_RATE)
