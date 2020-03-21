<?php

class TGDB {
  public  $db = null;

  const DB_USER = 'vmwishes_thegame';
  const DB_PASS = 'Dj4UFGJISrdG';
  const DB_NAME = 'vmwishes_thegame';
  const DB_HOST = 'localhost';

  function __construct()
  {
    if(is_null($this->db))
    {
      $mysqli = new mysqli(self::DB_HOST, self::DB_USER, self::DB_PASS, self::DB_NAME);

      $err = $mysqli->connect_error;
      if( $err )
      {
        $errno = $mysqli->connect_errno;
        throw new Exception( "Failed to connect to database[$errno]: $err", 500 );
      }

      if( ! $mysqli->set_charset('utf8') ) 
      { 
        throw new Exception('Failed to set charset to utf8',500); 
      }

      $this->db = $mysqli;
    }
  }

  public function query($sql)
  {
    $result = $this->db->query($sql);
    if( ! $result ) 
    { 
      $sql = preg_replace('/\s+/',' ',$sql);
      $sql = preg_replace('/^\s/','',$sql);
      $sql = preg_replace('/\s$/','',$sql);

      $trace = debug_backtrace();
      $file = $trace[0]["file"];
      $line = $trace[0]["line"];

      throw new Exception("Invalid SQL: $sql  [invoked at: $file:$line]",500); 
    }
    return $result;
  }

  public function escape($value)
  {
    return $this->db->real_escape_string($value);
  }
};

//
// USER INFO
//

function db_find_user_by_username($username)
{
  $db = new TGDB;

  $sql = "select * from tg_users where username='$username'";
  $result = $db->query($sql);
  $n = $result->num_rows;

  if($n>1) { throw new Exception('Multiple players with username $username',500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_facebook_id($fbid)
{
  $db = new TGDB;

  $result = $db->query("select * from tg_users where fb_id='$fbid'");
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with facebookd ID $fbid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_userid($userid)
{
  $db = new TGDB;

  $result = $db->query("select * from tg_users where userid='$userid'");
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with userid $userid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_userkey($userkey)
{
  $db = new TGDB;

  $result = $db->query("select * from tg_users where user_key='$userkey'");
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with user key $userkey",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_create_user_with_username($username,$password,$alias,$email)
{
  $db = new TGDB;

  $hashed_password = password_hash($password,PASSWORD_DEFAULT);
  $userkey = db_gen_user_key();

  $sql = "insert into tg_users (username,password,user_key) values ('$username','$hashed_password','$userkey')";
  $result = $db->query($sql);

  $sql = 'select last_insert_id()';
  $result = $db->query($sql);
  $data = $result->fetch_array();

  $userid = $data[0];

  if( ! empty($alias) )
  {
    $sql = "update tg_users set alias = '$alias' where userid = $userid";
    $result = $db->query($sql);
  }

  if( ! empty($email) )
  {
    $key = db_gen_email_validation_key();
    $sql = "update tg_users set email='$email', email_validation='$key' where userid=$userid";
    $result = $db->query($sql);
  }

  return $userkey;
}

function db_update_user_password($userid,$password)
{
  $db = new TGDB;

  $hashed_password = password_hash($password,PASSWORD_DEFAULT);

  $sql = "update tg_users set password='$hashed_password' where userid=$userid";
  $result = $db->query($sql);
  return $result;
}

function db_update_user_alias($userid,$alias)
{
  $db = new TGDB;

  if( empty($alias) ) { $sql = "update tg_users set alias=NULL where userid=$userid"; }
  else                { $sql = "update tg_users set alias='$alias' where userid=$userid"; }
  $result = $db->query($sql);
  return $result;
}

function db_update_user_email($userid,$email)
{
  $db = new TGDB;

  if( empty($email) ) { $sql = "update tg_users set email=NULL where userid=$userid"; }
  else                { $sql = "update tg_users set email='$email' where userid=$userid"; }
  $result = $db->query($sql);
  return $result;
}

function db_drop_user($userid)
{
  $db = new TGDB;
  $sql = "delete from tg_users where userid=$userid";
  $result = $db->query($sql);
  return $result;
}

function db_drop_username($userid)
{
  $db = new TGDB;
  $sql = "update tg_users set username=NULL, password=NULL, alias=NULL, email=NULL, userkey=NULL where userid=$userid";
  $result = $db->query($sql);

  db_cleanup();

  return $result;
}

function db_drop_facebook($userid)
{
  $db = new TGDB;
  $sql = "update tg_users set fb_id=NULL where userid=$userid";
  $result = $db->query($sql);

  db_cleanup();

  return $result;
}

function db_confirm_email($key)
{
  $db = new TGDB;
  $sql = "select userid from tg_uses where email_validation='$key'";
  $result = $db->query($sql);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email with same validation key",500); }
  if($n<1) return null;

  $data = $result->fetch_assoc();
  $userid = $data['userid'];

  $sql = "update tg_users set email_validation='Y' where userid=$userid";
  $result = $db->query($sql);

  return $result;
}

// Keys

function db_gen_email_validation_key()
{
  $db = new TGDB;

  $max_attempts = 256;
  for($attempt=0; $attempt<$max_attempts; ++$attempt)
  {
    $key = db_gen_key(24);

    $result = $db->query("select email_validation from tg_users where email_validation='$key'");
    $n = $result->num_rows;
    $result->close();

    if( $n==0 ) { return $key; }
  }

  throw new Exception("Failed to generate a unique ID in $max_attempts attempts", 500);
}

function db_gen_user_key()
{
  $db = new TGDB;

  $max_attempts = 256;
  for($attempt=0; $attempt<$max_attempts; ++$attempt)
  {
    $key = db_gen_key(15);

    $result = $db->query("select user_key from tg_users where user_key='$key'");
    $n = $result->num_rows;
    $result->close();

    if( $n==0 ) { return $key; }
  }

  throw new Exception("Failed to generate a unique ID in $max_attempts attempts", 500);
}

function db_gen_key($n)
{
  $pool = '123456789123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
  $npool = strlen($pool);

  $max_attempts = 256;

  $key = '';
  for( $i=0; $i<$n; $i++)
  {
    $key .= substr($pool,rand(0,$npool-1),1);
  }

  return $key;
}

// Miscellaneous

function db_cleanup()
{
  $db = new TGDB;

  $sql = "delete from tg_users where username is NULL and fb_id is NULL";
  $result = $db->query($sql);
  return $result;
}

?>
