<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey  = get_required_arg(USERKEY);
$token    = get_optional_arg(DEVTOKEN);
fail_on_extra_args();

$user = db_find_user_by_userkey($userkey);
if( ! isset($user) ) { send_failure(INVALID_USERKEY); }

$userid = $user[USERID];

$db = new TGDB;
if( isset($token) )
{
  $sql = 'replace into tg_dev_tokens values (?,?)';
  $result = $db->get($sql, 'is', $userid, $token);
}
else
{
  $sql = 'delete from tg_dev_tokens where userid=?';
  $result = $db->get($sql, 'i', $userid);
}

if( ! $result ) { send_failure(FAILED); }
send_success();
?>
