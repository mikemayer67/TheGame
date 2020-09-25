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

  $pool = '123456789123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
  $npool = strlen($pool);

  $max_attempts = 256;
  for( $attempt=0; $attempt<$max_attempts; $j++)
  {
    $key = '';
    for( $i=0; $i<$length; $i++)
    {
      $key .= substr($pool,rand(0,$npool-1),1);
    }
    $sql = "select $column from $table where $column=?";
    $result = $db->get($sql,'s',$key);
    $n = $result->num_rows;
    $result->close();

    if( $n == 0 ) { return $key; }
  }
  throw new Exception("Failed to generate a unique key in $max_attempts attempts", 500);
}

function db_gen_recovery_code($userid,$salt)
{
  $user_code = rand(1,999999);
  $reset_key = $user_code ^ $salt; 

  $code = str_split($user_code);

  while( count($code) < 6 ) { array_unshift($code,0); }

  $code = implode(' ',$code);

  $db = new TGDB;
  $sql = 'replace into tg_userkey_recovery values (?,?)';
  $result = $db->get($sql,'ii',$userid,$reset_key);

  return $code;
}


?>
