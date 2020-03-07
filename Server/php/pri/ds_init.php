<?php

$ds_delog       = 2;

$ds_admin       = 'Mike Mayer';
$ds_admin_email = 'mikemayer67@vmwishes.com';
$ds_admin_uri   = "mailto:$ds_admin_email?Subject=".urlencode("The Game");
$ds_admin_email_link = "<a href='$ds_admin_uri'>$ds_admin</a>";

if( $ds_delog > 0 )
{
  error_log('----------NEW GAME-------------');
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

?>
