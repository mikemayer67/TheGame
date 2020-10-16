<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');
require_once(__DIR__.'/db_email.php');

$name  = get_required_arg(NAME);
$email = get_optional_arg(EMAIL);
fail_on_extra_args();

$db = new TGDB;

$userkey   = db_gen_userkey();

$sql = 'insert into tg_users (userkey,name,last_loss) values (?,?,0)';
$result = $db->get($sql,'ss',$userkey,$name);

if( ! $result ) send_failure(FAILED_TO_CREATE_USER);

$userid = $db->last_insert_id();

if( !empty($email) )
{
  $key = db_gen_email_validation_key();
  list ($encrypted_email,$iv,$crc) = db_email_encrypt($email);

  $sql = 'insert into tg_email (userid,crc,iv,email,validation) values (?,?,?,?,?)';
  $db->get($sql,'iisss',$userid,$crc,$iv,$encrypted_email,$key);

  email_validation_request($email, $userid, 
    "A new account for $name was created for TheGame using this email address." );
}

send_success( array(USERKEY => $userkey) );

?>
