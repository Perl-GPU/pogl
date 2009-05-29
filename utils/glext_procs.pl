my $file = '../include/GL/glext.h';
die "Unable to read '$file'" if (!open(FILE,$file));

my $exts = '../glext_procs.h';
die "Unable to write to '$exts'" if (!open(EXTS,">$exts"));

my $exps = 'exports.txt';
die "Unable to read '$exps'" if (!open(EXPS,$exps));
my $exports = {};
foreach my $line (<EXPS>)
{
  $line =~ s|[\r\n]+||g;
  next if (!$line);
  $exports->{$line}++;
}
close(EXPS);

# Header
print EXTS qq
{#ifndef __glext_procs_h_
#define __glext_procs_h_

#ifdef __cplusplus
extern "C" \{
#endif

/*
** This file is derived from glext.h and is subject to the same license
** restrictions as that file.
**
};


# License
while (<FILE>)
{
  my $line = $_;
  next if ($line !~ m|^\*\* License Applicability.|);
  print EXTS $line;
  last;
}

# Skip to procs
while (<FILE>)
{
  my $line = $_;
  print EXTS $line;
  last if ($line =~ m|^\#include \<stddef.h\>|);
}

# Handle extensions
while (<FILE>)
{
  my $line = $_;
  if ($line =~ m|^\#ifdef __cplusplus|)
  {
    print "Found end\n";
    print EXTS $line;
    next;
  }
  elsif ($line =~ m|^\#ifndef GL_[^\s]+|)
  {
    my $next_line = <FILE>;

    if ($next_line !~ m|^\#define (GL_[^\s]+) 1|)
    {
      print EXTS $line.$next_line;
      next;
    }

    my $ext = $1;
    print "$ext\n";

    print EXTS qq
{#ifndef NO_$ext
#ifndef $ext
#define $ext 1
#endif
};

    my @procs;
    while (<FILE>)
    {
      my $line2 = $_;

      if ($line2 =~ m|GL_GLEXT_PROTOTYPES|)
      {
        print EXTS $line2;
        next;
      }

      if ($line2 !~ m|^\#endif[\r\n]*$|)
      {
        print EXTS $line2;

        if ($line2 =~ m|APIENTRY (gl[^\s]+)|)
        {
          my $export = $1;
          if ($exports->{$export})
          {
            print "  Not a wgl export: $export\n";
          }
          else
          {
            push(@procs,'static PFN'.uc($1).'PROC '.$1." = NULL;\n");
          }
        }
        next;
      }

      print EXTS "\#ifdef GL_GLEXT_PROCS\n";
      foreach my $proc (@procs)
      {
        print EXTS $proc;
      }
      print EXTS "\#endif /* GL_GLEXT_PROCS */\n";
      print EXTS $line2;
      last;
    }
  }
  else
  {
    print EXTS $line;
  }
}

close(EXTS);
close(FILE);
