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
                );

    # write diff to disk
    $diff->create_ddl_dir($path);

=cut

use Moose;

=head1 ATTRIBUTES

=head2 from

Any source (module name, dbh or dsn) which has the old version of the schema.

=cut

has from => (
    is => 'ro',
    isa => 'Any',
);

=head2 to

Any source (module name, dbh or dsn) which has the new version of the schema.

=cut

has to => (
    is => 'ro',
    isa => 'Any',
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

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
