<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_email.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/db_keys.php');
require_once(__DIR__.'/apn.php');

function db_update_user_name($userid,$name)
{
  $db = new TGDB;

  $sql = 'select name from tg_users where userid=?';
  $result = $db->get($sql,'i',$userid);
  $n = $result->num_rows;

  if( $n>1 ) { throw new Exception("Multiple players with userid $userid",500); }
  if( $n<1 ) { return false; }

  $data = $result->fetch_assoc();
  $cur_name = $data['name'];

  if( $cur_name == $name ) { return false; }

  $sql = 'update tg_users set name=? where userid=?';
  $result = $db->get($sql,'si',$name,$userid);

  if( $result )
  {
    send_apn_message_to_opponents( APN_UPDATE, $userid,
      "$cur_name is now playing TheGame as $name"
    );
  }

  return $result;
}

function db_update_user_email($userid,$email)
{
  $db = new TGDB;

  if( empty($email) ) 
  { 
    $sql = 'delete from tg_email where userid=?';
    $result = $db->get($sql,'i',$userid);
  }
  else 
  { 
    $key = db_gen_email_validation_key();
    list ($email,$iv,$crc) = db_email_encrypt($email);

    $sql = 'replace into tg_email (userid,crc,iv,email,validation) values (?,?,?,?,?)';
    $result = $db->get($sql,'iisss',$userid,$crc,$iv,$email,$key);
  }
  return $result;
}

function db_add_facebook($userid,$fbid,$name)
{
  $db = new TGDB;

  $sql = 'update tg_facebook_ids set fbid=? where userid=?';
  $result = $db->get($sql,'si',$fbid,$userid);

  if( $result )
  {
    $result = db_update_user_name($userid,$name);
  }

  return $result;
}

function db_drop_user($userid)
{
  $db = new TGDB;
  $sql = 'delete from tg_users where userid=?';
  $result = $db->get($sql,'i',$userid);
  return $result;
}


?>
