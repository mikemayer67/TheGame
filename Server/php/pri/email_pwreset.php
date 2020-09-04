<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

$username  = get_required_arg('username');
$salt      = get_required_arg('salt');

$result = db_find_user_by_username($username);
if( ! isset($result) ) { send_failure(INVALID_USERNAME); }

$userid    = $result[USERID];
$email     = $result[EMAIL];

if( empty($email) ) { send_failure(INVALID_EMAIL); }

$code = db_gen_password_reset_code($userid,$salt);

$message = "
      <div><b>A password reset code was requested for $username:</b></div>
      <div><br></div>
      <div style='margin-left:1em;'>
      You requested code is: <b>$code</b>
      </div>
      <br>
      <div>
      This code will only work on the device from which you requested the password reset.
      The next time you bring up the user login, you will be given the option to 
      reset your password.
      </div";

if( send_email($email, "Password Reset - TheGame", $message) )
{
  send_success();
}
else
{
  send_failure(EMAIL_FAILURE);
}

?>
