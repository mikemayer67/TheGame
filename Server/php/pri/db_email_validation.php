<?php

require_once(__DIR__.'/db.php');

function db_email_validation_key($userid)
{
  $db = new TGDB;
  $sql = 'select email,validation from tg_unvalidated_email where userid=?';
  $result = $db->get($sql,'i',$userid);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email for userid=$userid",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    return array($data['email'], $data['validation']);
  }
}

function db_unvalidated_email($userid)
{
  $db = new TGDB;
  $sql = 'select email from tg_unvalidated_email where userid=?';
  $result = $db->get($sql,'i',$userid);

  $n = $result->num_rows;
  if($n>1) { throw new Exception("Multiple pending email for userid=$userid",500); }

  if( $n == 1 )
  {
    $data = $result->fetch_assoc();
    return $data['email'];
  }
}

?>
