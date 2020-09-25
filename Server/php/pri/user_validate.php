<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');

$id = get_exclusive_arg(USERKEY,FBID);

$reply = array();
if( $id[0] == 1 ) // USERKEY
{
  $userkey = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(INVALID_USERKEY); }
}
else // 3: FBID
{
  $fbid = $id[1];
  $name = get_optional_arg(NAME);
  fail_on_extra_args();

  $info = db_find_user_by_facebook_id($fbid);
  if( empty($info) ) { send_failure(INVALID_FBID); }

  $userid = $info[USERID];

  if( isset($name) ) { db_update_user_name($userid,$name); }

  $reply[USERKEY] = $info[USERKEY];
}

if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

send_success($reply);

?>
