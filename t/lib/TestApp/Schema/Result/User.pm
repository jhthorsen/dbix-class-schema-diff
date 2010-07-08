package 
    TestApp::Schema::Result::User;

use Moose;
extends 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw/ Core /);
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_auto_increment => 1,
        is_nullable => 0,
    },
    username => {
        data_type => 'varchar',
        is_nullable => 0,
    },
    name => {
        data_type => 'varchar',
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');

1;
