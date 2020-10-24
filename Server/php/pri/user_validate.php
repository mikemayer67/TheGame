<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_update_user.php');

$id = get_exclusive_arg(USERKEY,FBID,QCODE);

$reply = array();
if( $id[0] == 1 ) // USERKEY
{
  $userkey = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(INVALID_USERKEY); }
}
elseif( $id[0] == 2 ) // FBID
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
else // QCODE
{
  $qcode = $id[1];
  $scode = get_required_arg(SCODE);
  fail_on_extra_args();

  $info = db_find_user_by_qcode($qcode,$scode);
  if( empty($info) ) { send_failure(INVALID_QS_CODE); }

  $reply[USERKEY] = $info[USERKEY];
}

$reply[NAME] = $info[NAME];
if( isset($info[FBID]) ) { $reply[FBID] = $info[FBID]; }

if( isset($info[EMAIL]) ) 
{ 
  $reply[VALIDATED] = ( $info[EMAIL] == 'V' ? 1 : 0 );
  $reply[EMAIL]     = db_lookup_email($info[USERID]);
}

if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

send_success($reply);

?>
