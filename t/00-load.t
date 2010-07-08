#!/usr/bin/env perl
use lib qw(lib);
use Test::More;
plan tests => 4;
use_ok('DBIx::Class::Schema::Diff');
use_ok('DBIx::Class::Schema::Diff::App');
use_ok('DBIx::Class::Schema::Diff::Source');
use_ok('DBIx::Class::Schema::Diff::Types');
