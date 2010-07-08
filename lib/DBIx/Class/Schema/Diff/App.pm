package DBIx::Class::Schema::Diff::App;

=head1 NAME

DBIx::Class::Schema::Diff::App - Application class for schema-diff.pl

=head1 VERSION

See L<DBIx::Class::Schema::Diff>

=head1 SYNOPSIS

    $ schema-diff.pl \
        --from <str> \
        --to <str> \
        --output path/to/dir \
        ;

=cut

use DBIx::Class::Schema::Diff::Types qw/ Source /;
use Moose;

extends 'DBIx::Class::Schema::Diff';
with qw/ MooseX::Getopt::Dashes /;

MooseX::Getopt::OptionTypeMap->add_option_type_to_map(Source, '=s');

has '+error' => ( traits => ['NoGetopt'] );
has 'output' => (
    is => 'ro',
    isa => 'Str',
    default => '.',
    documentation => 'Where to output SQL to',
);

=head1 METHODS

=head2 run

Used to start the program from a perl script.

=cut

sub run {
    my $self = shift;

    unless($self->create_ddl_dir($self->output)) {
        if($self->error) {
            print "Unknown error!\n";
            return 255;
        }
        else {
            print $self->error, "\n";
            return 1;
        }
    }

    print "\nDiff was generated:\n";
    printf " * From: %s\n", $self->to->filename($self->output);
    printf " * To:   %s\n", $self->from->filename($self->output);
    printf " * Diff: %s\n", $self->to->filename($self->output, $self->from->version);
    print "\n";

    return 0;
}

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
