my $file = '../include/GL/glext.h';
die "Unable to read '$file'" if (!open(FILE,$file));

my $exts = '../glext_procs.h';
die "Unable to write to '$exts'" if (!open(EXTS,">$exts"));
binmode EXTS;

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
  next if ($line !~ m|^\*\* Copyright \(c\) 20\d\d The Khronos Group Inc\.|);
  print EXTS $line;
  last;
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
    my $in_PROTOTYPES;
    my $proto_level;
    my $def_level = 1;
    while (<FILE>)
    {
      my $line2 = $_;

      if ($line2 =~ m/^#(if|ifdef|ifndef)/)
      {
        print EXTS $line2;
        if($line2 =~ /ifdef.*GL_GLEXT_PROTOTYPES/)
        {
          $proto_level = $def_level;
          $in_PROTOTYPES = 1;
        }
        $def_level++;
        next;
      }

      if ($line2 !~ m|^\#endif|)
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
      $def_level--;

      $in_PROTOTYPES = 0 if $in_PROTOTYPES and $proto_level == $def_level;

      if($def_level>0)
      {
        print EXTS $line2;
        next;
      }

      if(@procs)
      {
        print EXTS "\#ifdef GL_GLEXT_PROCS\n";
        foreach my $proc (@procs)
        {
          print EXTS $proc;
        }
        print EXTS "\#endif /* GL_GLEXT_PROCS */\n";
      }

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
