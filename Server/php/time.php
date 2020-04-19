<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/notify.php');

try
{ 
  fail_on_extra_args();  
  $time = time();
  send_success(array('time'=>$time));
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
