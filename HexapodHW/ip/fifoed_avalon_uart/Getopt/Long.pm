package Getopt::Long;
our @ISA = qw(Exporter);
our @EXPORT = qw(GetOptions);

# Simple and very stupid placeholder for Getopt::Long, since Quartus'
# perl distribution doesn't include that handy module.
# If you are so blessed as to have an actual installation of Getopt::Long,
# simply delete subdirectory Getopt.
sub GetOptions(@)
{
  my %options = @_;

  for my $term (@ARGV)
  {
    if ($term =~ /--(\S+)=(\S+)/)
    {
      my $name = $1;
      my $value = $2;
           
      map {${$options{$_}} = $value if $_ =~ /$name\=[is]/} keys %options;
    }
  }
}

1;

