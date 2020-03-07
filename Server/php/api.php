<?php

$dir = dirname(__FILE__);

require_once("$dir/pri/ds_init.php");

try
{
  if( ! array_key_exists('query',$_REQUEST) )
  {
    require("$dir/404.html");
    exit(0);
  }

  $rval = array();

  switch(strtolower($_REQUEST["query"]))
  {
  case "pkey":
    $rval["pkey"] = $_REQUEST["query"];
    $rval["args"] = $_REQUEST;
    $rval["server"] = $_SERVER;
    $rval["headers"] = getallheaders();
    break;
  default:
    require("$dir/403.html"); exit(0);
    break;
  }

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
