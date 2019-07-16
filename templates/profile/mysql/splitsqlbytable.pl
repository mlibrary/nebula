#! /usr/bin/perl

# split mysql backup out by database and table
#
# 2006-08-17 csnavely

print "not fully tested; known problem at end of sql file\n";
print "for last table in database\n";
#exit 0;

my $db;
open(OUT, "> header.sql");

while ( <STDIN> ) {

  # sense change in database
  if ( /CREATE DATABASE [^\`]* \`([^\']*)\`/ ) {
    $db = $1;
  }

  # sense start of table
  if ( /Table structure for table \`([^\']*)\`/ ) {
    close(OUT);
    open(OUT, "> $db.${1}.sql");
  }

  print OUT;
}

close(OUT);
