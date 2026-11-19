#!/usr/intel/pkgs/perl/5.14.1/bin/perl
use strict;
use warnings;
use File::Copy qw(copy move);

# Usage: parser_for_qsys_top.pl <DESIGN_DIR> <QSYS_TOP_REL_PATH>
# Wraps hps_subsys (and legacy sgmii) instances in `ifdef HPS_ENABLE so fabric-only
# sim can omit HPS child IPs. Patches both qsys_top and qsys_top_0 sim RTL in place
# (gen_ip_lib compiles those paths into IP libraries), then copies the selected
# top into verification/tb/qsys_top.v for the TB filelist.
my $design_dir = $ARGV[0];
my $qsys_rel   = $ARGV[1];

die "Usage: $0 <DESIGN_DIR> <QSYS_TOP_REL_PATH>\n"
  unless defined $design_dir && defined $qsys_rel && $design_dir ne '' && $qsys_rel ne '';

$qsys_rel =~ s/^"//;
$qsys_rel =~ s/"$//;
$design_dir .= '/' unless $design_dir =~ m{/$};

# Both variants are compiled into sim libraries; always patch both so NUM_CHANN=1|2 work.
my @qsys_sim_files = (
  $design_dir . "qsys/qsys_top/sim/qsys_top.v",
  $design_dir . "qsys/qsys_top_0/sim/qsys_top_0.v",
);

sub wrap_hps_enable {
  my ($in_path, $out_path) = @_;
  open(my $in,  "<", $in_path)  or die "Cannot open $in_path: $!";
  open(my $out, ">", $out_path) or die "Cannot write $out_path: $!";

  my $flag          = 0;
  my $already_wrapped = 0;
  while (<$in>) {
    # Idempotent: if HPS_ENABLE is already present, copy through unchanged.
    if (!$flag && /`ifdef\s+HPS_ENABLE/) {
      $already_wrapped = 1;
    }
    if (!$already_wrapped && !$flag && /subsys_hps \(|subsys_sgmii_emac1 \(/) {
      print $out "`ifdef HPS_ENABLE\n";
      print $out $_;
      $flag = 1;
    }
    elsif ($flag && /\);/) {
      print $out $_;
      print $out "`endif\n";
      $flag = 0;
    }
    else {
      print $out $_;
    }
  }
  close $in;
  close $out;
  die "ERROR: unmatched HPS_ENABLE wrap in $in_path\n" if $flag;
}

foreach my $src (@qsys_sim_files) {
  unless (-f $src) {
    warn "WARN: missing $src (skip)\n";
    next;
  }
  my $tmp = $src . ".hps_enable.tmp";
  wrap_hps_enable($src, $tmp);
  move($tmp, $src) or die "Cannot replace $src: $!";
  print "Patched HPS_ENABLE into $src\n";
}

# TB filelist always consumes ../tb/qsys_top.v (module may be qsys_top or qsys_top_0).
my $selected = $design_dir . $qsys_rel;
die "ERROR: selected Qsys top not found: $selected\n" unless -f $selected;

my $tb_out = "../tb/qsys_top.v";
copy($selected, $tb_out) or die "Cannot copy $selected to $tb_out: $!";
print "Copied $selected -> $tb_out\n";
