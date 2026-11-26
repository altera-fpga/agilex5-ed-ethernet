#!/usr/bin/env perl

###########################################################
# These give you extra warnings/errors. Do not remove them
###########################################################
use strict;
use warnings;
use Scalar::Util;

use RegTest;
use Data::Dumper;
use TestUtils::XML;
use TestUtilsSystem::Messages::Standard;
use Carp;
use SetEnv;
use Readonly;
use Switch;
use List::Util 'first';

use RegressionList;
use itf_common;

##use ITFUtil;

###########################################
##----- Setup Environment Variables -----##
###########################################
&SetEnv::setup_env();

##################################
##-----Variable Declaration-----##
##################################

# TOP Module
my $top_module               = "-top tb_top";

# VCS Compile command
my $compile_cmd              = "+v2k -sverilog -full64 -ntb_opts uvm -timescale=1ns/1fs -debug_pp -debug_access+all";

# Compile Log
my $compile_log              = "-l compile.log";

# Simulation Log
my $simulation_log           = "-l sim.log";

# Seed range
my $seed_range               = 100000;

# Max UVM Error
my $max_error                = 100;

# Maximum transaction count  
my $trans_count              = 10;

# Pass patterns
my @pass_patterns            = ("UVM_FATAL :    0", "UVM_ERROR :    0");

# Enable Coverage
my $cov_en                   = ITF::get_option("cov_en"       , "ITF") || "0";

# Enable DUMP
my $dump_on                  = ITF::get_option("dump_on"      , "ITF") || "0";


# Random seed generation
my $seed                     = ITF::get_option("seed"         , "ITF") || "1";

# UVM Verbosity
my $uvm_verbosity            = ITF::get_option("uvm_verbosity", "ITF") || "UVM_LOW";

# Testname
my $testname                 = ITF::get_option("testname"     , "ITF") ;

# DUT option
my $dut                      = ITF::get_option('dut'          , "ITF") || "no_dut";

# RTL Debug Statements
my $rtl_dbg_stmt_on          = ITF::get_option('rtl_dbg_stmt_on',"ITF") || "0";

# User Defined Options
my $user_defined_options     = " ";

# UVM options
my $uvm_options              = " ";

# Compile options
my $compile_opts             = " ";

# Simulation options
my $sim_opts                 = ITF::get_option('sim_args', "ITF") || " ";
$sim_opts = join(" ",split(",",$sim_opts));

# Simulation command
my $simulation_cmd           = " ";

# TB Files
my $tb_flists                = " ";

##my $tcam_flists              = " ";

my $rtl_flists               = " ";

my $quartus_simlib           = " ";

# Defines
my $defines                  = " ";
my $debug_def                  = " ";
my $sysrp_debug             = ITF::get_option("sysrp_debug"   , "ITF") || "1";
my $uvm_config_debug             = ITF::get_option("uvm_config_debug", "ITF") || 0;

# Enable performance

my $perf_en                = ITF::get_option("perf_en", "ITF") || 0;


my $seqname = "";
my $str = "";
##===================== Regression List Declaration ====================##
my $regr_cfg_filename = ITF::get_option("regr_cfg", "ITF") || undef;
my $regression_list = RegressionList->new($regr_cfg_filename);


# Copy MIF to VCS directory when running simulation
my @files_read_by_tb_file = ( "SM_SRC_VLIW_MIF.mif" );
ITF::set_option('files_to_be_copied_to_run_directory', 'simulation', \@files_read_by_tb_file);


####################################################################
##------------------------- SUB ROUTINES -------------------------##
####################################################################

##================== Replacing the VCS script ====================##

sub gen_script {
   my ($orig_spd_script) = @_;
   system("cat $orig_spd_script  >> ${orig_spd_script}.new");
   system("sed -i '/  \$design_files */d' ${orig_spd_script}.new");
   system("echo 'cat sim.log 2>/dev/null' >> ${orig_spd_script}.new");
   return "${orig_spd_script}.new";
}


sub check_sim_log_pass_patterns {
   my ($args_ref) = @_;
   my $sim_log_gz = "synopsys/vcs/sim.log.gz";
   my $sim_log    = "synopsys/vcs/sim.log";

   my $content = "";

   if (-f $sim_log_gz) {
        $content = `zcat $sim_log_gz 2>/dev/null`;
    } elsif (-f $sim_log) {
        open(my $fh, '<', $sim_log) or return 0;
        $content = do { local $/; <$fh> };
        close($fh);
    } else {
        return 0;
    }

    return ($content =~ /UVM_FATAL :    0/ && $content =~ /UVM_ERROR :    0/) ? 1 : 0;
}
##===================== Compilation stage ========================##
#-------------------------------------------------------------------
# Note:
# For Makefile-ITF Spetc, the qsys/rtl files and simv are from 
# Makefile build, hence the ITF compilation stage is not used. 
# Sub tests compile_variant, update_compile, compile are not used
#------------------------------------------------------------------
sub compile_variants {
  return unless $regression_list->is_defined();
  return $regression_list->get_test_groups();
}

sub update_compile {
  return unless $regression_list->is_defined();

  my $variant_name = ITF::get_subtest_option("variant_name");
  my $compile_flags = $regression_list->get_compile_flags_for_test_group($variant_name);

  foreach my $flag (@$compile_flags) {
    my ($key, $value) = ($flag =~ /--(.*)=(.*)/);
    ITF::itf_print_info("Setting $key to $value\n");
    ITF::set_option($key, "ITF", $value);
  }
}

sub compile {
   if($dump_on == 1) {
     $user_defined_options .= " -debug_access+nomemcbk+dmptf -debug_region+cell -debug_pp +vcs+vcdpluson +memcbk +vcdplusmemon"; 
   }
 
   if($sysrp_debug == 1) {
     $debug_def = " +define+PCIE_RP_DEBUG";
   }
 
   if ($cov_en == 1) {
     $user_defined_options .= " +define+FCOV_ON -ntb_opts dtm -cm assert+line+cond+tgl+branch+fsm -cm_libs yv+celldefine -cm_noconst -cm_seqnoconst -cm_tgl mda -cm_dir ./simv.vdb";
   }
 
   if ($rtl_dbg_stmt_on == 1) {
     $defines .= " +define+DBG_STMT_ON";
   }
 
   if($perf_en == 1) {
    $user_defined_options .= " +define+PERF_EN";
   }
 
 
    
   $rtl_flists             .= " -f $ENV{TB_PATH}/scripts/rtl_list.f";
   $rtl_flists             .= " -f $ENV{TB_PATH}/scripts/rtl_filelist.f";
   $tb_flists               = " -f $ENV{TB_PATH}/ver_list.f ";
  
   $compile_opts           .= "+define+__ALTERA_STD__METASTABLE_SIM +systemverilogext+.sv +define+TIMESCALE_EN +define+UVM_NO_DEPRECATED +define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_VERDI_NO_COMPWAVE +define+SVT_UVM_TECHNOLOGY +define+SYNOPSYS_SV +define+SVT_FSDB_ENABLE +define+NUM_QSFP_2 +define+P7521SERDES_UX_SIMSPEED +define+MAC_SRD_CFG_25G VLOG_OPT_TB +define+SVT_AXI_MAX_NUM_MASTERS_1 +define+SVT_AXI_MAX_NUM_SLAVES_1 +define+SVT_AXI_MAX_ADDR_WIDTH=64 +define+SVT_AXI_MAX_DATA_WIDTH=256 +define+SM_PTP_MAX_PORTS=2 +define+SIM_MODE $defines $rtl_flists $tb_flists $user_defined_options $compile_log";
 
   $compile_cmd            .= " $compile_opts";
 
   ITF::itf_print_info("REG_LOCAL_ROOT_DIR_PATH=$ENV{REG_LOCAL_ROOT_DIR_PATH}");
   ITF::set_option('USER_DEFINED_ELAB_OPTIONS', 'simulation.vcs', "$compile_cmd");
}

# Reading regression files
sub read_list {
   my $list_file = $_[0];
   my @list;

   open (REGR_FILE,"$list_file") or die ("Could not open $list_file");
   while (<REGR_FILE>) {
     if (!($_ =~ m/^\s*([#]+([\s]*[_a-zA-Z0-9]*)*)*\s*$/g)) {
       chomp ();
       push (@list,$_);
     }
   }

   return @list;
}

sub sequence_variants {
   my @tvariants;
   my @svariants;
   my @my_cmd;
   my $i=0;

   if(defined ($testname)) {
     print("TEST NAME DEFINED : $testname \n");
     push(@tvariants,"$testname");

   } else {
      print("Using regression test list : $regr_cfg_filename \n");

      @my_cmd = &read_list($regr_cfg_filename);

      foreach my $n (@my_cmd) { 
         $i = $i + 1;  

         if($n =~ /testname=([_a-zA-Z0-9]*)/) {
              $testname= $1;
              print("testname: $testname\n");
              ITF::itf_print_info("TESTNAME in SEQ VAR= $testname");
              push(@tvariants,"${testname}");
         }

      }
   }

  print("variants array: @tvariants\n");

  print("sequence_variants stage testname: $testname\n");
  return \@tvariants;
}

sub update_sequence {
   my @my_cmd;
   my $count_line=0;
   my $variant_line;
   my $test_opt_val;
   my @seq;
   my $t1;
   my $t2;
   my $t3;
   my $t4;
   my $seqname=" ";

   my $variant      = ITF::get_subtest_option("variant_name");
   ITF::itf_print_info("Update variant: $variant");

    if(defined ($regr_cfg_filename)) {
        $seed = int(rand($seed_range));
      }

      ITF::set_option("testname"         , "ITF" , $variant);
      ITF::set_option("seed"             , "ITF" , $seed);

   print("SEQUENCE UPDATE SUB: $variant $testname $seed\n");

}

sub sequence_post_process {
  my $seed = ITF::get_option("seed", "ITF");
  my $num_seeds = ITF::get_option("num_seeds", "ITF") || 1;

  my $use_fixed_seed = ITF::get_option("fixed_seed", "ITF") || undef;

  if ( defined($seed)) {
	  my @seeds = ($seed);
	  ITF::set_option('run_seed_sweep__rtl_sim_simulate_only_vcs', 'ITF', \@seeds);
	  ITF::enable_seed_sweep({'seed_type'=> 'user', 'stage' => 'rtl_sim_simulate_only_vcs'});
  } else {
    if (defined($use_fixed_seed)) {
	    ITF::enable_seed_sweep({'seed' => $num_seeds, 'stage' => 'rtl_sim_simulate_only_vcs', 'seed_type' => 'fixed'});
    } else {
      my @seeds;
      for (1 .. $num_seeds) {
        my $new_seed = int(rand($seed_range));
        while (grep( /^$new_seed$/, @seeds )) {
          $new_seed = int(rand($seed_range));
        }
        push(@seeds, $new_seed);
      }
	    ITF::set_option('run_seed_sweep__rtl_sim_simulate_only_vcs', 'ITF', \@seeds);
	    ITF::enable_seed_sweep({'seed_type'=> 'user', 'stage' => 'rtl_sim_simulate_only_vcs'});
    }
  }

  # dump the command that was run
  my $variant_name = ITF::get_subtest_option("variant_name");
  if (!defined($variant_name)) {
    return;
  }

  if (!$regression_list->is_defined()) {
    return;
  }

  # Replace compilation with simv from Makefile build
  ITF::itf_print_info("variant_name=$variant_name");
  ITF::itf_run_system_command("cd $ENV{REG_LOCAL_ROOT_DIR_PATH}/scripts/itf/sequence__$variant_name && mkdir synopsys && cd synopsys && cp -rf $ENV{REG_INITIAL_EXE_DIR_PATH}/../../sim vcs");
}

##====================== Simulation stage ========================##
sub simulate {
  
  my $variant_name = ITF::get_subtest_option("variant_name");
  my $seqname=" ";

  
  #if(!defined ($regr_cfg_filename)) {
  if(defined ($regr_cfg_filename)) {
  $seqname  = ITF::get_option("testname", "ITF");
  $testname = "sm_ptp_base_test";
  ITF::set_option("testname", "ITF", $testname);
  ITF::itf_print_info("SEQNAME=$seqname TESTNAME=$testname");
  }
  

  if (!defined($seed)) {
    if ($variant_name =~ /s[0-9]+/) {
      $variant_name =~ s/s//g;
      $seed = $variant_name;
    } else {
      $seed = int(rand($seed_range));
    }
    ITF::set_option("seed", "ITF", $seed);
  }

  ITF::itf_print_info("Simulate Stage - Seed is: $seed");

  my $plusargs               = ITF::get_option("plusargs", "ITF");
  $plusargs = "+".$plusargs;
  $plusargs = join(" +", split(',',$plusargs));
   $uvm_options            .= " +UVM_VERBOSITY=$uvm_verbosity +ntb_random_seed=$seed +UVM_TESTNAME=$testname cm_name ${variant_name}_${seed} +seqname=$seqname +UVM_MAX_QUIT_COUNT=$max_error";

  if ($cov_en == 1) {
     $user_defined_options .= " -ntb_opts dtm -cm assert+line+cond+tgl+branch+fsm -cm_dir ./simv.vdb";
  }

   $user_defined_options   .= " +licq $uvm_options $sim_opts";
   $simulation_cmd         .= " $user_defined_options $simulation_log";
 
   ITF::itf_print_info("Simulate Stage - Testname=$testname");
   ITF::set_option('USER_DEFINED_SIM_OPTIONS', 'simulation.vcs', "$simulation_cmd");
}


####################################################################
##------------------------- ITF Options --------------------------##
####################################################################
# Required
ITF::set_option('run_spd_flow' , 'simulation', 1);

ITF::set_option('no_testbench_source_files' , 'simulation.vcs' , 1);

# Since there are no IP files generated
ITF::set_option('no_generated_ip_files', 'simulation', 1);

# Top Level module
ITF::set_option('testbench_name' , 'simulation' , "tb_top");

ITF::set_option('custom_gen_spd_sim_script_fn', 'simulation.vcs', \&gen_script );

# For setting the pass signature in simulation
ITF::set_option('sim_log_passing_patterns_arr_ref' , 'simulation', \@pass_patterns);
ITF::set_option('use_all_passing_patterns'         , 'simulation', 1);
ITF::set_option('custom_parse_for_passing_patterns_fn', 'simulation', \&check_sim_log_pass_patterns);


####################################################################
##------------------------- ITF Function Calls -------------------##
####################################################################

#ITF::register_function("vcs_compile_only_resources" ,"get_arc_resources", \&vcs_compile_only_resources);
sub sim_only_resources {
  return "vcs vcs-vcsmx-lic ostype/suse15";
}
 
ITF::register_user_function("rtl_sim_simulate_only_vcs", "get_arc_resources", \&sim_only_resources);

# Configure test based on compile variants
#---------Note: Compilation stage is not used in Makefile/ITF/Spetc flow----------
#ITF::register_function("rtl_sim_compile_only_vcs", "get_variant_list", \&compile_variants);
#ITF::register_function("rtl_sim_compile_only_vcs", "update_variant", \&update_compile);
# Pre-Compilation Stage
#ITF::register_function("rtl_sim_compile_only_vcs", "run_pre_process", \&compile);
#----------------------------------------------------------------------------------

# Configure test based on testname + sim_opts
ITF::register_function("sequence", "get_variant_list" , \&sequence_variants);
ITF::register_function("sequence", "update_variant" , \&update_sequence);

# Post-Sequencing Seed configuraton and data dump
ITF::register_function("sequence", "run_post_process", \&sequence_post_process);

# Pre-Simulation Stage
ITF::register_function("rtl_sim_simulate_only_vcs", 'run_pre_process', \&simulate);

# do not remove the line below!
1;
