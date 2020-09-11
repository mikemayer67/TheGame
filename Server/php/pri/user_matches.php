<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey = get_required_arg(USERKEY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$userid = $info[USERID];

$db = new TGDB;

$sql = 'select * from tg_user_opponents where userid=?';
$result = $db->get($sql,'i',$userid);

$mtches = array();
if( $result )
{
  while( $row = $result->fetch_assoc() )
  {
    $last_loss   = $row[LASTLOSS];
    $match_id    = $row[MATCHID];
    $match_start = $row[MATCHSTART];
    $username    = $row[USERNAME];
    $alias       = $row[ALIAS];
    $fbid        = $row[FBID];
    if( isset($last_loss) && isset($match_start) && isset($match_id) )
    {
      $match = array(
        MATCHID    => $match_id, 
        LASTLOSS   => $last_loss, 
        MATCHSTART => $match_start 
      );

      if( isset($fbid)     ) { $match[FBID] = $fbid;     }
      if( isset($username) ) { $match[NAME] = $username; }
      if( isset($alias)    ) { $match[NAME] = $alias;    }  // yep, intentional override

      if( isset($match[FBID]) || isset($match[NAME]) )
      {
        $matches[] = $match;
      }
    }
  }
}

send_success( array( 'matches' => $matches ) );

?>
