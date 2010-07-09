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

has '+error' => (
    traits => ['NoGetopt'],
);

has write_to => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
    documentation => 'Write "to" schema to disk',
);

has write_from => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
    documentation => 'Write "from" schema to disk',
);

has write_diff => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
    documentation => 'Write "diff" to disk (--no-write-diff to disable)',
);

has output => (
    is => 'ro',
    isa => 'Str',
    default => '.',
    documentation => 'Where to output SQL to ("-" = STDOUT)',
);

=head1 METHODS

=head2 run

Used to start the program from a perl script.

=cut

sub run {
    my $self = shift;
    my $output = $self->output;

    if(!$self->from or !$self->to) {
        print STDERR "--from and --to is required\n";
        exit 2;
    }

    if($output eq '-') {
        my $buf = '';
        $output = \$buf;
    }

    for my $action (qw/to from diff/) {
        my $write = 'write_' .$action;
        my $method = $action. '_ddl';

        next unless($self->$write);

        if($self->$method($output)) {
            if(ref $output eq 'SCALAR') {
                print $$output;
            }
            elsif($action eq 'diff') {
                printf "Wrote diff: %s\n", $self->to->filename($self->output, $self->from->version);
            }
            else {
                printf "Wrote %s: %s\n", $action, $self->$action->filename($self->output);
            }
        }
        elsif($self->error) {
            print "Unknown error!\n";
            return 255;
        }
        else {
            print $self->error, "\n";
            return 1;
        }
    }

    print "\n";

    return 0;
}

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
