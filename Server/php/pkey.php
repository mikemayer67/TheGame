<?php

$dir = dirname(__FILE__);

require_once("$dir/pri/ds_init.php");

try
{
  $rval = array();

  $rval["query"] = "pkey";
  $rval["args"] = $_REQUEST;
  $rval["server"] = $_SERVER;
  $rval["headers"] = getallheaders();

  print( json_encode( $rval ) );
}
catch (Exception $e)
{
  $code = $e->getCode();

  $msg  = $e->getMessage();
  $file = $e->getFile();
  $line = $e->getLine();

  error_log("$file\[$line\]: $msg");
  require("$dir/500.html");
}


?>
