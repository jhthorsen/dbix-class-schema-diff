package DBIx::Class::Schema::Diff::App;

=head1 NAME

DBIx::Class::Schema::Diff::App - Application class for schema-diff.pl

=head1 VERSION

See L<DBIx::Class::Schema::Diff>

=head1 SYNOPSIS

    $ schema-diff.pl <from> <to>

=cut

use Moose;

extends 'DBIx::Class::Schema::Diff';
with qw/ MooseX::Getopt::Dashes /;

=head1 METHODS

=head2 run

Used to start the program from a perl script.

=cut

sub run {
    my $self = shift;
    my $args = $self->extra_argv;
}

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
