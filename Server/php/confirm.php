<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/db.php');
require_once(__DIR__.'/pri/const.php');

$key = get_required_arg("key");

# check for email confirmation key in database

$db = new TGDB;
$sql = 'select userid,name from tg_unvalidated_email where validation=?';
$result = $db->get($sql,'s',$key);

$n = $result->num_rows;
if($n>1) 
{ 
  # database has been corrupted
  throw new Exception("Multiple pending email with same validation key",500); 
}
elseif( $n == 1 )
{
  # found the email confirmation key
  #   clear the validation key (to indicate the email has been validated)
  #   prepare the html to dispaly success
  $data   = $result->fetch_assoc();
  $userid = $data['userid'];
  $name   = $data['name'];

  $sql = 'update tg_email set validation=NULL where userid=?';
  $result = $db->get($sql,'i',$userid);
  
  $title = "Email Confirmed";
  $body = "The email address for $name has been confirmed.";
}
else
{
  # failed to find the email confirmation key
  #   prepare the html to dispaly failure
  $title = "Invalid Link";
  $body = "The link you used to get here is no longer valid.";
}
?>

<html>
  <head>
    <title><?=$title?></title>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@700&display=swap" rel="stylesheet">
  </head>
  <body>
    <div style="font-family: 'Caveat', cursive; font-size:32"><?=$body?></div>
  </body}>
</html>
