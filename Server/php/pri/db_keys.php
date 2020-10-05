<?php

require_once(__DIR__.'/db.php');

function db_gen_email_validation_key()
{
  return db_gen_key(24,'tg_email','validation');
}

function db_gen_userkey()
{
  return db_gen_key(32,'tg_users','userkey');
}

function db_gen_key($length,$table,$column)
{
  $db = new TGDB;

  $max_attempts = 256;
  foreach( range(1,$max_attempts) as $attempt )
  {
    $key = _db_gen_key($length);

    $sql = "select $column from $table where $column=?";
    $result = $db->get($sql,'s',$key);
    $n = $result->num_rows;
    $result->close();

    if( $n == 0 ) { return $key; }
  }
  throw new Exception("Failed to generate a unique key in $max_attempts attempts", 500);
}

function db_gen_recovery_code($userid,$q_code,$days=1)
{
  $db = new TGDB;
  $now = time();
  $expires = $now + 86400*$days;

  $max_attempts = 256;
  foreach( range(1,$max_attempts) as $attempt )
  {
    $s_code = _db_gen_key(8);

    $sql = 'select userid from tg_recovery where q_code=? and s_code=?';
    $result = $db->get($sql,'ss',$q_code,$s_code);
    $n = $result->num_rows;

    if( $n == 0 ) {
      $sql = 'replace into tg_recovery values (?,?,?,?)';
      $result = $db->get($sql,'issi',$userid,$q_code,$s_code,$expires);
      return $s_code;
    }
  }
  throw new Exception("Failed to generate an s_code in $max_attempts attempts", 500);
}

function _db_gen_key($length)
{
  $pool = '2345678923456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  $npool = strlen($pool);

  $s_code = '';
  foreach( range(1,$length) as $i )
  {
    $s_code .= $pool[ rand(0,$npool-1) ];
  }
  return $s_code;
}


?>
