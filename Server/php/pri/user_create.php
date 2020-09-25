<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');
require_once(__DIR__.'/db_email_validation.php');

$name  = get_required_arg(NAME);
$email = get_optional_arg(EMAIL);
fail_on_extra_args();

$db = new TGDB;

$userkey   = db_gen_userkey();
$hashed_pw = password_hash($password,PASSWORD_DEFAULT);

$sql = 'insert into tg_users (userkey,name,last_loss) values (?,?,0)';
$result = $db->get($sql,'ss',$userkey,$name);

if( ! $result ) send_failure(FAILED_TO_CREATE_USER);

$userid = $db->last_insert_id();

if( !empty($email) )
{
  $key = db_gen_email_validation_key();

  $sql = 'insert into tg_email (userid,email,validation) values (?,?,?)';
  $db->get($sql,'iss',$userid,$email,$key);

  email_validation_request(
    "A new account for $username was created for TheGame using this email address.",
    $userid);
}

send_success( array(USERKEY => $userkey) );

?>
