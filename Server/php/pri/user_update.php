<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_update_user.php');

$userkey  = get_required_arg(USERKEY);
$password = get_optional_arg(PASSWORD);
$alias    = get_optional_arg(ALIAS);
$email    = get_optional_arg(EMAIL);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) send_failure(INVALID_USERKEY);

# only want to apply these updates if the username is set

$username = $info[USERNAME];
if( empty($username) ) send_failure(FAILED_TO_UPDATE_USER);

$userid = $info[USERID];

$updated = array();

if( !empty($password) )
{
  if( db_update_user_password($userid,$password) ) { $updated[] = PASSWORD; }
}

if( isset($alias) ) 
{ 
  if( db_update_user_alias($userid,$alias) ) { $updated[] = ALIAS; }
}

if( isset($email) ) 
{ 
  if( db_update_user_email($userid,$email) ) 
  {
    $updated[] = EMAIL; 

    $cur_email = $info[EMAIL];
    $action = ( empty($cur_email) ? "added to" : "updated for" );
    $intro = "This email address was $action the user account $username for TheGame.";
    email_validation_request($intro,$userid);
  }
}

send_success( array(UPDATED => $updated) );
?>
