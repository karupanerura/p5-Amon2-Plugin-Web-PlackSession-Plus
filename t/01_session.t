use strict;
use warnings;
use Test::More;
use Test::Requires qw(
			 Plack::Builder
			 Plack::Middleware::Session
			 Plack::Session::Store::Cache
			 Cache::Memory
			 Test::WWW::Mechanize::PSGI
		 );

{
    package MyApp;
    use parent qw/Amon2/;

    package MyApp::Web;
    use parent -norequire, qw/MyApp/;
    use parent qw/Amon2::Web/;
    use Tiffany;
    sub create_view { Tiffany->load('Text::MicroTemplate::File') }
    sub dispatch {
        my $c = shift;
        if ($c->request->path_info eq '/') {
            $c->session->param(foo => 'bar');
            return $c->redirect('/step2');
        } elsif ($c->request->path_info eq '/step2') {
            my $res = "<html><body>@{[  $c->session->param('foo') ]}</body></html>";
            return $c->create_response(
                200,
                [
                    'Conent-Length' => length($res),
                    'Content-Type'  => 'text/plain'
                ],
                $res
            );
        } else {
            return $c->create_response(404, [], []);
        }
    }

    __PACKAGE__->load_plugins('Web::PlackSession::Plus');
}

my $app = MyApp::Web->to_app;
my $mech = Test::WWW::Mechanize::PSGI->new(
    app => builder{
	enable 'Plack::Middleware::Session',
	    store => Plack::Session::Store::Cache->new(
		cache => Cache::Memory->new(
		    namespace       => 'Amon2::Plugin::Web::PlackSession_test',
		    default_expires => '1 sec'
		)
	    );
	$app
    },
    max_redirect          => 0,
    requests_redirectable => []
);
$mech->get('/');
is $mech->status(), 302;
is $mech->res->header('Location'), 'http://localhost/step2';
$mech->get_ok($mech->res->header('Location'));
$mech->content_is('<html><body>bar</body></html>');

done_testing;

