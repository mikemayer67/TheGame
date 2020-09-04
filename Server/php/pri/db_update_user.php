<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/db_keys.php');

function db_update_user_password($userid,$password)
{
  $db = new TGDB;

  $hashed_password = password_hash($password,PASSWORD_DEFAULT);

  $sql ='update tg_users set password=? where userid=?';
  $result = $db->get($sql,'si',$hashed_password,$userid);
  return $result;
}

function db_update_user_alias($userid,$alias)
{
  $db = new TGDB;

  if( empty($alias) ) 
  { 
    $sql = 'update tg_users set alias=NULL where userid=?'; 
    $result = $db->get($sql,'i',$userid);
  }
  else 
  { 
    $sql = 'update tg_users set alias=? where userid=?'; 
    $result = $db->get($sql,'si',$alias,$userid);
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
    $sql = 'replace into tg_email (userid,email,validation) values (?,?,?)';
    $result = $db->get($sql,'iss',$userid,$email,$key);
  }
  return $result;
}


function db_add_facebook($userid,$fbid)
{
  $db = new TGDB;

  $sql = 'update tg_users set fbid=? where userid=?';
  $result = $db->get($sql,'si',$fbid,$userid);
  return $result;
}

function db_add_username($userid,$username,$password,$alias,$email)
{
  $db = new TGDB;

  $userkey   = db_gen_userkey();
  $hashed_pw = password_hash($password,PASSWORD_DEFAULT);

  $sql = 'update tg_users set username=?, password=? where userid=?';
  if( ! $db->get($sql,'ssi',$username,$hashed_pw,$userid) ) { return null; }

  if( ! empty($alias) )
  {
    $sql = 'update tg_users set alias=? where userid=?';
    $db->get($sql,'si',$alias,$userid);
  }

  db_update_user_email($userid,$email);

  return $userkey;
}


function db_drop_user($userid)
{
  $db = new TGDB;
  $sql = 'delete from tg_users where userid=?';
  $result = $db->get($sql,'i',$userid);
  return $result;
}


?>
