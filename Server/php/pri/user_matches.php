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
    $match = array(
      MATCHID    => $row[MATCHID],
      NAME       => $row[NAME],
      LASTLOSS   => $row[LASTLOSS],
      MATCHSTART => $row[MATCHSTART],
    );

    if( isset($fbid) ) { $match[FBID] = $fbid; }

    $matches[] = $match;
  }
}

send_success( array( 'matches' => $matches ) );

?>
