<?php

require_once(__DIR__.'/db.php');

function db_user_badge($userid)
{
  $db = new TGDB;

  $sql = 'select * from tg_user_badge where userid=?';
  $result = $db->get($sql,'i',$userid);
  $n = $result->num_rows;

  if($n>1) { throw new Exception('Multiple players with userid $userid',500); }
  if($n<1) { return 0; }

  $data = $result->fetch_assoc();
  return $data['badge'];
}
