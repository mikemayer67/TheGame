<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

$userkey = get_required_arg(USERKEY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$reply = array();
if( isset($info[USERNAME]) ) { $reply[USERNAME] = $info[USERNAME]; }
if( isset($info[ALIAS])    ) { $reply[ALIAS]    = $info[ALIAS]; }
if( isset($info[FBID])     ) { $reply[FBID]     = $info[FBID]; }

if( isset($info[EMAIL]) ) 
{ 
  $reply[EMAIL]     = $info[EMAIL]; 
  $reply[VALIDATED] = 1;
}
else
{
  $email = db_unvalidated_email($info[USERID]);
  if( isset($email) )
  {
    $reply[EMAIL] = $email;
    $reply[VALIDATED] = 0;
  }
}

send_success( $reply );

?>
