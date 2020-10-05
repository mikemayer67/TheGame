<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

$userkey = get_required_arg(USERKEY);
$q_code  = get_required_arg(QCODE);
$valid   = get_optional_arg(VALID);  // days
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( ! isset($info) ) { send_failure(INVALID_USERKEY); }

if( ! preg_match('/^\w{8}$/', $q_code) ) { send_failure(INVALID_QS_CODE); }

$userid = $info[USERID];

if( ! isset($valid) ) { $valid = 7; }

$s_code = db_gen_recovery_code($userid,$q_code,$valid);

send_success( array(SCODE=>$s_code, VALID=>$valid) );
?>
