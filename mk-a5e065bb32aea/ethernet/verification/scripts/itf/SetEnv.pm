#This is the SetENV file

package SetEnv;

use vars qw(@EXPORT);
use Cwd;
use RegTest;

@EXPORT = qw (setup_env);

sub setup_env () {
    my $cwd = cwd();

    $ENV{'TB_PATH'}                   = $ENV{'REG_LOCAL_ROOT_DIR_PATH'}; 
    $ENV{'HOME_PATH'}                 = $ENV{'REG_LOCAL_ROOT_DIR_PATH'};

} 

