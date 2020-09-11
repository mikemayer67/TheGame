<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');
require_once(__DIR__.'/db_email_validation.php');

$username = get_required_arg(USERNAME);
$password = get_required_arg(PASSWORD);
$alias    = get_optional_arg(ALIAS);
$email    = get_optional_arg(EMAIL);
fail_on_extra_args();

# check if user already exists
#   if so, return failure

$info = db_find_user_by_username($username);

if( isset($info) )
{ 
  $reply = array();
  if( isset($info[EMAIL]) ) { $reply[EMAIL] = $info[EMAIL]; }
  send_failure(USER_EXISTS, $reply);
}

# otherwise, add the new user to the database

$db = new TGDB;

$userkey   = db_gen_userkey();
$hashed_pw = password_hash($password,PASSWORD_DEFAULT);

$sql = 'insert into tg_users (userkey) values (?)';
$result = $db->get($sql,'s',$userkey);

if( ! $result ) send_failure(FAILED_TO_CREATE_USER);

$userid = $db->last_insert_id();

if( empty($alias) )
{
  $sql = "insert into tg_username (userid,username,password) values (?,?,?)";
  $result = $db->get($sql,'iss',$userid,$username,$hashed_pw);
}
else
{
  $sql = "insert into tg_username (userid,username,password,alias) values (?,?,?,?)";
  $result = $db->get($sql,'isss',$userid,$username,$hashed_pw,$alias);
}

if( ! $result ) 
{
  $db->get('delete from tg_users where userid=?','i',$userid);
  send_failure(FAILED_TO_CREATE_USER);
}

# if email is specified, create an email validation key in the database

if( !empty($email) )
{
  $key = db_gen_email_validation_key();

  $sql = 'insert into tg_email (userid,email,validation) values (?,?,?)';
  $db->get($sql,'iss',$userid,$email,$key);

  email_validation_request(
    "The user account $username was created for TheGame using this email address.",
    $userid);
}

send_success( array(USERKEY => $userkey) );

?>
