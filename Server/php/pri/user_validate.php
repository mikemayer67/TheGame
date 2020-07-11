<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

$id = get_exclusive_arg(USERKEY,USERNAME,FBID);

$reply = array();
if( $id[0] == 1 ) // USERKEY
{
  $userkey = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(INVALID_USERKEY); }
}
elseif( $id[0] == 2 ) // USERNAME
{
  $username = $id[1];
  $password = get_required_arg(PASSWORD);
  fail_on_extra_args();

  $info = db_find_user_by_username($username);
  if( empty($info) )                              { send_failure(INVALID_USERNAME);   }
  if( ! db_verify_password($username,$password) ) { send_failure(INCORRECT_PASSWORD); }

  $reply[USERKEY] = $info[USERKEY];
}
else // 3: FBID
{
  $fbid = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_facebook_id($fbid);
  if( empty($info) ) { send_failure(INVALID_FBID); }

  $reply[USERKEY] = $info[USERKEY];
}

if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

db_drop_password_reset($info[USERID]);

send_success($reply);

?>
