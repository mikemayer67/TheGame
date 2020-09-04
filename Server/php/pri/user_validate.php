<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');

$id = get_exclusive_arg(USERKEY,USERNAME,FBID);

$reply = array();
if( $id[0] == 1 ) // USERKEY
{
  $userkey = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(INVALID_USERKEY); }
}
elseif( $id[0] == 2 ) // USERNAME
{
  $username = $id[1];
  $password = get_required_arg(PASSWORD);
  fail_on_extra_args();

  $info = db_find_user_by_username($username);
  if( empty($info) ) { send_failure(INVALID_USERNAME);   }

  $db = new TGDB;
  $sql = 'select password from tg_users where username=?';
  $result = $db->get($sql,'s',$username);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple entries for userid=$userid",500); }

  if( $n != 1 ) { return false; }

  $data = $result->fetch_assoc();
  $hashed_password = $data['password'];
  if( ! password_verify($password,$hashed_password) )
  {
    send_failure(INCORRECT_PASSWORD);
  }

  $reply[USERKEY] = $info[USERKEY];
}
else // 3: FBID
{
  $fbid = $id[1];
  fail_on_extra_args();

  $info = db_find_user_by_facebook_id($fbid);

  if( empty($info) ) { send_failure(INVALID_FBID); }

  $reply[USERKEY] = $info[USERKEY];
}

if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

$db = new TGDB;
$userid = $info[USERID];
$sql = 'delete from tg_password_reset where userid=?';
$db->get($sql,'i',$userid);

send_success($reply);

?>
