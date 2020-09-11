<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

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

$db = new TGDB;

if( $dropF and isset($info[FBID]) ) 
{
  $db->get('delete from tg_facebook where userid=?','i',$userid);
  $reply[FBID] = 1;
}

if( $dropU and isset($info[USERNAME]) )
{
  $result = $db->get('delete from tg_username where userid=?','i',$userid);
  $result = $db->get('delete from tg_email where userid=?','i',$userid);

  $reply[USERNAME] = 1;
}

$subsql = 'select userid from tg_user_info where username is null and fb_name is null';
$sql = "delete from tg_users where userid in ( select userid from ($subsql) t )";

$db->get($sql);

$t = db_find_user_by_userkey($userkey);
if( empty($t) ) { $reply[USERKEY] = 1; }

send_success($reply);

?>
