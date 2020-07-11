<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

$username  = get_required_arg(USERNAME);
$password  = get_required_arg(PASSWORD);
$reset_key = get_required_arg(RESET_KEY);
fail_on_extra_args();

$info = db_find_user_by_username($username);

if( empty($info) ) send_failure(INVALID_USERNAME);

$userid = $info[USERID];

if( db_reset_user_password($userid,$password,$reset_key) )
{
  send_success( array(USERKEY => $info[USERKEY]) );
}
else
{
  send_failure(FAILED_TO_UPDATE_USER);
}

?>
