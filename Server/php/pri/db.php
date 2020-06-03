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

  public function last_insert_id()
  {
    return $this->db->insert_id;
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

  $sql = "select * from tg_user_info where username='$username'";
  $result = $db->query($sql);
  $n = $result->num_rows;

  if($n>1) { throw new Exception('Multiple players with username $username',500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_userkey($userkey)
{
  $db = new TGDB;

  $sql = "select * from tg_user_info where userkey='$userkey'";
  $result = $db->query($sql);
  $n = $result->num_rows;

  if($n>1) { throw new Exception('Multiple players with userkey $userkey',500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_facebook_id($fbid)
{
  $db = new TGDB;

  $sql = "select * from tg_user_info where fbid='$fbid'";
  $result = $db->query($sql);
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with facebookd ID $fbid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_userid($userid)
{
  $db = new TGDB;

  $result = $db->query("select * from tg_user_info where userid=$userid");
  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple players with userid $userid",500); }

  $data = $result->fetch_assoc();
  return $data;
}

function db_find_user_by_email($email)
{
  $db = new TGDB;
 
  $sql = "select * from tg_user_info where email='$email'";
  $result = $db->query($sql);
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

function db_create_user_with_username($username,$password,$alias,$email)
{
  $db = new TGDB;

  $userkey   = db_gen_userkey();
  $hashed_pw = password_hash($password,PASSWORD_DEFAULT);

  $columns = 'userkey,username,password';
  $values  = "'$userkey','$username','$hashed_pw'";

  if( !empty($alias) )
  {
    $columns .= ',alias';
    $values  .= ",'$alias'";
  }

  $sql = "insert into tg_users ($columns) values ($values)";
  if( ! $db->query($sql) ) { return null; }

  $userid = $db->last_insert_id();

  if( !empty($email) )
  {
    $key = db_gen_email_validation_key();

    $columns = "userid,email,validation";
    $values  = "$userid, '$email', '$key'";
    $sql = "insert into tg_email ($columns) values ($values)";

    $db->query($sql);
  }

  return array($userid,$userkey);
}

function db_create_user_with_facebook_id($fbid)
{
  $db = new TGDB;

  $userkey   = db_gen_userkey();
  $sql = "insert into tg_users (userkey,fbid) values ('$userkey','$fbid')";

  if( $db->query($sql) ) { return $userkey; }

  return null;
}

function db_update_user_password($userid,$password)
{
  $db = new TGDB;

  $hashed_password = password_hash($password,PASSWORD_DEFAULT);

  $sql = "update tg_users set password='$hashed_password' where userid=$userid";
  $result = $db->query($sql);
  return $result;
}

function db_reset_user_password($userid,$password,$reset_key)
{
  $cur_key = db_get_password_reset($userid);
  if( ! isset($cur_key) ) return null;
  if( $reset_key != $cur_key) return null;

  db_drop_password_reset($userid);

  return db_update_user_password($userid,$password);
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

  if( empty($email) ) 
  { 
    $sql = "delete from tg_email where userid=$userid";
  }
  else 
  { 
    $key = db_gen_email_validation_key();
    $columns = "userid,email,validation";
    $values  = "$userid, '$email', '$key'";
    $sql = "replace into tg_email ($colunns) values ($values)";
  }
  $result = $db->query($sql);
  return $result;
}

function db_add_facebook($userid,$fbid)
{
  $db = new TGDB;

  $sql = "update tg_users set fbid='$fbid' where userid=$userid";
  $result = $db->query($sql);
  return $result;
}

function db_add_username($userid,$username,$password,$alias,$email)
{
  $db = new TGDB;

  $userkey   = db_gen_userkey();
  $hashed_pw = password_hash($password,PASSWORD_DEFAULT);

  $sql = "update tg_users set username='$username', password='$hashed_pw' where userid=$userid";

  if( ! $db->query($sql) ) { return null; }

  if( ! empty($alias) )
  {
    $sql = "update tg_users set alias = '$alias' where userid=$userid";
    $db->query($sql);
  }

  db_update_user_email($userid,$email);

  return $userkey;
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
  $sql = "update tg_users set username=NULL, password=NULL, alias=NULL where userid=$userid";
  $result = $db->query($sql);

  if( $result )
  {
    $sql = "delete from tg_email where userid = $userid";
    $db->query($sql);

    $sql = "delete from tg_users where username is NULL and fbid is NULL";
    $db->query($sql);
  }

  return $result;
}

function db_drop_facebook($userid)
{
  $db = new TGDB;

  $sql = "update tg_users set fbid=NULL where userid=$userid";
  $result = $db->query($sql);

  if( $result )
  {
    $sql = "delete from tg_users where username is NULL and fbid is NULL";
    $db->query($sql);
  }

  return $result;
}

function db_find_matches($userid)
{
  $db = new TGDB;

  $sql = "select * from tg_user_opponents where userid=$userid";
  $result = $db->query($sql);

  $data = array();
  if( $result )
  {
    while( $row = $result->fetch_assoc() )
    {
      $last_loss   = $row['last_loss'];
      $match_id    = $row['match_id'];
      $match_start = $row['match_start'];
      $fbid        = $row['fbid'];
      $username    = $row['username'];
      $alias       = $row['alias'];
      if( isset($last_loss) && isset($match_start) && isset($match_id) )
      {
        $match = array(
          'match_id' => $match_id, 
          'last_loss' => $last_loss, 
          'match_start' => $match_start 
        );

        if( isset($fbid) ) { 
          $match['fpid'] = $fbid;
          $data[] = $match;
        }
        elseif( isset($alias) )
        {
          $match['name'] = $alias;
          $data[] = $match;
        }
        elseif( isset($username) )
        {
          $match['name'] = $username;
          $data[] = $match;
        }
      }
    }
  }
  return $data;
}

// Email Validation

function db_confirm_email($key)
{
  $db = new TGDB;
  $sql = "select userid,username from tg_unvalidated_email where validation='$key'";
  $result = $db->query($sql);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email with same validation key",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    $userid = $data['userid'];
    $username = $data['username'];

    $sql = "update tg_email set validation=NULL where userid=$userid";
    $result = $db->query($sql);

    return $username;
  }

  return null;
}

function db_email_validation_key($userid)
{
  $db = new TGDB;
  $sql = "select email,validation from tg_unvalidated_email where userid=$userid";
  $result = $db->query($sql);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email for userid=$userid",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    return array($data['email'], $data['validation']);
  }
}

// Password

function db_verify_password($username,$password)
{
  $db = new TGDB;
  $sql = "select password from tg_users where username='$username'";
  $result = $db->query($sql);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple entries for userid=$userid",500); }

  if( $n != 1 ) { return false; }

  $data = $result->fetch_assoc();
  $hashed_password = $data['password'];
  return password_verify($password,$hashed_password);
}

function db_set_password_reset($userid,$reset_key)
{
  $db = new TGDB;
  $sql = "replace into tg_password_reset values ($userid,$reset_key)";
  $result = $db->query($sql);
  return $result;
}

function db_get_password_reset($userid)
{
  $db = new TGDB;
  $sql = "select reset_key from tg_password_reset where userid=$userid";
  $result = $db->query($sql);
  $row = $result->fetch_array();
  return $row[0];
}

function db_drop_password_reset($userid)
{
  $db = new TGDB;
  $sql = "delete from tg_password_reset where userid=$userid";
  $result = $db->query($sql);
  return $result;
}

// Keys

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
    $sql = "select $column from $table where $column='$key'";
    $result = $db->query($sql);
    $n = $result->num_rows;
    $result->close();

    if( $n == 0 ) { return $key; }
  }
  throw new Exception("Failed to generate a unique key in $max_attempts attempts", 500);
}

?>
