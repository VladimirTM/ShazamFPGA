#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use IO::File;
use Getopt::Long;
use Data::Dumper;

my $fft_length = 1024;
my $fft_dw = 16;
my $basename = "twrom";

my $fft_n = log( $fft_length ) / log(2);

my $fullScale = 0x1 << ($fft_dw-1);
my $mPi = atan2( 1,1 ) * 4;

my $max_frequency = 50000;
my $frequency_hop = 48.828125;

my @romContents = ();
for ( my $i = 0; $i < $fft_length/4; $i++ )
{
    $romContents[$i] = int($fullScale * cos( 2 * $mPi * ($i / $max_frequency) * $frequency_hop) + 0.5);
}


printVerilog( $basename . ".v", \@romContents );
printMif( $basename . ".mif", \@romContents );

sub printVerilog
{
    ( my $filename, my $listRef ) = @_;

    my $fh = IO::File->new( $filename, '>' ) or croak( $! );

   $fh->print( <<"VERILOG_HEADER"
module $basename
(
input wire clk,
input wire twact,
input wire [$fft_n-1-2:0] twa,
output reg [$fft_dw-1:0] twdr_cos
);


always @ ( posedge clk ) begin
if ( twact ) begin
case ( twa )
VERILOG_HEADER
       );

for ( my $i = 0; $i < $fft_length/4; $i++ ){
    $fh->print( "$i: twdr_cos <= " . $listRef->[$i] . ";\n");
}

$fh->print( <<"VERILOG_FOOTER"
endcase
end
end
endmodule

VERILOG_FOOTER
    );

}


sub printMif
{
    ( my $filename, my $listRef ) = @_;
    
    my $fh = IO::File->new( $filename, '>' ) or croak( $! );

    my $depth = $fft_length/4;
    
    $fh->print( <<"MIF_HEADER"
WIDTH=$fft_dw;
DEPTH=$depth;

ADDRESS_RADIX=UNS;
DATA_RADIX=UNS;

CONTENT BEGIN
MIF_HEADER
	);

    for ( my $i = 0; $i < $fft_length/4; $i++ ) {
	$fh->print( " $i : " . $listRef->[$i] . ";\n" );
    }

    $fh->print( <<"MIF_FOOTER"
END;
MIF_FOOTER
	);
    
}







