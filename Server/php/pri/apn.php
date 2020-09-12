<?php

require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_find_user.php');

require_once(__DIR__.'/email.php');  # @@@ REMOVE THIS

function send_apn_message($target_id, $message)
{
  $db = new TGDB;
  $sql = 'select * from tg_users where userid=?';
  $result = $db->get($sql,'i',$target_id);

  $n = $result->num_rows;
  if( $n < 1 ) { api_error("Invalid target ID ($target_id) sent to send_apn_message"); }
  if( $n > 1 ) { api_error("Multiple entries for userid ($target_id) in tg_users"); }

  $target = $result->fetch_assoc();
  $devcert = $target[DEVCERT];

  if( empty($devcert) ) { return false; }

  send_email('mikemayer67@vmwishes.com','APN Test',
    "<div><b>Need to implement APN code in apn.php.</b></div>\n\n".
    "<div style='margin-left:1em;'><b>Message:</b> $message</div>\n\n".
    "<div style='margin-left:1em;'><b>DeviceCert:</b> $devcert\n\n"
  );

  return true;
}
