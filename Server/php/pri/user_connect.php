<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

$fbid    = get_required_arg(FBID);
fail_on_extra_args();

$info = db_find_user_by_facebook_id($fbid);

$reply = array();
if(isset($info) ) # existing FBID
{
  $reply[USERKEY] = $info[USERKEY];
  if( isset($info[LASTLOSS]) ) $reply[LASTLOSS] = (int)$info[LASTLOSS];
}
else
{
  $userkey = db_create_user_with_facebook_id($fbid);
  if( empty($userkey) ) { send_failure(FAILED_TO_CREATE_USER); }
  $reply[USERKEY] = $userkey;
  $reply[LASTLOSS] = 0;
}

send_success($reply);

?>

