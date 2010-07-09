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

    # write "diff", "to" and "from" to disk
    $diff->diff_ddl($directory) or die $diff->error;
    $diff->to_ddl($directory) or die $diff->error;
    $diff->from_ddl($directory) or die $diff->error;

=cut

use File::Temp ();
use DBIx::Class;
use SQL::Translator::Diff;
use DBIx::Class::Schema::Diff::Types qw/ Source /;
use Moose;

=head1 ATTRIBUTES

=head2 from

Any source (module name, dbh or dsn) which has the old version of the schema.
This attribute can coerce. See L<DBIx::Class::Schema::Diff::Types> for details.

=cut

has from => (
    is => 'ro',
    isa => Source,
    coerce => 1,
    documentation => 'Source with old schema information (module name or dsn)',
);

=head2 to

Any source (module name, dbh or dsn) which has the new version of the schema.
This attribute can coerce. See L<DBIx::Class::Schema::Diff::Types> for details.

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
    is => 'rw',
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

=head2 diff_ddl

    $bool = $self->diff_ddl($directory, \%args);
    $bool = $self->diff_ddl(\$text, \%args);

Will write the diff (one file per each type in L</databases>) between
L</from> and L</to> to a selected C<$directory>. C<%args> is passed
on to L<SQL::Translator::Diff::new()>, but "output_db", "source_schema"
and "target_schema" is set by this method.

Will write DDL to C<$text> if given as a scalar reference. (This might
not make much sense, if you have more than one type defined in
L</databases>).

=cut

sub diff_ddl {
    my $self = shift;
    my $directory = shift;
    my $args = shift || {};
    my $from = $self->from;
    my $to = $self->to;
    my @tmp_files;

    if($to->version == $from->version) {
        $self->_set_error('"to" and "from" version is the same');
        return;
    }

    for my $db (@{ $self->databases }) {
        my $file = ref $directory eq 'SCALAR' ? $directory : $to->filename($directory, $from->version);
        my($diff_obj, $diff_text);

        SOURCE:
        for my $source ($from, $to) {
            my $old_producer = $source->producer;
            push @tmp_files, File::Temp->new;

            $source->producer($db);
            $source->reset;

            unless($source->schema_to_file($tmp_files[-1])) {
                $self->_set_error($source->error);
                return;
            }

            $source->producer($old_producer);
        }

        $diff_obj = SQL::Translator::Diff->new({
                        %$args,
                        output_db => $db,
                        source_schema => $self->from->schema,
                        target_schema => $self->to->schema,
                    });

        eval {
            $diff_text = $diff_obj->compute_differences->produce_diff_sql;
            open my $DIFF, '>', $file or die $!;
            print $DIFF $diff_text or die $!;
        } or do {
            $self->_set_error($@);
            return;
        };
    }

    return 1;
}

=head2 from_ddl

=head2 to_ddl

    $bool = $self->from_ddl($directory);
    $bool = $self->from_ddl(\$text);
    $bool = $self->to_ddl($directory);
    $bool = $self->to_ddl(\$text);

Will write L</from> or L</to> schemas as DDL to the given directory,
with all the languages defined in L</databases>.

Will write DDL to C<$text> if it is given as a scalar reference. (This
might not make much sense, if you have more than one type defined in
L</databases>.

=cut

sub from_ddl { shift->_ddl(from => @_) }
sub to_ddl { shift->_ddl(to => @_) }

sub _ddl {
    my $self = shift;
    my $attr_name = shift;
    my $directory = shift;
    my $args = shift || {};
 
    for my $db (@{ $self->databases }) {
        my $source = $self->$attr_name;
        my $file = ref $directory eq 'SCALAR' ? $directory : $source->filename($directory);
        my $old_producer = $source->producer;

        $source->reset;
        $source->producer($db);

        unless($source->schema_to_file($file)) {
            $self->_set_error($source->error);
            return;
        }

        $source->producer($old_producer);
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
