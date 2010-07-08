use warnings;
use strict;
use lib qw(t/lib lib);
use DBIx::Class::Schema::Diff;
use Test::More;

plan skip_all => 'Cannot run tests without DBD::SQLite' if ! eval "use DBD::SQLite; 1";
plan tests => 4;

use_ok 'TestApp::Schema';

my $diff = eval {
    DBIx::Class::Schema::Diff->new(
        from => 'DBI:SQLite:t/db/one.sqlite',
        to => 'TestApp::Schema',
    );
};

ok($diff, 'Created diff object') or BAIL_OUT $@;
ok($diff->create_ddl_dir('t/output'), 'Wrote diff to t/output') or diag $diff->error;

{
    open my $GENERATED, '<', 't/output/TestApp-Schema-0-1.0-SQLite.sql' or BAIL_OUT $!;
    open my $EXPECTED, '<', 't/output/expected-0-1.0-SQLite.sql' or BAIL_OUT $!;

    my $n = 0;

    LINE:
    while(my $generated = readline $GENERATED) {
        next LINE unless($generated =~ /^\w/);
        my $expected = readline $EXPECTED;
        $expected = '................' unless(defined $expected);

        if($expected ne $generated) {
            diag "$expected != $generated";
            last LINE;
        }

        $n++;
    }

    is($n, 3, 'Expected diff is ok');
}

unlink 't/output/TestApp-Schema-0-1.0-SQLite.sql';
unlink 't/output/GEN1-Schema-0-SQLite.sql';
unlink 't/output/TestApp-Schema-1.0-SQLite.sql';
