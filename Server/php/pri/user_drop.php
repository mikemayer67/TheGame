<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey = get_required_arg(USERKEY);
$notify  = get_optional_arg(NOTIFY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$userid = $info[USERID];

if( isset($notify) )
{
  error_log('@@@ Need to add drop notification logic');
}

$db = new TGDB;

$db->get('delete from tg_users where userid=?','i',$userid);

send_success();
?>
