use inc::Module::Install;
name 'Net-Natalie';
all_from 'lib/Net/Natalie.pm';

requires 'Class::Accessor::Fast';

requires 'URI'
requires 'Encode'
requires 'XML::Feed'
requires 'Furl'

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
