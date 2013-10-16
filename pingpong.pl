# Ping-pong. Someone says "ping", you say "pong".
# GPLv2, apparently, so we'll stick with that.
#
# Derived from:
# CopyLeft Riku Voipio 2001
# half-life bot script
use Irssi;
use Irssi::Irc;
use vars qw($VERSION %IRSSI);

# header begins here

$VERSION = "1.1";
%IRSSI = (
    authors     => 'Richard Soderberg',
    contact     => 'rsoderberg@gmail.com',
    name        => 'pingpong',
    description => 'Replies to pings with pongs',
    license     => 'GPLv2',
    url         => 'https://github.com/floatingatoll/pingpong',
);

use vars qw(%pingpong_timeout);
sub cmd_pingpong_public {
    my ($server, $data, $nick, $mask, $target) =@_;
    if ($data =~ /ping/) {
        my $current_nickname = $server->{nick};
        if ($data=~/^\s*${current_nickname}[:;]?\s*ping\s*$/i){
            my $now = time;
            if (!exists($pingpong_timeout{$target}) || $now >= $pingpong_timeout{$target}) {
                $server->command("/msg ${target} public current:${current_nickname} target:${target} nick:${nick} timeout:$pingpong_timeout{$target} now:$now");
                $pingpong_timeout{$target} = $now + 3600;
            }
        }
    }
}

sub cmd_pingpong_private {
    my ($server, $data, $nick, $mask, $target) =@_;
    if ($data =~ /ping/) {
        my $current_nickname = $server->{nick};
        if ($data=~/^\s*(?:${current_nickname}[:;]?)?\s*ping\s*$/i){
            my $now = time;
            if (!exists($pingpong_timeout{$target}) || $now >= $pingpong_timeout{$target}) {
                $server->command("/msg ${nick} private current:${current_nickname} target:${target} nick:${nick} timeout:$pingpong_timeout{$target}");
                $pingpong_timeout{$target} = $now + 3600;
            }
        }
    }
} 

Irssi::signal_add_last('message public', 'cmd_pingpong_public');
Irssi::signal_add_last('message private', 'cmd_pingpong_private');

Irssi::print("Pingpong loaded.");
