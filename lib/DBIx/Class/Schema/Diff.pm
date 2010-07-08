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
use SQL::Translator::Diff;
use DBIx::Class::Schema::Diff::Types qw/ Source /;
use Moose;

=head1 ATTRIBUTES

=head2 from

Any source (module name, dbh or dsn) which has the old version of the schema.

=cut

has from => (
    is => 'ro',
    isa => Source,
    coerce => 1,
    documentation => 'Source with old schema information (module name or dsn)',
);

=head2 to

Any source (module name, dbh or dsn) which has the new version of the schema.

=cut

has to => (
    is => 'ro',
    isa => Source,
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

=head2 error

Holds the last error.

=cut

has error => (
    is => 'ro',
    isa => 'Str',
    writer => '_set_error',
    default => '',
);

=head1 METHODS

=head2 create_ddl_dir

Will write the diff between L</from> and L</to> to a selected directory -
one file per table.

=cut

sub create_ddl_dir {
    my $self = shift;
    my $dump_dir = shift;
    my $from = $self->from;
    my $to = $self->to;

    if($to->version == $from->version) {
        $self->_set_error('"to" and "from" version is the same');
        return;
    }

    DB:
    for my $db (@{ $self->databases }) {
        my($diff_obj, $diff_text);

        SOURCE:
        for my $source ($from, $to) {
            my $old_producer = $source->producer;
            my $file = $source->filename($dump_dir);

            $source->producer($db);
            $source->reset;

            unless($source->schema_to_file($file)) {
                $self->_set_error($source->error);
                return;
            }

            $source->producer($old_producer);
        }

        $diff_obj = SQL::Translator::Diff->new({
                        output_db => $db,
                        source_schema => $self->from->schema,
                        target_schema => $self->to->schema,
                    });

        eval {
            $diff_text = $diff_obj->compute_differences->produce_diff_sql;
            open my $DIFF, '>', $to->filename($dump_dir, $from->version) or die $!;
            print $DIFF $diff_text or die $!;
        } or do {
            $self->_set_error($@);
            return;
        };
    }

    return 1;
}

=head1 COPYRIGHT & LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen C<< jhthorsen at cpan.org >>

=cut

1;
