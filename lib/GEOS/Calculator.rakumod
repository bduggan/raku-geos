class GEOS::Calculator {

  =begin pod

  =head1 NAME

  GEOS::Calculator -- geospatial calculations using libgeos

  =head1 SYNOPSIS

  =begin code

  use GEOS::Reader;
  use GEOS::Calculator 'c';

  my $r = GEOS::Reader.new;
  my $x = $r.read-wkt('POINT(1 1)');
  my $y = $r.read-wkt('POINT(1 2)');
  my $d = c.distance($x,$y);

  =end code

  =end pod

  use GEOS::Native;

  has $.context = GEOS_init_r();

  method distance(GEOSGeometry $x, GEOSGeometry $y) {
    my num64 $distance;
    GEOSDistance_r($!context, $x, $y, $distance);
    $distance;
  }

  submethod DESTROY {
    GEOS_finish_r($!context);
  }
}

sub EXPORT($c = 'c') {
  %( $c => GEOS::Calculator.new )
}

