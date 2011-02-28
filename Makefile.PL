use inc::Module::Install;
name 'Amon2-Plugin-Web-PlackSession-Plus';
all_from 'lib/Amon2/Plugin/Web/PlackSession/Plus.pm';
readme_from 'lib/Amon2/Plugin/Web/PlackSession/Plus.pm';
readme_pod_from 'lib/Amon2/Plugin/Web/PlackSession/Plus.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
