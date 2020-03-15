<?php

require_once(__DIR__.'/pri/init.php');
require_once(__DIR__.'/pri/db.php');

try
{
  $action = get_required_arg('action');

  if     ( $action == 'quit'   ) { game_quit();   }
  else
  {
    api_error('Unknown action: ' . $action);
  }
}
catch (Exception $e)
{
  $code = $e->getCode();

  $msg  = $e->getMessage();
  $file = $e->getFile();
  $line = $e->getLine();

  error_log("$file\[$line\]: $msg");
  send_http_code(500);
}


function game_quit()
{
  global $dir;
  send_http_code(420);
}


?>
