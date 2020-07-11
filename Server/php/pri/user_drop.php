<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

$userkey = get_required_arg(USERKEY);
$scope   = get_required_arg(SCOPE);
$notify  = get_optional_arg(NOTIFY);
fail_on_extra_args();

$dropF = ($scope == 'F' || $scope == 'FU');
$dropU = ($scope == 'U' || $scope == 'FU');
if( ! ( $dropF || $dropU ) ) { api_error("Invalid scope: '$scope'"); }

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$userid = $info[USERID];

if( isset($notify) )
{
  error_log('@@@ Need to add drop notification logic');
}

$reply = array();

if( $dropF ) 
{
  db_drop_facebook($userid);
  if( isset($info[FBID]) ) { $reply[FBID] = 1; }
}
if( $dropU )
{
  db_drop_username($userid);
  if( isset($info[USERNAME]) ) { $reply[USERNAME] = 1; }
}

$t = db_find_user_by_userkey($userkey);
if( empty($t) ) { $reply[USERKEY] = 1; }

send_success($reply);

?>
