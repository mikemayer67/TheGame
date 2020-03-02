<?php

$dir = dirname(__FILE__);

require_once("$dir/ds_init.php");

try
{
  if( $ds_delog > 0 )
  {
    error_log('----------NEW TT-------------');

    error_log("HOST: " . $_SERVER['SERVER_NAME']);
    error_log(" URI: " . $_SERVER['REQUEST_URI']);
    error_log(" GET: " . count($_GET));
    error_log("POST: " . count($_POST));
    error_log(" REQ: " . count($_REQUEST));
    if( $ds_delog > 1 )
    {
      error_log("GET: " . print_r($_GET,true));
      error_log("POST: " . print_r($_POST,true));
      error_log("REQUEST: " . print_r($_REQUEST,true));
      error_log("COOKIES: " . print_r($_COOKIE,true));
      error_log("HTTP HEADERS...");
      foreach (getallheaders() as $hkey => $hvalue) { error_log("$hkey: $hvalue"); }
    }
  }

  if( ! array_key_exists('query',$_REQUEST) )
  {
    require("$dir/404.shtml");
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
    require("$dir/403.shtml"); exit(0);
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
  require("$dir/500.shtml");
}


?>
