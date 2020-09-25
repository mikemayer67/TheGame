<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/apn.php');

require_once(__DIR__.'/db_find_user.php');

$userkey  = get_required_arg(USERKEY);
$match_id = get_required_arg(MATCHID);

$sender = db_find_user_by_userkey($userkey);
if( ! isset($sender) ) { send_failure(INVALID_USERKEY); }

$sender_id   = $sender[USERID];
$sender_name = $sender[NAME];

$db = new TGDB;
$sql = 'select opponent from tg_user_opponents where match_id=? and userid=?';
$result = $db->get($sql,'ii', $match_id, $sender_id);

$n = $result->num_rows;
if( $n < 1 ) { send_failure(INVALID_OPPONENT); }

$target = $result->fetch_assoc();
$target_id = $target[OPPONENT];

$rc = send_apn_message($target_id, "You have been poked by $sender_name");
send_result($rc);

?>
