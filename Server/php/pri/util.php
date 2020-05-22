<?php

$tg_delog       = 1;

define('TG_ROOT',realpath(__DIR__.'/..'));

class Admin
{
  const name       = 'VMWishes Games';
  const email      = 'games@vmwishes.com';
}

class RC
{
  const USER_EXISTS              =  1;
  const INVALID_USERKEY          =  2;
  const INVALID_USERNAME         =  3;
  const INVALID_USERKEY_FBID     =  4;  
  const INCORRECT_USERNAME       =  5;
  const INCORRECT_PASSWORD       =  6;
  const FAILED_TO_CREATE_FBID    =  7;
  const FAILED_TO_CREATE_USER    =  8;
  const FAILED_TO_UPDATE_USER    =  9;
  const NO_EMAIL                 = 10; 
  const INVALID_EMAIL            = 11;
}

if( $tg_delog > 0 )
{
  error_log('----------THE GAME-------------');
  error_log(" URI: " . $_SERVER['REQUEST_URI']);
  if( $tg_delog > 1 )
  {
    error_log("HOST: " . $_SERVER['SERVER_NAME']);
    error_log("GET: " . print_r($_GET,true));
    error_log("POST: " . print_r($_POST,true));
    error_log("REQUEST: " . print_r($_REQUEST,true));
    error_log("COOKIES: " . print_r($_COOKIE,true));
    error_log("HTTP HEADERS...");
    foreach (getallheaders() as $hkey => $hvalue) { error_log("$hkey: $hvalue"); }
  }
}

function array_extract(array &$x,$key)
{
  $rval = null;
  if( isset($x[$key]) )
  {
    $rval = $x[$key];
    unset($x[$key]);
  }
  return $rval;
}

function get_optional_arg($key)
{
  $rval = array_extract($_REQUEST,$key);
  return $rval;
}

function get_required_arg($key)
{
  $rval = array_extract($_REQUEST,$key);
  if( empty($rval) ) { api_error("Missing $key"); }
  return $rval;
}

function get_exclusive_arg(...$keys)
{
  $index = 0;
  foreach ( $keys as $key )
  {
    $index = $index + 1;
    $value = array_extract($_REQUEST,$key);
    if(isset($value))
    {
      if(isset($rval)) 
      { 
        api_error('Cannot specify more than one of: ' . implode(', ', $keys));
      }
      $rval = array($index,$value);
    }
  }
  if( empty($rval) )
  {
    api_error('Must specify at least one of: ' . implode(', ', $keys));
  }
  return $rval;
}

function fail_on_extra_args()
{
  if( count($_REQUEST) > 0 ) { api_error('Extra arguments: ' . implode(', ', array_keys($_REQUEST))); }
}

function api_error($msg)
{
  $bt = debug_backtrace();
  $c  = array_shift($bt);
  $f = substr($c['file'],1+strlen(TG_ROOT));
  $l = $c['line'];
  error_log("API Error: $msg  ($f:$l)\n   URI:".$_SERVER['REQUEST_URI']);
  send_http_code(404);
  exit(1);
}

function send_success($result = null)
{
  if( is_null($result) ) { $result = array(); }

  $result['rc'] = 0;
  print(json_encode($result));
  exit(0);
}

function send_failure($errno,$extra=null)
{
  $result = array('rc'=>$errno);

  if( isset($extra) ) { 
    if( is_array($extra) )
    {
      $result = array_merge($result,$extra);
    }
    else
    {
      $result['reason'] = $extra; 
    }
  }

  print( json_encode($result) );
 
  exit(0);
}

function send_http_code($code)
{
  require(TG_ROOT."/$code.html");
  http_response_code($code);
}

?>
