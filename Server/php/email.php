<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/email.php');

try 
{
  $action = get_required_arg('action');

  if     ( $action == 'confirm'  ) { email\confirm();  }
  elseif ( $action == 'username' ) { email\username(); }
  elseif ( $action == 'pwreset'  ) { email\pwreset(); }
  
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

  send_http_code(500);
}

?>
