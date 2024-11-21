#!raku

use GEOS::Reader;
use GEOS::Writer;

use Test;

my $reader = GEOS::Reader.new;
ok $reader.defined, 'reader defined';

my $writer = GEOS::Writer.new;
ok $writer.defined, 'writer defined';

my $point = $reader.read-wkt('POINT(1 2)');
ok $point.defined, 'point defined';

my $wkt = $writer.write-wkt($point);
ok $wkt.defined, 'wkt defined';
is $wkt, 'POINT (1 2)', 'wkt correct';

done-testing;
