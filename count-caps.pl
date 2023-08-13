#!/usr/bin/perl
## Get the length of caps and count them

use strict;
use warnings;
use Data::Dumper;

# Initiate
my $file = $ARGV[0];
my @sizes; 

# Check input
die "$file doesn't exist or empty" unless -s $file;

# Open file for reading 
open (my $fh, '<', $file) or die "Failed to open $file";

# Read file by lines
while (<$fh>) {
	chomp;
	my @arr = split / /;
	my $s = @arr;
	push @sizes, $s;
}


# Get unique sizes
my @root_unsorted = uniq(@sizes);

# Sort numerically
my @root = sort { $a <=> $b } @root_unsorted;

# Show unique cap lengths
print join("\t", @root), "\n";

# Count 
my %seen;
for my $data (@sizes) {
    $seen{$data}++; 
}

# Show counts
print join("\t", map {$_ // '0'} @seen{@root}), "\n";   
print "Total: ".(scalar @sizes)."\n";

close $fh;
exit 0;

# === subs ===

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}




