<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_keys.php');
require_once(__DIR__.'/ssl.php');

function db_email_decrypt($email,$iv)
{
  return openssl_decrypt($email,SSL_CIPHER,SSL_KEY,0,hex2bin($iv));
}

function db_email_encrypt($email)
{
  $crc = crc32($email);
  $iv  = openssl_random_pseudo_bytes(openssl_cipher_iv_length(SSL_CIPHER));
  $ivh = bin2hex($iv);
  $email = openssl_encrypt($email,SSL_CIPHER,SSL_KEY,0,$iv);

  return array($email,$ivh,$crc);
}

function db_find_userids_from_email($email)
{
  $db = new TGDB;

  $crc = crc32($email);
  $sql = 'select * from tg_email where crc=?';
  $result = $db->get($sql,'i',$crc);

  $ids = array();
  if( $result )
  {
    while( $row = $result->fetch_assoc() )
    {
      $decrypted = db_email_decrypt($row['email'], $row['iv']);

      if( $email == $decrypted )
      {
        $ids[] = $row['userid'];
      }
    }
  }
  return $ids;
}

function db_email_validation_key($userid)
{
  $db = new TGDB;
  $sql = 'select * from tg_unvalidated_email where userid=?';
  $result = $db->get($sql,'i',$userid);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email for userid=$userid",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    return $data['validation'];
  }
}

function db_lookup_email($userid)
{
  $db = new TGDB;
  $sql = 'select email,iv from tg_email where userid=?';
  $result = $db->get($sql,'i',$userid);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple email for userid=$userid",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    return db_email_decrypt( $data['email'], $data['iv'] );
  }
}

?>
