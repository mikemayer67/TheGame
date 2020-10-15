<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/apn.php');

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_find_user.php');

$userkey = get_required_arg(USERKEY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$userid = $info[USERID];

$db = new TGDB;
$now = time();

$sql = 'update tg_users set last_loss=? where userid=?';
$result = $db->get($sql,'ii',$now,$userid);

if( $result )
{
  $sql = 'select * from tg_user_opponents where userid=?';
  $result = $db->get($sql,'i',$userid);
  if( $result )
  {
    $name = $info[NAME];
    while( $row = $result->fetch_assoc() )
    {
      $opponent_id = $row[OPPONENT];
      $rc = send_apn_message(APN_LOSS, $opponent_id, "$name just lost TheGame");
    }
  }

  send_success();
}
else
{
  send_failure(FAILED_TO_UPDATE_USER);
}

?>
