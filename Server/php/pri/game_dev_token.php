<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey  = get_optional_arg(USERKEY);
$token    = get_optional_arg(DEVTOKEN);
fail_on_extra_args();

$db = new TGDB;

if( ! (isset($token) || isset($userkey)) )
{
  api_error("Must specify " . USERKEY . ", " . DEVTOKEN . ", or both");
}

if( isset($token) )
{
  $sql = 'delete from tg_dev_tokens where dev_token=?';
  $db->get($sql,'s',$token);
}

if( isset($userkey) )
{
  $user = db_find_user_by_userkey($userkey);
  if( ! isset($user) ) { send_failure(INVALID_USERKEY); }

  $userid = $user[USERID];

  if( isset($token) )
  {
    $sql = 'insert into tg_dev_tokens values (?,?)';
    $result = $db->get($sql, 'is', $userid, $token);

    if( ! $result ) { send_failure(FAILED); }
  }
  else
  {
    $sql = 'delete from tg_dev_tokens where userid=?';
    $db->get($sql,'i',$userid);
  }
}

send_success();

?>
