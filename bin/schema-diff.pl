#!/usr/bin/env perl

=head1 NAME

schema-diff.pl - Executable for DBIx::Class::Schema::Diff::App

=cut

use DBIx::Class::Schema::Diff::App;
exit DBIx::Class::Schema::Diff::App->new_with_options->run;
