<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_update_user.php');

$username  = get_required_arg(USERNAME);
$password  = get_required_arg(PASSWORD);
$reset_key = get_required_arg(RESET_KEY);
fail_on_extra_args();

$info = db_find_user_by_username($username);

if( empty($info) ) send_failure(INVALID_USERNAME);

$userid = $info[USERID];

# verify that the provided reset key is correct

$db = new TGDB;
$sql = 'select reset_key from tg_password_reset where userid=?';
$result = $db->get($sql,'i',$userid);
$row = $result->fetch_array();

if( ! isset($row) )         send_failure(FAILED_TO_UPDATE_USER);

$correct_key = $row[0];

if( ! isset($correct_key) )     send_failure(FAILED_TO_UPDATE_USER);
if( $reset_key != $correct_key) send_failure(FAILED_TO_UPDATE_USER);

# a reset key can only be used once
#   remove it from the database

$sql = 'delete from tg_password_reset where userid=?';
$result = $db->get($sql,'i',$userid);

# update the user password and return result

if( db_update_user_password($userid,$password) )
{
  send_success( array(USERKEY => $info[USERKEY]) );
}
else
{
  send_failure(FAILED_TO_UPDATE_USER);
}

?>
