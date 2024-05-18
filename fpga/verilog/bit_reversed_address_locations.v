// when reading data from a stream (ADC) we would store those values in adjacent memory locations:
// READING 1 -> MEMORY 1, 
// READING 2 -> MEMORY 2, 
// ... 
// READING n -> MEMORY n

// but the FFT requires that input data is mapped to memory locations using the following rule:
// READING 1 -> MEMORY 4, 
// READING 2 -> MEMORY 6,
// ... 
// READING n -> MEMORY bit_reverse(n)
// where the bit_reverse of "abcdef" is "fedcba" 
// see page 5 of: https://web.mit.edu/6.111/www/f2017/handouts/FFTtutorial121102.pdf
module bit_reversed_address_locations
  (
   input wire                   rst,
   input wire                   clk,
   input wire                   clr,

   input wire                   inc,
   output wire [9:0]            bit_reversed_address,
   output wire [9:0]            count,
   output wire                  countFull
   
   );

    // the location in the input stream that will be used to output the location in the FFT memory using the bit_reversed method 
   reg [9:0]         input_stream_location;
   
   assign count = input_stream_location;

   always @ ( posedge clk ) begin
      if ( rst ) begin
         input_stream_location <= 10'b_00000_00000;
      end else if ( clr ) begin
         // the buffer is full, the FFT will start and when it finishes a new stream will be read
         input_stream_location <= 10'b_00000_00000;
      end else if ( inc ) begin
         input_stream_location <= input_stream_location + 1;
      end
   end

   genvar i;
   generate
      for ( i = 0; i < 10; i = i + 1 ) begin : MAKE_BIT_REVERSE
         // make "abcdef" -> "fedcba" 
         assign bit_reversed_address[i] = input_stream_location[BIT_WIDTH-1-i];
      end
   endgenerate

    // when input_stream_location is 10'b_11111_11111 (decimal: 1023) we want to stop reading from the input stream
   assign countFull = &input_stream_location;
   
endmodule

