#!/usr/bin/perl

package SMS::Claro;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;

use vars qw($VERSION);
use Carp;

$VERSION = "0.1";

sub new () {
	my ($class, %params) = @_;
	my $self = {};
	bless $self, $class;
	$self->_init(%params) or return undef;
	return $self;
}

sub username {
	my $self = shift;
	if (@_) { $self->{"_username"} = shift }
	return $self->{"_username"};
}

sub password {
	my $self = shift;
	if (@_) { $self->{"_password"} = shift }
	return $self->{"_password"};
}

sub login {
	my ($self, $user, $pass) = @_;
	$self->username($user) if ($user);
	$self->password($pass) if ($pass);
	return ($self->username, $self->password);
}

sub baseurl {
	my $self = shift;
	if (@_) { $self->{"_baseurl"} = shift }
	return $self->{"_baseurl"};
}

sub from {
	my $self = shift;
	if (@_) { $self->{"_from"} = shift }
	return $self->{"_from"};
}

sub to {
	my $self = shift;
	if (@_) { $self->{"_to"} = shift }
        return $self->{"_to"};
}

sub message {
	my $self = shift;
	if (@_) { $self->{"_message"} = shift }
	return $self->{"_message"};
}

sub valperiod {
	my $self = shift;
	if (@_) { $self->{"_valperiod"} = shift }
	return $self->{"_valperiod"};
}

sub is_success {
	my $self = shift;
	return $self->{"_success"};
}

sub content {
	my $self = shift;
	if (@_) { $self->{"_content"} = shift }
	return $self->{"_content"};
}

sub send {
	my ($self, $message) = @_;
	$self->message($message) if($message);
	my $parms = {};

	foreach(qw/username password to from message service mode/) {
		$self->_croak("$_ not specified.") unless(defined $self->{"_$_"});
		$parms->{$_} = $self->{"_$_"};
	}

	my $url = $self->baseurl;
	$url .= "user=$parms->{username}";
	$url .= "&pwd=$parms->{password}";
	$url .= "&service=$parms->{service}";
	$url .= "&mode=$parms->{mode}";
	$url .= "&ANUM=$parms->{from}";
	$url .= "&BNUM=$parms->{to}";
	$url .= "&TEXT=$parms->{message}";
	$url .= "&VALPERIOD=" . $self->valperiod;

	my $response = $self->{"_ua"}->get($url);

	if ($response->is_success()) {
		$self->{"_content"} = $response->content;
		$self->{"_success"} = 1;
	} else {
		$self->{"_success"} = 0;
	}

	return $self->is_success;
}

sub _init {
	my $self = shift;
	my %params = @_;

	my $ua =  LWP::UserAgent->new(
		agent => __PACKAGE__." v. $VERSION",
	);

	my %options = (
		ua                => $ua,
		baseurl           => 'https://retail.mds.claro.com.br/BAE/xmlgate?',
		username          => undef,       
		password          => undef,       
		from              => undef,
		to		  => undef,
		message           => undef,
		service		  => 'SENDSMS_NACIONAL',
		mode		  => 'assync-delivery',
		valperiod	  => '000001000000000R',
		success		  => undef,
		content		  => undef,
		%params,
	);

	$self->{"_$_"} = $options{$_} foreach(keys %options);
	return $self;
}


sub _croak {
	my ($self, @error) = @_;
	Carp::croak(@error);
}

1;

__END__

=head1 NAME

SMS::Claro - Send SMS messages via Claro (BAE).

=head1 SYNOPISIS

	use SMS::Claro;

	my $sms = new SMS::Claro;
	$sms->from('0000');	# Short-number
	$sms->to('1199999999'); # Cellphone (DDD + NUMBER)
	$sms->send("message");
	if ($sms->is_success) {
		print $sms->content;
	}

=head1 DESCRIPTION

SMS::Claro allow sending SMS messages via Claro, using a short-number (4 numbers digits) of Claro .

=head1 METHODS

=head2 new

creates a new SMS::Claro object.

=head2 Options

=over 4

=item baseurl

Defaults to "https://retail.mds.claro.com.br/BAE/xmlgate?"

=item ua

Configure your own L<WWW::Mechanize> object, or use our default value.

=item username

Your Claro username.

=item password

Your claro password.

=item message

The actual SMS text.

=head2 login

Set the I<username> and I<password> in one go.

	$sms->login('username', 'password');

	# is basically a shortcut for

	$sms->username('username');
	$sms->password('password');

Without arguements, it will return the array containing I<username> and I<password>.

	my ($username, $password) = $sms->login();

=head2 from

Set from number (short-number) to send SMS message.

=head2 to

Set recipient to send SMS message. (DDD + Number)

=head2 send

Send the actual message. If this method is called with an argument,
it's considered the I<message>. Returns true if the sending was successful,
and false when the sending failed (see I<resultcode> and I<resultmessage>).

=head2 is_success

Returns true when the last sending was successful and false when it failed.

=head2 content

Returns the content of the GET URL.

=head1 AUTHOR

Thiago Rondon, E<lt>thiago@aware.com.brE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Thiago Rondon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
