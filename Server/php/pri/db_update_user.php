<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/db_keys.php');

function db_update_user_name($userid,$name)
{
  $db = new TGDB;

  $sql = 'update tg_users set name=? where userid=?'; 
  $result = $db->get($sql,'si',$name,$userid);
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
    $sql = 'replace into tg_email (userid,email,validation) values (?,?,?)';
    $result = $db->get($sql,'iss',$userid,$email,$key);
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
