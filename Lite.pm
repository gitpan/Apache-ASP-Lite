#####################################################################
#
# Apache::ASP::Lite - Implement IIS $Request $Response objects in non-IIS environment 
#
# Emulate limited Microsoft IIS ASP collections under Apache envirnoment
#
# Author: Ross Ferguson (ross.ferguson@cibc.co.uk)
# Revisions: 1.00
#
# Modhist: 
# 24-jan-2001	Released
#
#
#####################################################################

package Apache::ASP::Lite;
$VERSION = "1.00";

sub new {

my $self = { 
  $ContentType = "text/html",
  $sent = false,
  $query = {},
  $env	 = {},
  $form  = {}
  }; 


&parse($ENV{'QUERY_STRING'});

if($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$query_string,$ENV{'CONTENT_LENGTH'});
    &parse($query_string,true);
}

while(($key,$value) = each %ENV) {
  $value =~tr/+/ / ;
  $value =~s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
  $self{env}{$key} = $value;
 }
  
sub parse {

foreach $arg (split(/&/,$_[0])) {
  ($key,$value) = split(/=/,$arg);
  $value =~tr/+/ / ;
  $value =~s/%([0-9a-fA-F]{2})/pack("c",hex($1))/ge;
  
  if($_[1]) {
     $self{form}{$key} = $value;
  } else {
     $self{query}{$key} = $value;
     }
  } 
}

bless $self, 'Apache::ASP::Lite';
return($self);	
}


####
####
####

sub Write { 

my $self = shift;

if (!$self{$sent}) {
   print "content-type: $ContentType\n\n"; 
   $self{$sent} = true;
}

print @_[0]; 
}

####
####
####

sub Item  { 

my $self = shift;
return($self->{Item});
}

####
####
####

sub Count  { 

my $self = shift;
return($self->{Count});
}


####
####
####

sub QueryString {

my $self = shift;
my $ret = { 
  'Item'  => $self{query}{@_[0]}, 
  'Count' => scalar keys %{ $self{query} }
};

bless $ret, Apache::ASP::Lite;
return($ret);	
}


####
####
####

sub ServerVariables { 

my $self = shift;
my $ret = { 
  'Item'  => $self{env}{@_[0]},
  'Count' => scalar keys %{ $self{env} }
}; 

bless $ret, Apache::ASP::Lite;
return($ret);	
}


####
####
####

sub Form { 

my $self = shift;
my $ret = { 
   'Item'  => $self{form}{@_[0]},
   'Count' => scalar keys %{ $self{form} }
};

bless $ret, Apache::ASP::Lite;
return($ret);	
}


####
####
####

sub ContentType { 

my $self = shift;

print "--", $self{ContentType}, "--";
return($self->{ContentType});
}

####
####
####

sub BinaryWrite { 

my $self = shift;

if (!$self{$sent}) {
   print "content-type: $ContentType\n\n"; 
   $self{$sent} = true;
}

print @_[0];
}

package main;

$Request  = Apache::ASP::Lite::new(); 
$Response = $Request;

1;

=head1 NAME

Apache::ASP::Lite - a Module for ASP emulation 

=head1 SYNOPSIS

	use Apache::ASP::Lite; 

	$Response->Write("hello<br>\n");

 	$IE=true if $Request->ServerVariables("HTTP_USER_AGENT")->Item =~/MSIE/;
 
 	$Response->Write("IE=$IE<br>\n");

 	$Response->Write("id=" . $Request->QueryString("id")->Item . "<br>\n");

=head1 DESCRIPTION

Emulate limit Microsoft IIS ASP objects under Apache envirnoment 
Provides common API across both platforms
