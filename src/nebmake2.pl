#!/usr/bin/env perl
#;-*- Perl -*-

# Makes a two step linear interpolation between to POSCARs with N points

use FindBin qw($Bin);
use lib "$Bin";
use Perl_func;

# Get the input parameters
@ARGV >= 6 || die "The input parameters are larger than the maximum\n";
$pos1 = $ARGV[0];
$pos2 = $ARGV[1];
$nim = $ARGV[2] + 2;
$ind1 = $ARGV[3];
$ind2 = $ARGV[4];
$ind_atom = $ARGV[5];

$nim < 100 || die "THE NUMBER OF IMAGES (INCLUDING END-POINTS) IS  LIMITED TO 100 AS IS \n";

# Read in the POSCAR files and make sure that the number of atoms and types are the same
($coo1,$basis1,$lattice1,$natoms1,$totatoms1,$selectiveflag,$selective,$description,$filetype1)
 = read_poscar($pos1);
($coo2,$basis2,$lattice2,$natoms2,$totatoms2,$selectiveflag,$selective,$description,$filetype2)
 = read_poscar($pos2);

print "filetype1: ",$filetype1,"\n";
print "filetype2: ",$filetype2,"\n";

if($filetype1 ne $filetype2) {
    print "TYPE OF FILE 1 IS:  ",$filetype1,"\n";
    print "TYPE OF FILE 2 IS:  ",$filetype2,"\n";
    die;
}
if($totatom1 != $totatom2) {
    print "TOTAL NUMBER OF ATOMS IN FILE 1 IS:  ",$totatoms1,"\n";
    print "TOTAL NUMBER OF ATOMS IN FILE 2 IS:  ",$totatoms2,"\n";
    die;
}
if(@{$natoms1} != @{$natoms2}) {
    print "TYPES OF ATOMS IN FILE 1 IS:  ",$n=@{$natoms1},"\n";
    print "TYPES OF ATOMS IN FILE 2 IS:  ",$n=@{$natoms2},"\n";
    die;
} 
for($i=0; $i<@{$natoms1}; $i++) {
    if($natoms1->[$i] != $natoms2->[$i]) {
        print "FOR ELEMENT ",$i," ... \n";
        print "... ATOMS IN FILE 1 IS:  ",$natoms1->[$i],"\n";
        print "... ATOMS IN FILE 2 IS:  ",$natoms2->[$i],"\n";
        die;
    }
} 
if($lattice1 != $lattice2) {
    print "WARNING: LATTICE CONSTANTS ARE NOT THE SAME \n";
    print "THE LATTICE CONSTANT IN FILE 1 IS:  ",$lattice1,"\n";
    print "THE LATTICE CONSTANT IN FILE 2 IS:  ",$lattice2,"\n";
    print "I HOPE YOU KNOW WHAT YOU ARE DOING\n";
    $dyn_cell = 1;
}
for($i=0; $i<3; $i++) {
    for($j=0; $j<3; $j++) {
        if(($basis1->[$j][$i] != $basis2->[$j][$i])&&($dyn_cell != 1)) {
            print "WARNING: BASIS VECTORS ARE NOT THE SAME \n" ;
            print "BASIS ELEMENT ",$i," ",$j," ... \n" ;
            print "... IS IN FILE 1:  ",$basis1->[$j][$i],"\n" ;
            print "... IS IN FILE 2:  ",$basis2->[$j][$i],"\n" ;
            print "I HOPE YOU KNOW WHAT YOU ARE DOING\n";
            $dyn_cell = 1;
        }
    }
}

# Ok, the POSCARs appear to be for the same system.
# Get te header, i.e. the element symbols from the first POSCAR line
$header = `head -n 1 $pos1`;
chop($header);

# Calculate basis and lattice step if dyn_cell
if ($dyn_cell==1) {
    $latt_step = ($lattice2-$lattice1)/($nim-1);
    #$latt_avg = ($lattice2-$lattice1)/(2);
    $t_latt = $lattice1;
    for($i=0; $i<3; $i++) {
        for($j=0; $j<3; $j++) {
            $basis_step->[$j][$i] = ($basis2->[$j][$i] - $basis1->[$j][$i])/($nim-1);
            $basis_avg->[$j][$i] = ($basis2->[$j][$i] + $basis1->[$j][$i])/(2);
            $t_basis->[$j][$i] = $basis1->[$j][$i];
        }
    }
}

# Calculate the distance between the two images ... dirkar: direct -> cartesian 
$coo1_5 = middle_cal($coo1,$coo2,$totatoms1,$ind1,$ind2,$ind_atom);

# Because zero is the number of the first image
$nim--;

# Put the POSCAR in the initial state folder
mkdir "00";
write_poscar($coo1,$basis1,$lattice1,$natoms1,$totatoms1,
             $selectiveflag,$selective,$header,"00/POSCAR",$filetype1);

# Put the POSCAR in the middle state folder
{
    use integer;
    $nim_middle = $nim / 2;
}
if($nim < 10) { $dir = "0$nim_middle"; }
else { $dir = "$nim_middle"; }
mkdir $dir;
write_poscar($coo1_5,$basis2,$lattice2,$natoms1,$totatoms1,
             $selectiveflag,$selective,$header,"$dir/POSCAR",$filetype1);
             
# Put the POSCAR in the final state folder
if($nim < 10) { $dir = "0$nim"; }
else { $dir = "$nim"; }
mkdir $dir;
write_poscar($coo2,$basis2,$lattice2,$natoms1,$totatoms1,
             $selectiveflag,$selective,$header,"$dir/POSCAR",$filetype1);

# Make the rest of the images in the chain
$nim1 = $nim_middle - 1;
system "$Bin/nebmake.pl 0$nim_middle/POSCAR POSCAR2 $nim1";
$nim2 = $nim_middle + 1;
$i = $nim_middle;
while($i>-1){
    $ii = $i + $nim_middle;
    system "mv 0$i 0$ii";
    $i = $i - 1;
}
system "$Bin/nebmake.pl POSCAR1 0$nim_middle/POSCAR $nim1";
