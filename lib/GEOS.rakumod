unit module GEOS;

=begin pod

=head1 NAME

GEOS - Raku wrappers for libgeos

=head1 SYNOPSIS

=begin code

use GEOS::Reader;
use GEOS::Calculator 'c';

my $r = GEOS::Reader.new;
my $x = $r.read-wkt('POINT(1 1)');
my $y = $r.read-wkt('POINT(1 2)');
my $d = c.distance($x,$y);

say $d; # 1

=end code


