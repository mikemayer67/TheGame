<?php

require_once(__DIR__.'/pri/util.php');

try
{ 
  fail_on_extra_args();  
  send_success();
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
