<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/db.php');
require_once(__DIR__.'/pri/const.php');

$key = get_required_arg("key");

$username = db_confirm_email($key);

if( isset($username) )
{
?>

<html>
  <head>
    <title>Email Confirmed</title>
  </head>
  <body>
    The email address for <?=$username?> has been confirmed.
  </body}>
</html>

<?php } else { ?>

<html>
  <head>
    <title>Invalid Link</title>
  </head>
  <body>
    The link you used to get here is no longer valid.
  </body}>
</html>

<?php } ?>
