use inc::Module::Install;

name q(DBIx-Class-Schema-Diff);
all_from q(lib/DBIx/Class/Schema/Diff.pm);

requires q(DBIx::Class) => 0.08115;
requires q(DBIx::Class::Schema::Loader) => 0.07000; # optional?
requires q(Moose) => 1.07;
requires q(MooseX::Getopt) => 0.26;
requires q(SQL::Translator) => 0.11003;

test_requires q(Test::More) => 0.94;

bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-Schema-Diff);
homepage q(http://search.cpan.org/dist/DBIx-Class-Schema-Diff);
repository q(git://github.com//home/repositories/dbix-class-schema-diff.git);

install_script glob('bin/*');
auto_install;
WriteAll;
