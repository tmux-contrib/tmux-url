#!/usr/bin/env perl

# Inspired by github.com/mvdan/xurls approach:
# - Strict mode: URLs with explicit schemes
# - Relaxed mode: Domain names without schemes
# - Proper deduplication

use strict;
use warnings;

# Read all input from STDIN
my $text = do { local $/; <STDIN> };

# Hash for deduplication
my %urls_seen;
my @urls;

# Pattern components (inspired by xurls)
# Common schemes
my $schemes = '(?:https?|ftps?|git|ssh|file|mailto|tel|sms|data)';

# IPv4 octet
my $octet = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])';

# IPv4 address
my $ipv4 = "$octet\\.$octet\\.$octet\\.$octet";

# Common TLDs
my $tlds = '(?:com|org|net|edu|gov|mil|int|io|co|uk|us|de|jp|fr|au|ca|cn|in|br|ru|it|es|nl|se|ch|dk|at|be|no|fi|pl|cz|gr|pt|ie|nz|kr|hk|sg|my|th|vn|ph|tw|tr|za|ae|sa|eg|ng|ke|app|dev|tech|online|site|website|space|store|blog|news|media|info|biz|name|pro|mobi|asia)';

# Domain label and domain pattern
my $label = '[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?';
my $domain = "$label(?:\\.$label)*\\.$tlds";

# Path characters
my $pathChars = '[a-zA-Z0-9\-._~:/?#\[\]@!$&\'()*+,;=%]';

# STRICT MODE: URLs with explicit schemes
my $strictPattern = "($schemes://(?:$ipv4|$domain|localhost)(?::\\d+)?(?:/$pathChars*)?)";
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

# RELAXED MODE: Domain names without schemes
my $relaxedPattern = "\\b($domain(?::\\d+)?(?:/$pathChars*)?)\\b";
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

# EMAIL MODE: Standalone email addresses
my $emailPattern = "\\b([a-zA-Z0-9._%+\\-]+\@$domain)\\b";
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
