use warnings;
use strict;
use lib qw(t/lib lib);
use DBIx::Class::Schema::Diff;
use Test::More;

plan skip_all => 'Cannot run tests without DBD::SQLite' if ! eval "use DBD::SQLite; 1";
plan tests => 10;

use_ok 'TestApp::Schema';

my $diff = eval {
    DBIx::Class::Schema::Diff->new(
        from => 'DBI:SQLite:t/db/one.sqlite',
        to => 'TestApp::Schema',
    );
};

ok($diff, 'created diff object') or BAIL_OUT $@;
ok($diff->diff_ddl('t/output'), 'wrote diff to t/output') or diag $diff->error;

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

{
    my $text;
    $text = '';
    ok($diff->diff_ddl(\$text), 'wrote "diff" to ref') or diag $diff->error;
    like($text, qr{ADD COLUMN name}, 'diff got ADD COLUMN');

    $text = '';
    ok($diff->from_ddl(\$text), 'wrote "from" to ref') or diag $diff->error;
    like($text, qr{username varchar NOT NULL\n\)}, 'diff only got "username"');

    $text = '';
    ok($diff->to_ddl(\$text), 'wrote "to" to ref') or diag $diff->error;
    like($text, qr{username varchar NOT NULL,\n\s+name}, 'to has "username" and "name"');
}

unlink 't/output/TestApp-Schema-0-1.0-SQLite.sql';
