% Program for generating n-length FFT's twiddle factor
% By: Denny Hermawanto
% Puslit Metrologi LIPI, INDONESIA
% Copyright 2015

fft_length = 1024;

function [twiddle_real, twiddle_imag] = twiddle_generator(N, frequnecy_hop, fft_length) 
  for k = 0:1:(fft_length/2)
    theta = (-2*pi*frequnecy_hop*(k/N));
    twiddle(k+1) = cos(theta) + (1i*(sin(theta)));
  end  
    twiddle_real = single(uniquetol(abs(real(twiddle)), 1e-6));
    twiddle_imag = single(uniquetol(abs(imag(twiddle)), 1e-6));
end

sampling_frequency = 40960;
frequnecy_hop = 40;

[vanilla_twiddle_real, vanilla_twiddle_imag] = twiddle_generator(fft_length, 1, fft_length);
[custom_twiddle_real, custom_twiddle_imag] = twiddle_generator(sampling_frequency, frequnecy_hop, fft_length);

function dec32 = uint_32_from_twiddle_uint16 (twiddle_uint16)
    % Use the uint16 as the most significat bits of dec32
    dec32 = bitshift(twiddle_uint16, 16);
end

function msb_uint16 = keep_msb16_of_hex32 (hex32)
    % Convert the 32-bit hexadecimal value to a decimal integer
    dec32 = hex2dec(hex32);
    
    % Extract the 16 most significant bits (MSBs)
    dec32 = bitshift(dec32, -16);
    %dec32 = bitshift(dec32, 16);

    msb_uint16 = uint32(dec32);
end 

% check that the algorithm used to compress the number of twiddles
% preserves
check_custom_twiddles = [];
custom_twiddles_hex = num2hex(vanilla_twiddle_real);
custom_twiddles_uint16 = [];

for i = 1 : length(custom_twiddles_hex)
    current_hex = convertCharsToStrings(custom_twiddles_hex(i, 1 : 8));
    msb16_of_hex_32 = keep_msb16_of_hex32(current_hex)
    dec2hex(msb16_of_hex_32)
    custom_twiddles_uint16(i) = msb16_of_hex_32;
end

for i = 1 : length(custom_twiddles_uint16)
    dec32 = uint_32_from_twiddle_uint16(custom_twiddles_uint16(i));
    check_custom_twiddles(i) = typecast(uint32(dec32), "single");
end