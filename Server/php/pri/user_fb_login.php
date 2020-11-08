<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/fb_info.php');
require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

$fbid = get_required_arg(FBID);
fail_on_extra_args();

$fbinfo = fb_info($fbid);
if( empty($fbinfo) ) { send_failure(INVALID_FBID); }

$info = db_find_user_by_facebook_id($fbid);

$reply = array();
if(isset($info) ) # existing FBID
{
  $reply[USERKEY] = $info[USERKEY];
  if( isset($info[LASTLOSS]) ) $reply[LASTLOSS] = (int)$info[LASTLOSS];

  db_update_user_name($info[USERID],$fbinfo[NAME]);
}
else
{
  $db = new TGDB;

  $userkey   = db_gen_userkey();

  $sql = 'insert into tg_users (userkey,name,last_loss) values (?,?,0)';
  $result = $db->get($sql,'ss',$userkey,$fbinfo[NAME]);

  if( ! $result ) send_failure(FAILED_TO_CREATE_USER);

  $userid = $db->last_insert_id();

  $sql = 'insert into tg_facebook_ids (userid,fbid) values (?,?)';
  $result = $db->get($sql,'is',$userid,$fbid);

  if( $result )
  {
    $reply[USERKEY] = $userkey;
    $reply[LASTLOSS] = 0;
  }
  else
  {
    send_failure(FAILED_TO_CREATE_FBID); 
  }
}

$reply[NAME] = $fbinfo[NAME];
if( isset($fbinfo[PICTURE]) ) { $reply[PICTURE] = $fbinfo[PICTURE]; }

send_success($reply);

?>

elseif( $id[0] == 2 ) // FBID
{
  $fbid = $id[1];
  $name = get_optional_arg(NAME);
  fail_on_extra_args();

  if(isset($name)) { error_log("Validating: $fbid / $name"); }
  else { error_log("Validating: $fbid / no-name"); }

  $info = db_find_user_by_facebook_id($fbid);
  error_log("info = " . print_r($info,true));
  if( empty($info) ) { error_log("send INVALID_FBID"); send_failure(INVALID_FBID); }

  $userid = $info[USERID];
  error_log("userid = $userid");

  if( isset($name) ) { error_log("db_update_user_name($userid,$name)"); db_update_user_name($userid,$name); }

  $reply[USERKEY] = $info[USERKEY];

  error_log("reply = " . print_r($reply,true));
}
