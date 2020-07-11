<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

$username = get_required_arg(USERNAME);
$password = get_required_arg(PASSWORD);
$alias    = get_optional_arg(ALIAS);
$email    = get_optional_arg(EMAIL);
fail_on_extra_args();

$info = db_find_user_by_username($username);

if( isset($info) )
{ 
  $reply = array();
  if( isset($info[EMAIL]) ) { $reply[EMAIL] = $info[EMAIL]; }
  send_failure(USER_EXISTS, $reply);
}

list ($userid,$userkey) = db_create_user_with_username($username,$password,$alias,$email);
if( empty($userkey) )
{
  send_failure(FAILED_TO_CREATE_USER);
}

if( ! empty($email) ) {
  $intro = "The user account $username was created for TheGame using this email address.";
  email_validation_request($intro,$userid);
}

send_success( array(USERKEY => $userkey) );

?>
