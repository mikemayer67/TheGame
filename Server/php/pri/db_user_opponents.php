<?php

require_once(__DIR__.'/db.php');

function db_user_opponents($userid)
{
  $db = new TGDB;

  $sql = 'select * from tg_user_opponents where userid=?';
  $result = $db->get($sql,'i',$userid);

  $rval = array();
  while($row = $result->fetch_assoc())
  {
    $rval[] = $row[OPPONENT];
  }

  return $rval;
}
