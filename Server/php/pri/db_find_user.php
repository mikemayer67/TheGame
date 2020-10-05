<?php

require_once(__DIR__.'/db.php');

function db_find_user_by_userid($userid)
{
  $db = new TGDB;

  $sql = 'select * from tg_user_info where userid=?';
  $result = $db->get($sql,'i',$userid);
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with userid $userid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_userkey($userkey)
{
  $db = new TGDB;

  $sql = 'select * from tg_user_info where userkey=?';
  $result = $db->get($sql,'s',$userkey);
  $n = $result->num_rows;

  if($n>1) { throw new Exception("Multiple players with userkey $userkey",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_facebook_id($fbid)
{
  $db = new TGDB;

  $sql = 'select * from tg_user_info where fbid=?';
  $result = $db->get($sql,'s',$fbid);
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with facebookd ID $fbid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_email($email)
{
  $db = new TGDB;
 
  $sql = 'select * from tg_user_info where email=?';
  $result = $db->get($sql,'s',$email);
  $data = array();
  if( $result )
  {
    while( $row = $result->fetch_assoc() )
    {
      $data[] = $row;
    }
  }

  return $data;
}

function db_find_user_by_qcode($qcode,$scode)
{
  $db = new TGDB;

  $sql = 'delete from tg_recovery where expires<?';
  $db->get($sql,'i',time());

  $sql = 'select userid from tg_recovery where q_code=? and s_code=?';
  $result = $db->get($sql,'ss',$qcode,$scode);
  $n = $result->num_rows;

  if($n>1) { throw new Exception("Multiple players with q_code=$qcode and s_code=$scode",500); }
  if($n<1) { return null; }

  $data = $result->fetch_assoc();
  $userid = $data[USERID];

  $sql = 'delete from tg_recovery where userid=?';
  $db->get($sql,'i',$userid);

  return db_find_user_by_userid($userid);
}

?>
