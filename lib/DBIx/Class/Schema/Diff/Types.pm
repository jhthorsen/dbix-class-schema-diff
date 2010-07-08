package DBIx::Class::Schema::Diff::Types;

=head1 NAME

DBIx::Class::Schema::Diff::Types - Moose types

=head1 SYNOPSIS

    use DBIx::Class::Schema::Diff::Types qw/DBICObject/;
    has foo => ( isa => DBICObject, ... );

=cut

use constant GENERATED => 'DBIx::Class::Schema::GENERATED'; # subject for change
use Class::MOP ();
use DBIx::Class::Schema::Loader ();
use MooseX::Types::Moose ':all';
use MooseX::Types -declare => [qw/ DBICObject /];

subtype DBICObject, as Str, where { Class::MOP::is_class_loaded($_) };
coerce DBICObject, (
    from Str, via {
        if(/^DBI:/) {
            my $dsn = $_;
            DBIx::Class::Schema::Loader::make_schema_at(GENERATED,
                { naming => 'v7', preserve_case => 1 },
                [ $dsn ],
            );
            return GENERATED;
        }
        elsif(/^[\w+:]+$/) {
            my $class = $_;
            Class::MOP::load_class($class);
            return $class;
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
