#!/usr/bin/env perl
#;-*- Perl -*-

# Create hybrid hexagonal lattice structure for POSCAR.
# Cubic box will be created on basis of this script.
# Primary designed for hexagonal graphene boron nitride

use FindBin qw($Bin);
use lib "$Bin";
use Perl_func;

# Get the input parameters

if(@ARGV > 6){
  $row = $ARGV[0];
  $col1 = $ARGV[1];
  $col2 = $ARGV[2];
  $lat_type = $ARGV[3];
  $Itype = $ARGV[4];
  $elenum = $ARGV[5];
  for($i = 0; $i < $elenum; $i++){
          $ele[$i] = $ARGV[$i+6];
  }
  $lat_const = $ARGV[elenum+6];
  $c = $ARGV[elenum+7];
  $c_pnt = $ARGV[elenum+8];
}elseif(@ARGV == 6)
{
  if($ARGV[5] == 'CBN'){
    $row = $ARGV[0];
    $col1 = $ARGV[1];
    $col2 = $ARGV[2];
    $lat_type = $ARGV[3];
    $Itype = $ARGV[4];
    $elenum = 3
    $ele = "C B N";
    $lat_const = 2.49;
    $c = 12;
    $c_pnt = 0.4;
  }
}
else
{die "Your input format is not available in the current version"};

$col = $col1 + $cole2;
$filetype = "vasp5";

for($i = 0; $i < 3; $i++){
  for($j = 0; $j < 3; $j++){
    $base_vec->[$i][$j] = 0;
  }
}
for($i = 0; $i < 4; $i++){
  for($j = 0; $j < 4; $j++){
    $base_pnt->[$i][$j] = 0;
  }
} 
#define the base vector and base point

# Alllocate the base vector and base point
if($Itype == 'Z')
{
  $base_vec->[0][0] = 1.73205 * $lat_const * col;
  $base_vec->[1][1] = $lat_const * row;
  $base_vec->[2][2] = $c;
  for($i=1; $i < 4; $i++)
  {
    $base_pnt->[$i][2] = $c_pnt;
  }
  $base_pnt->[0][1] = 1.0/2/row;
  $base_pnt->[1][0] = 1.0/6/col;
  $base_pnt->[2][0] = 1.0/2/col;
  $base_pnt->[3][0] = 2.0/3/col;
  $base_pnt->[3][1] = 1.0/2/row;
}elseif($Itype == 'A')
{
  $base_vec->[0][0] = $lat_const * col;
  $base_vec->[1][1] = 1.73205 * $lat_const * row;
  $base_vec->[2][2] = $c;
  for($i=1; $i < 4; $i++)
  {
    $base_pnt->[$i][2] = $c_pnt;
  }
  $base_pnt->[0][0] = 1.0/2/col;
  $base_pnt->[1][1] = 1.0/6/row;
  $base_pnt->[2][1] = 1.0/2/row;
  $base_pnt->[3][1] = 2.0/3/row;
  $base_pnt->[3][0] = 1.0/2/col;
}else
{die "Your Itype is not available in the current version"};

# calculate the lattice point

# output the POSCAR


write_poscar($t,$basis,$lattice,$natoms,$totatoms,
                     $selectiveflag,$selective,$header,"$dir/POSCAR_PS",$filetype);

  
  
  
