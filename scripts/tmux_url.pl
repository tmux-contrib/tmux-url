#!/usr/bin/env perl

# Inspired by github.com/mvdan/xurls approach:
# - Strict mode: URLs with explicit schemes
# - Relaxed mode: Domain names without schemes
# - Proper deduplication

use strict;
use warnings;

# Check if URL unwrapping is enabled (default: on)
sub is_unwrap_enabled {
    my $unwrap_setting = $ENV{UNWRAP_URLS} || "on";
    return $unwrap_setting eq "on";
}

# Check if next line continues the URL from current line
# Based on terminal line wrapping signature:
# - Current line is completely filled (no trailing whitespace)
# - Next line continues immediately (no leading whitespace)
sub _is_url_continuation {
    my ($current, $next) = @_;

    # Empty or whitespace-only lines don't continue
    return 0 if $next =~ /^\s*$/;

    # Next line must NOT start with whitespace (terminal wrap has no leading space)
    return 0 if $next =~ /^\s/;

    # Current line must NOT end with whitespace (terminal wrap fills the line)
    # This is the key signature of a terminal-wrapped line
    return 0 if $current =~ /\s$/;

    # Current line must contain URL-like content
    # Check for scheme, domain pattern, or URL path characters
    return 0 unless $current =~ m{(?:https?://|ftps?://|[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|[/?#@&=%])};

    # If next line starts with a new URL scheme, it's separate
    return 0 if $next =~ m{^[a-zA-Z][a-zA-Z0-9+.-]*://};

    # If next line looks like a complete domain by itself, don't merge
    return 0 if $next =~ m{^[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}(?:\s|$)};

    # Next line should start with URL path characters (not labels like "remote:")
    # URL path chars: alphanumeric, dash, slash, question mark, ampersand, equals, percent, etc.
    # Explicitly reject patterns like "word:" which are labels, not URL content
    return 0 if $next =~ m{^[a-zA-Z]+:\s*$};

    # Otherwise, it's likely a wrapped continuation
    return 1;
}

# Unwrap URLs that have been wrapped across multiple lines
sub unwrap_urls {
    my ($text) = @_;

    return $text unless is_unwrap_enabled();

    my @lines = split /\n/, $text, -1;  # -1 to preserve trailing empty lines
    my @unwrapped;
    my $i = 0;

    while ($i < @lines) {
        my $current = $lines[$i];
        my $merged = $current;

        # Look ahead to merge continuation lines
        while ($i + 1 < @lines && _is_url_continuation($merged, $lines[$i + 1])) {
            $i++;
            # Remove trailing whitespace from merged line and leading whitespace from next
            $merged =~ s/\s+$//;
            my $next = $lines[$i];
            $next =~ s/^\s+//;
            $merged .= $next;
        }

        push @unwrapped, $merged;
        $i++;
    }

    return join("\n", @unwrapped);
}

# Read all input from STDIN
my $text = do { local $/; <STDIN> };

# Unwrap URLs that span multiple lines
$text = unwrap_urls($text);

# Hash for deduplication
my %urls_seen;
my @urls;

# Pattern components (inspired by xurls)
# Common URI schemes (from IANA registry)
# Includes: web, file transfer, communication, version control, and application schemes
my $schemes = '(?:https?|ftps?|sftp|file|ws|wss|git|ssh|svn|mailto|tel|sms|sip|sips|xmpp|irc|ircs|vnc|magnet|bitcoin|slack|spotify|steam|vscode|data)';

# IPv4 octet
my $octet = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])';

# IPv4 address
my $ipv4 = "$octet\\.$octet\\.$octet\\.$octet";

# Common TLDs for relaxed mode (domain-only matching)
# Includes: generic TLDs, major country codes, and popular new gTLDs
my $tlds_common = '(?:com|org|net|edu|gov|mil|int|io|co|ac|ad|ae|af|ag|ai|al|am|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|cr|cu|cv|cw|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|ss|st|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|za|zm|zw|app|dev|tech|online|site|website|space|store|blog|news|media|info|biz|name|pro|mobi|asia|xyz|top|club|shop|live|today|world|earth|life|cloud|email|digital|global|zone|works|ninja|guru|expert|tips|solutions|photos|travel|guide)';

# Permissive TLD pattern for strict mode (with scheme) - matches any 2-63 letter TLD
my $tlds_any = '[a-zA-Z]{2,63}';

# Domain label and domain patterns
my $label = '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?';
my $domain_strict = "$label(?:\\.$label)*\\.$tlds_any";  # Permissive for URLs with schemes
my $domain_relaxed = "$label(?:\\.$label)*\\.$tlds_common";  # Conservative for domain-only

# Path characters
my $pathChars = '[a-zA-Z0-9._~:/?#\[\]@!$&\'()*+,;=%-]';

# STRICT MODE: URLs with explicit schemes (permissive TLD matching)
my $strictPattern = "($schemes://(?:$ipv4|$domain_strict|localhost)(?::\\d+)?(?:/$pathChars*)?)";
while ($text =~ /$strictPattern/gi) {
    my $url = $1;
    # Remove trailing punctuation
    $url =~ s/[.,;:!?\)\]]+$//;
    $url =~ s/["']+$//;

    if (!exists $urls_seen{$url}) {
        $urls_seen{$url} = 1;
        push @urls, $url;
    }
}

# RELAXED MODE: Domain names without schemes (conservative TLD matching)
my $relaxedPattern = "\\b($domain_relaxed(?::\\d+)?(?:/$pathChars*)?)\\b";
while ($text =~ /$relaxedPattern/gi) {
    my $match = $1;
    # Remove trailing punctuation
    $match =~ s/[.,;:!?\)\]]+$//;
    $match =~ s/["']+$//;

    # Construct the full URL
    my $url = "https://$match";

    # Only add if we don't already have this domain
    if (!exists $urls_seen{$url}) {
        my $already_found = 0;
        foreach my $existing (@urls) {
            if ($existing =~ /\Q$match\E/) {
                $already_found = 1;
                last;
            }
        }
        if (!$already_found) {
            $urls_seen{$url} = 1;
            push @urls, $url;
        }
    }
}

# EMAIL MODE: Standalone email addresses (use permissive TLD matching)
my $emailPattern = "\\b([a-zA-Z0-9._%+\\-]+\@$domain_strict)\\b";
while ($text =~ /$emailPattern/g) {
    my $email = $1;
    my $url = "mailto:$email";

    # Skip if this email is already in our URLs
    if (!exists $urls_seen{$url}) {
        my $already_found = 0;
        foreach my $existing (@urls) {
            if ($existing =~ /\Q$email\E/) {
                $already_found = 1;
                last;
            }
        }
        if (!$already_found) {
            $urls_seen{$url} = 1;
            push @urls, $url;
        }
    }
}

# Output one URL per line
foreach my $url (@urls) {
    print "$url\n";
}
