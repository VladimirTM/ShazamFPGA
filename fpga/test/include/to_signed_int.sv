function signed [16-1:0] ToSignedInt;
      input real inputValue;
      reg [16-1:0] fullScale;
      real 	       scaledInput;
      real 	       fullScaleDouble;
      begin
	 if ( inputValue >= 1.0 ) begin
	    inputValue = 1.0;
	 end else if ( inputValue <= -1.0 ) begin
	    inputValue = -1.0;
	 end
	 fullScale = {1'b0, 1'b0, 1'b1,{16-3{1'b0}}};
	 fullScaleDouble = fullScale;
	 scaledInput = $floor(inputValue * fullScaleDouble);
	 
	 if ( scaledInput >= fullScaleDouble ) begin
	    ToSignedInt = {1'b0, 1'b0, 1'b0,{16-3{1'b1}}};
      end else begin
	    ToSignedInt = scaledInput;
	 end
      end
   endfunction