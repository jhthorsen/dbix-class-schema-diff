use lib qw(lib);

package MyClass;
use DBIx::Class::Schema::Diff::Types qw/ Source /;
use Moose;
has source => ( is => 'ro', isa => Source, coerce => 1 );

package main;
use warnings;
use strict;
use Test::More;

plan tests => 3 * 2;

my $obj;

SKIP: {
    eval {
        $obj = MyClass->new(
                source => ['dbi:SQLite:t/db/one.sqlite', 'user', 'pass'],
            );
    } or skip $@, 2;
    ok($obj, 'object constructed from ARRAY');
    is($obj->source->class, 'GEN1::Schema', 'class = GEN1::Schema');
}

SKIP: {
    eval {
        $obj = MyClass->new(
                source => 'dbi:SQLite:t/db/one.sqlite&user&pass',
            );
    } or skip $@, 2;
    ok($obj, 'object constructed from STRING');
    is($obj->source->class, 'GEN2::Schema', 'class = GEN2::Schema');
}

SKIP: {
    eval {
        $obj = MyClass->new(
                source => { class => 'TestApp::Schema' },
            );
    } or skip $@, 2;
    ok($obj, 'object constructed from HASH');
    is($obj->source->class, 'TestApp::Schema', 'class = TestApp::Schema');
}
