#!/usr/bin/perl -w
#!c:/Perl/bin/Perl.exe -w

use strict;
use warnings;

use Getopt::Std;
use Data::Dumper;

my %args = ();
my $sep = ';';
getopt("fnc",\%args);
die "Please specify input csv filename with -f : \"file_name\" \n" unless defined $args{'f'};
die "Please specify kml folder name with -n : \"folder name\" \n" unless defined $args{'n'};
my $file = $args{'n'}.'.kml';
start_kml($args{'n'},$file);
open my $in,'<',$args{'f'} || die "Could not open $args{'f'} for reading : $! \n";
while(my $line = <$in>) {
	chomp $line;
	print_point_to_kml($file,$line);
}
close $in;
end_kml($file);



sub start_kml {
	my ($name,$file) = @_;
	open my $out,'>', $file || die "Could not open output kml file $file for writing : $! \n";
	print $out '<?xml version="1.0" encoding="UTF-8"?>',"\n";
	print $out '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">',"\n";
	print $out '<Document>',"\n";
	print $out "\t<name>$file</name>\n";
	print $out "\t<Folder>\n";
	print $out "\t\t<name>$name</name>\n";
	print $out "\t\t<open>1</open>\n";
	close $out;
}

sub end_kml {
	my $file = shift;
	open my $out ,'>>',$file || die "Could not open output kml file $file for appending : $! \n";
	print $out "\t</Folder>\n";
	print $out '</Document>',"\n";
	print $out '</kml>',"\n";
	close $out;
}

sub print_point_to_kml {
	my ($file,$line) = @_;
	my ($name,$lon,$lat) = split($sep,$line);
	$lon = dms_to_dec($lon) if defined $args{c};
	$lat = dms_to_dec($lat) if defined $args{c};
	open my $out ,'>>',$file || die "Could not open output kml file $file for appending : $! \n";
	print $out "\t\t<Placemark>\n";
	print $out "\t\t\t<name>$name</name>\n";
	print $out "\t\t\t<open>1</open>\n";
	print $out "\t\t\t",'<styleUrl>#default+nicon=http://maps.google.com/mapfiles/kml/pal3/icon60.png+hicon=http://maps.google.com/mapfiles/kml/pal3/icon52.png</styleUrl>',"\n";
	print $out "\t\t\t<Point>\n";
	print $out "\t\t\t\t<coordinates>$lon,$lat,0</coordinates>\n";
	print $out "\t\t\t</Point>\n";
	print $out "\t\t</Placemark>\n";
	close $out;
}

sub dms_to_dec {
	my $dms = shift;
	my $dec = undef;
	my @num = ($dms =~ /\d+/g);
	my ($dir) = ($dms =~ /(n|s|e|w)/ig);
	my %dir = ('n' => 1,'e' => 1,'s' => -1,'w' => -1);	
	if (scalar @num == 3) {
		$dec = $dir{lc($dir)} * ($num[0] + ($num[1]/60 + $num[2]/3600)); 
	}
	else {
		my $sec = $num[2].'.'.$num[3];
		$dec = $dir{lc($dir)} * ($num[0] + ($num[1]/60 + $sec/3600));
	}
	return $dec;
}

__END__