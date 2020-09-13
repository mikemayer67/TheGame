<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey  = get_required_arg(USERKEY);
$token    = get_optional_arg(DEVTOKEN);

$user = db_find_user_by_userkey($userkey);
if( ! isset($user) ) { send_failure(INVALID_USERKEY); }

$userid = $user[USERID];

$db = new TGDB;
if( isset($token) )
{
  $sql = 'update tg_users set dev_token=? where userid=?';
  $result = $db->get($sql, 'si', $token, $userid);
}
else
{
  $sql = 'update tg_users set dev_token=null where userid=?';
  $result = $db->get($sql, 'i', $userid);
}

if( ! $result ) { send_failure(FAILED); }
send_success();
?>
