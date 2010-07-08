package DBIx::Class::Schema::Diff;

=head1 NAME

DBIx::Class::Schema::Diff - Diff two schemas, regardless of version numbers

=head1 VERSION

0.00

=head1 DESCRIPTION

    Is there a project which can check out two tags/commits from
    git and make a diff between the two schemas? So instead of
    having the version information in the database, I would like
    to A) make a diff between database and the current checked out
    version from the repo B) make a diff between two git-versions.

=head1 SYNOPSIS

    use DBIx::Class::Schema::Diff;

    my $diff = DBIx::Class::Schema::Diff->new(
                    from => $dsn,
                    to => 'MyApp::Schema',
                    databases => ['SQLite'],
                );

    # write diff to disk
    $diff->create_ddl_dir($path);

=cut

use DBIx::Class;
use SQL::Translator;
use SQL::Translator::Diff;
use DBIx::Class::Schema::Diff::Types qw/ DBICObject /;
use Moose;

=head1 ATTRIBUTES

=head2 from

Any source (module name, dbh or dsn) which has the old version of the schema.

=cut

has from => (
    is => 'ro',
    isa => DBICObject,
    coerce => 1,
    documentation => 'Source with old schema information (module name or dsn)',
);

=head2 to

Any source (module name, dbh or dsn) which has the new version of the schema.

=cut

has to => (
    is => 'ro',
    isa => DBICObject,
    coerce => 1,
    documentation => 'Source with new schema information (module name or dsn)',
);

=head2 databases

Which SQL language the output files should be in.

=cut

has databases => (
    is => 'ro',
    isa => 'ArrayRef',
    documentation => 'MySQL, SQLite, PostgreSQL, ....',
    default => sub { ['SQLite'] },
);

=head1 METHODS

=head2 create_ddl_dir

Will write the diff between L</from> and L</to> to a selected directory -
one file per table.

=cut

sub create_ddl_dir {
    my $self = shift;

    # ...
}

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen C<< jhthorsen at cpan.org >>

=cut

1;
