package DBIx::Class::Schema::Diff::Types;

=head1 NAME

DBIx::Class::Schema::Diff::Types - Moose types

=head1 SYNOPSIS

    package MyClass;
    use DBIx::Class::Schema::Diff::Types qw/ Source /;
    use Moose;
    has source => ( is => 'ro', isa => Source, coerce => 1 );

    $obj = MyClass->new(
               source => ['dbi:Pg:dbname="foo"', 'user', 'pass'],
           );

    # NOTE: Using "&" as seperator is subject for change!
    $obj = MyClass->new(
               source => 'dbi:Pg:dbname="foo"&user&pass',
           );

    $obj = MyClass->new(
               source => DBIx::Class::Schema::Diff::Source->new(
                   class => 'TestApp::Schema',
               ),
           );

    $obj = MyClass->new(
               source => { class => 'TestApp::Schema' },
           );

=cut

use Class::MOP ();
use DBIx::Class::Schema::Loader ();
use DBIx::Class::Schema::Diff::Source; 
use MooseX::Types::Moose ':all';
use MooseX::Types -declare => [qw/ Source /];

my $generated = 0;
sub _generate_classname { 'GEN' .(++$generated) .'::Schema' }

subtype Source, as Object, where {
    blessed $_ and 'DBIx::Class::Schema::Diff::Source' eq blessed $_;
};

coerce Source, (
    from Str, via {
        if(/^DBI:/i) {
            my $dsn = $_;
            my $class = _generate_classname;

            DBIx::Class::Schema::Loader::make_schema_at($class,
                { naming => 'v7', preserve_case => 1 },
                [ split /&/, $dsn ],
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
    from ArrayRef, via {
        my $args = $_;
        my $class = _generate_classname;

        DBIx::Class::Schema::Loader::make_schema_at($class,
            { naming => 'v7', preserve_case => 1 },
            $args,
        );

        return DBIx::Class::Schema::Diff::Source->new(class => $class);
    },
    from HashRef, via {
        return DBIx::Class::Schema::Diff::Source->new($_);
    },
);

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<DBIx::Class::Schema::Diff>.

=cut

1;
