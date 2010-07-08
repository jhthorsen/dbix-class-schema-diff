package
    TestApp::Schema;

use Moose;

our $VERSION = '1.0';

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

1;
