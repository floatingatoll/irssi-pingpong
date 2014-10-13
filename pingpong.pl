# Ping-pong. Someone says "ping", you say "pong".
# GPLv2, apparently, so we'll stick with that.
#
# Derived from:
# CopyLeft Riku Voipio 2001
# half-life bot script
use Irssi;
use Irssi::Irc;
use vars qw($VERSION %IRSSI);

use vars qw($PINGPONG_REPLY);
$PINGPONG_REPLY = sub {
    # $which_channel is undef or '' for private messages.
    my($current_nickname, $who_pinged, $which_channel) = @_;

    # Helpful boolean.
    my $is_public = (defined($which_channel) && length($which_channel) > 0);

    # Build a reply.
    my $reply;

    # Prefix their nickname if it's in a channel.
    if ($is_public) {
        $reply .= "${who_pinged}: ";
    }

    # Autoresponder reply.
    $reply .= "content-free ping detected, please consider replying with additional information for my scrollback.";

    # All done.
    return $reply;
};

# header begins here

$VERSION = "1.1";
%IRSSI = (
    authors     => 'Richard Soderberg',
    contact     => 'rsoderberg@gmail.com',
    name        => 'pingpong',
    description => 'Replies to pings with pongs',
    license     => 'GPLv2',
    url         => 'https://github.com/floatingatoll/irssi-pingpong',
);

use vars qw(%pingpong_timeout);
%pingpong_timeout = ();

sub cmd_pingpong_public {
    my ($server, $data, $nick, $mask, $target) =@_;
    if ($data =~ /ping/) {
        my $current_nickname = $server->{nick};
        if ($current_nickname ne $nick && $data=~/^\s*${current_nickname}[:;]?\s*ping[\s\!\@\#\$\%\^\&\*\~0-9]*$/i){
            my $now = time;
            if (!exists($pingpong_timeout{$target}) || $now >= $pingpong_timeout{$target}) {
                my $reply = $PINGPONG_REPLY->($current_nickname, $nick, $target);
                $server->command("/msg ${target} ${reply}");
                $pingpong_timeout{$target} = $now + 3600;
            }
        }
    }
}

sub cmd_pingpong_private {
    my ($server, $data, $nick, $mask, $target) =@_;
    if ($data =~ /ping/) {
        my $current_nickname = $server->{nick};
        if ($current_nickname ne $nick && $data=~/^\s*(?:${current_nickname}[:;]?)?\s*ping[\s\!\@\#\$\%\^\&\*\~0-9?]*$/i){
            my $now = time;
            if (!exists($pingpong_timeout{$target}) || $now >= $pingpong_timeout{$target}) {
                my $reply = $PINGPONG_REPLY->($current_nickname, $nick, $target);
                $server->command("/msg ${nick} ${reply}");
                $pingpong_timeout{$target} = $now + 3600;
            }
        }
    }
} 

Irssi::signal_add_last('message public', 'cmd_pingpong_public');
Irssi::signal_add_last('message private', 'cmd_pingpong_private');

Irssi::print("Pingpong loaded.");
