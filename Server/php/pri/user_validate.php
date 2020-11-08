<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_update_user.php');

list($key,$value) = get_exclusive_arg(USERKEY,QCODE);

$reply = array();
if( $key == USERKEY )
{
  $userkey = $value;
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(INVALID_USERKEY); }
}
elseif( $key == QCODE )
{
  $qcode = $value;
  $scode = get_required_arg(SCODE);
  fail_on_extra_args();

  $info = db_find_user_by_qcode($qcode,$scode);
  if( empty($info) ) { send_failure(INVALID_QS_CODE); }

  $reply[USERKEY] = $info[USERKEY];
}
else
{
  api_error("Should not be able to get here...");
}

$reply[NAME] = $info[NAME];

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

if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

send_success($reply);

?>
