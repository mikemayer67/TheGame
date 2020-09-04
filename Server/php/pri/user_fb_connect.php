<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

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
  $db = new TGDB;

  $userkey   = db_gen_userkey();
  $sql = 'insert into tg_users (userkey,fbid) values (?,?)';
  $result = $db->get($sql,'ss',$userkey,$fbid);

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

send_success($reply);

?>

