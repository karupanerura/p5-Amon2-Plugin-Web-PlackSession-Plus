package Amon2::Plugin::Web::PlackSession::Plus;
use strict;
use warnings;
our $VERSION = '0.01';

use Amon2::Util;

sub init {
    my ($class, $c) = @_;

    Amon2::Util::add_method($c, session => sub {
        my $self = shift;

	return $self->{__PACKAGE__} //= Plack::Session::Plus->new($self->req->env);
    });
}

package Plack::Session::Plus;
use strict;
use warnings;
use Carp;

use parent qw(Plack::Session);

# add Sledge like interface
sub param{
    my $self = shift;

    if(@_ == 0){
        return $self->keys;
    }elsif(@_ == 1){
        return (ref($_[0]) eq 'HASH')?
	    $self->param(%{$_[0]}):
	    $self->session->{$_[0]};
    }elsif(!(@_ % 2)){
	while(my($key, $val) = splice(@_, 0, 2)){
	    $self->session->{$key} = $val;
	}
    }else{
	Carp::croak('Bad argument. I need to take key or key and value pair.');
    }
}

sub change_id{ shift->options->{change_id}++; }
sub cleanup{ %{shift->session} = (); }

1;
__END__

=head1 NAME

Amon2::Plugin::Web::PlackSession::Plus - add more interface to Amon2::Plugin::Web::PlackSession.

=head1 SYNOPSIS

    # MyApp.psgi

    use Plack::Builder;
    use Plack::Session::State::YouLike;
    use Plack::Session::Store::YouLike;

    builder{
        # ...

        enable 'Session',
           state => Plack::Session::State::YouLike->new,
           store => Plack::Session::Store::YouLike->new;

        # ,,,
    };

    package MyApp::Web;
    use parent qw/MyApp Amon2::Web/;

    __PACKAGE__->load_plugins('Web::PlackSession::Plus');

    package MyApp::C::Root;
    use strict;
    use warnings;

    sub index {
        my ($class, $c) = @_;
        my $foo = $c->session->get('foo');
        if ($foo) {
              $c->session->set('foo' => $foo+1);
        } else {
              $c->session->set('foo' => 1);
        }
        my $id = $c->session->id; # It's same $c->req->session_options->{id};
        # or $c->session->session_id; is same.

        # or Sledge like interface
        $c->session->param(foo => 1, bar => 2);

        # ...
    }

    sub login{
        if($c->auth eq 'Success!'){
            $c->session->change_id; # It's same $c->req->session_options->{change_id}++;
        }

        # ...
    }

    sub logout{
        $c->session->expire; # It's same $c->req->session_options->{expire}++;

        # ...
    }

=head1 DESCRIPTION

Amon2::Plugin::Web::PlackSession::Plus add more interface to Amon2::Plugin::Web::PlackSession.

=head1 AUTHOR

Kenta Sato E<lt>kenta.sato.1990@gmail.comE<gt>

=head1 SEE ALSO

L<Amon2>
L<Plack::Session>
L<Plack::Middleware::Session>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
