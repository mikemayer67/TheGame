<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_email.php');

$userkey = get_required_arg(USERKEY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$reply = array( NAME => $info[NAME] );

if( isset($info[FBID]) ) 
{ 
  require_once(__DIR__.'/fb_info.php');
  $fbinfo = fb_info($info[FBID]);
  if($fbinfo)
  {
    $reply[NAME] = $fbinfo[NAME];
    $reply[PICTURE] = $fbinfo[PICTURE];
  }
}

if( isset($info[EMAIL]) ) 
{ 
  $reply[VALIDATED] = ( $info[EMAIL] == 'V' ? 1 : 0 );
  $reply[EMAIL]     = db_lookup_email($info[USERID]);
}

send_success( $reply );

?>
