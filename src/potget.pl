#!/usr/bin/env perl
#;-*- Perl -*-

#This command is used to generate POTCAR for your calculation
# Introduction of parameters
# 1. number of element
# 2. potential type: 1 for gga; 2 for lda
# 3-N. The name of the element

use FindBin qw($Bin);
use lib "$Bin";
use Vasp;

@ARGV >= 3 || die "You must tell me the number of element, potential type and name of elements";
$elenum = $ARGV[0];
$pottype = $ARGV[1];
for($i = 0; $i < $elenum; $i++){
	$ele[$i] = $ARGV[$i+2];
}

system "rm POTCAR";

if($pottype == 1){
	for($i = 0; $i < $elenum; $i++)
	{
		$element = $ele[$i];
		system "cat ~/potpaw_PBE/$element/POTCAR >> POTCAR";
	}	
}elsif($pottype == 2)
{
	for($i = 0; $i < $elenum; $i++)
	{
		$element = $ele[$i];
		system "cat ~/potpaw_LDA/$element/POTCAR >> POTCAR";
	}
}
else
{die "There are only GGA and LDA potential available just now"};
