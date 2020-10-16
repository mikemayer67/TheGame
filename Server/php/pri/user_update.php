<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_update_user.php');

$userkey  = get_required_arg(USERKEY);
$name     = get_optional_arg(NAME);
$email    = get_optional_arg(EMAIL);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) send_failure(INVALID_USERKEY);

# only want to apply these updates if the username is set

$userid = $info[USERID];

$updated = array();

if( isset($name) ) 
{ 
  if( db_update_user_name($userid,$name) ) { $updated[] = NAME; }
}
else
{
  $name = $info[NAME];
}

if( isset($email) ) 
{ 
  if( db_update_user_email($userid,$email) ) 
  {
    $updated[] = EMAIL; 

    $cur_email = $info[EMAIL];
    $action = ( empty($cur_email) ? "added to" : "updated for" );
    $intro = "This email address was $action the account for $name.";
    email_validation_request($email,$userid,$intro);
  }
}

send_success( array(UPDATED => $updated) );
?>
