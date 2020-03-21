<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/db.php');

try
{
  $key = get_required_arg('confirm');
  
  if( db_confirm_email($key) )
  {
?>
<html>
  <head>
    <title>Email Confirmed</title>
  </head>
  <body>
    Thank you.  Your email address has been confirmed.
  </body>
</html>
<?php
  }
  else
  {
    send_http_code(404);
  }
}
catch (Exception $e)
{
  $code = $e->getCode();

  $msg  = $e->getMessage();
  $file = $e->getFile();
  $line = $e->getLine();

  send_http_code(500);
}

