
package RegressionList;

use YAML::Syck;
use Data::Dumper;

sub split_opt_str_into_array {
  my ($str_opt) = @_;
  my @options = split(/ ?(?=--)/, $str_opt);
  return \@options;
}

sub parse_config {
  my ($yaml_cfg) = @_;
  
  foreach my $test_grp_key (keys %{$yaml_cfg}) {
    my $tests = $yaml_cfg->{$test_grp_key}->{'tests'};
    my $compile_flags = split_opt_str_into_array($yaml_cfg->{$test_grp_key}->{'compile_flags'});
    $yaml_cfg->{$test_grp_key}->{'compile_flags'} = $compile_flags;

    while (my ($name, $test_cmd) = each %$tests) {
      my %test_config = (
        'name' => $name,
        'uvm_testname' => $test_cmd->{'uvm_testname'},
        'options' => split_opt_str_into_array($test_cmd->{'options'})
      );
      $tests->{$name} = \%test_config;
    }
  }
}

sub RegressionList::new {
  my ($class, $regression_file) = @_;

  if (!defined $regression_file) {
    return bless {
      regression_file => undef,
      yaml_cfg => {},
      is_defined => 0
    }, $class;
  }

  my $data = LoadFile($regression_file);
  parse_config($data);

  my $self = {
    regression_file => $regression_file,
    yaml_cfg => $data,
    is_defined => 1
  };

  return bless $self, $class;
}

sub RegressionList::is_defined {
  my ($self) = @_;
  return $self->{'is_defined'};
}

sub RegressionList::get_test_groups {
  my ($self) = @_;
  my $yaml_cfg = $self->{'yaml_cfg'};
  my @test_groups = keys %$yaml_cfg;
  return \@test_groups;
}

sub RegressionList::get_test_group {
  my ($self, $test_group) = @_;
  my $yaml_cfg = $self->{'yaml_cfg'};

  return $yaml_cfg->{$test_group};
}

sub RegressionList::get_num_seeds_for_test_group {
  my ($self, $test_group) = @_;
  my $yaml_cfg = $self->{'yaml_cfg'};

  return $yaml_cfg->{$test_group}->{'num_seeds'};
}

sub RegressionList::get_testlist_for_test_group {
  my ($self, $test_group) = @_;
  my $yaml_cfg = $self->{'yaml_cfg'};

  if (!exists $yaml_cfg->{$test_group}) {
    print "ERROR - test group does not exist!";
    return;
  }

  my @testlist = keys %{ $yaml_cfg->{$test_group}->{'tests'} };
  return \@testlist;
}

sub RegressionList::get_config_for_test {
  my ($self, $test_group, $name) = @_;
  my $yaml_cfg = $self->{'yaml_cfg'};

  return $yaml_cfg->{$test_group}->{'tests'}->{$name};
}

sub RegressionList::get_compile_flags_for_test_group {
  my ($self, $test_group) = @_;
  return $self->{'yaml_cfg'}->{$test_group}->{'compile_flags'};
}

1;

# my $regression_list = RegressionList->new("regression_config.yaml");
# my $thing = $regression_list->get_config_for_test("sanity", "switch_csr_test");
# print Dumper($thing)
# print Dumper($regression_list);

# my $test_groups = get_test_groups($regression_list);
# my $tests = get_testlist_for_test_group("performance", $regression_list);
# print Dumper($tests);

# my $num_seeds = get_num_seeds_for_test_group("performance", $regression_list);
# print "$num_seeds\n";

