<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/apn.php');

require_once(__DIR__.'/db_find_user.php');

$userkey  = get_required_arg(USERKEY);
$match_id = get_required_arg(MATCHID);
$notify   = get_optional_arg(NOTIFY);

$user = db_find_user_by_userkey($userkey);
if( ! isset($user) ) { send_failure(INVALID_USERKEY); }

$userid = $user[USERID];

$db = new TGDB;
$sql = 'select opponent from tg_user_opponents where match_id=? and userid=?';
$result = $db->get($sql,'ii', $match_id, $userid);

$n = $result->num_rows;

if( $n < 1 ) { send_failure(INVALID_OPPONENT); }
$opponent    = $result->fetch_row();
$opponent_id = $opponent[0];

$sql = 'delete from tg_matches where id=?';
$result = $db->get($sql,'i', $match_id);

if( ! $result ) { send_failure(FAILED); }
if( ! $notify ) { send_success();       }

if( isset($user[FBID]) && isset($user[FBNAME]) ) { $user_name = $user[FBNAME]; }
elseif( isset($user[ALIAS]) )                    { $user_name = $user[ALIAS]; }
elseif( isset($user[USERNAME]) )                 { $user_name = $user[USERNAME]; }

if( ! isset($user_name) )
{
  api_error("Cannot resolve userkey $userkey to a user name or alias");
}

$result = send_apn_message( $opponent_id, 
  "$user_name has withdrawn from their competition with you."
);

send_success( array( NOTIFY => ($result ? 1 : 0) ) );

?>
