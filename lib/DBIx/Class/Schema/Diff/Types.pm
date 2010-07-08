package DBIx::Class::Schema::Diff::Types;

=head1 NAME

DBIx::Class::Schema::Diff::Types - Moose types

=head1 SYNOPSIS

    use DBIx::Class::Schema::Diff::Types qw/ Source /;
    has foo => ( isa => Source, ... );

=cut

use Class::MOP ();
use DBIx::Class::Schema::Loader ();
use DBIx::Class::Schema::Diff::Source; 
use MooseX::Types::Moose ':all';
use MooseX::Types -declare => [qw/ Source /];

my $generated = 0;
sub _generated_classname { "DBIx::Class::Schema::GENERATED" .(++$generated) }

subtype Source, as Object, where {
    blessed $_ and 'DBIx::Class::Schema::Diff::Source' eq blessed $_;
};

coerce Source, (
    from Str, via {
        if(/^DBI:/) {
            my $dsn = $_;
            my $class = _generated_classname;
            DBIx::Class::Schema::Loader::make_schema_at($class,
                { naming => 'v7', preserve_case => 1 },
                [ $dsn ],
            );
            return DBIx::Class::Schema::Diff::Source->new(class => $class);
        }
        elsif(/^[\w+:]+$/) {
            my $class = $_;
            Class::MOP::load_class($class);
            return DBIx::Class::Schema::Diff::Source->new(class => $class);
        }

        return $_;
    },
);

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
