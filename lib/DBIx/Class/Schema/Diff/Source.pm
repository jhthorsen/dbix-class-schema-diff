package DBIx::Class::Schema::Diff::Source;

=head1 NAME

DBIx::Class::Schema::Diff::Source - can do stuff

=head1 SYNOPSIS

    my $obj = DBIx::Class::Schema::Diff::Source->new(
        class => $str,
        sqltranslator => SQL::Translator->new(...),
    );

=cut

use SQL::Translator;
use Moose;

=head1 ATTRIBUTES

=head2 class

This attribute holds the classname of a L<DBIx::Class> schema.

=cut

has class => (
    is => 'ro',
    isa => 'Str', # Class?
    required => 1,
);

=head2 sqltranslator

Holds an L<SQL::Translator> object, either autobuilt or given when
constructing the object.

=cut

has sqltranslator => (
    is => 'ro',
    isa => 'SQL::Translator',
    lazy_build => 1,
    handles => {
        reset => 'reset',
        producer => 'producer',
    },
);

sub _build_sqltranslator {
    return SQL::Translator->new(
        add_drop_table => 1,
        ignore_constraint_names => 1,
        ignore_index_names => 1,
        parser => 'SQL::Translator::Parser::DBIx::Class',
        # more args...?
    );
}

=head2 version

Holds the database schema. Either generated from L</class> or
given in constructor.

=cut

has version => (
    is => 'ro',
    isa => 'Num',
    lazy_build => 1,
);

sub _build_version {
    my $class = shift->class;
    my $version;

    if($class->can('meta')) {
        return $class->meta->version || '0';
    }
    elsif($version = eval "no strict; \$$class\::VERSION") {
        return $version;
    }

    return 0;
}

=head2 producer

Proxy for L<SQL::Translator::producer()>.

=head2 error

Holds the last error after a method return false.

=cut

has error => (
    is => 'ro',
    isa => 'Str',
    writer => '_set_error',
    default => '',
);

=head1 METHODS

=head2 translate

    $text = $self->translate;

Will return generated SQL or undef if it fails to do so. Check
L</error> if that is the case.

=cut

sub translate {
    my $self = shift;
    my $text = $self->sqltranslator->translate({ data => $self->class });

    unless($text) {
        $self->_set_error($self->sqltranslator->error);
        return;
    }

    return $text;
}

=head2 filename

    $path = $self->filename($database, $directory);

Returns a filename, relative to the C<$database> type and L<$directory>.

=cut

sub filename {
    my($self, $database, $directory) = @_;
    my $class = $self->class;

    unless($class->can('ddl_filename')) {
        $self->_set_error("$class cannot ddl_filename()");
        return;
    }

    return $self->class->ddl_filename($database, $self->version, $directory);
}

=head2 schema_to_file

    $bool = $self->schema_to_file($filename);
    $bool = $self->schema_to_file;

Will dump schema as SQL to a given C<$filename> or use the L</filename>
attribute by default.

=cut

sub schema_to_file {
    my $self = shift;
    my $file = shift || $self->filename or return;
    my $text = $self->translate or return;
    my $OUT;

    unless(open $OUT, '>', $file) {
        $self->_set_error($!);
        return;
    }

    return 1;
}

=head2 reset

Proxy for L<SQL::Translator::reset()>.

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
