<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

$email = get_required_arg('email');
$salt  = get_required_arg('salt');

$result = db_find_user_by_email($email);
$n = count($result);

if( $n == 0 ) { send_failure(INVALID_EMAIL); }

$s = ( $n > 1 ? 's' : '' );

$message = "
      <div><b>We found the following username$s and password reset code$s associated with $email:</b></div>
      <div><br></div>
      <table style='margin-left:1em;'>";

foreach ( $result as $row )
{
  $username = $row[USERNAME];
  $userid   = $row[USERID];

  $code = db_gen_password_reset_code($userid,$salt);

  $message .= "<tr><td>$username</td>";
  $message .= "<td>&nbsp;-&nbsp;</td>";
  $message .= "<td>$code</td>";
}
$message .= "
      </table>
      <br>
      <div>
      The password reset code will only work on the device from which you requested the
      username reminder.  The next time you bring up the user login, you will be given
      the option to reset your password.
      </div";

if( send_email($email, "Username Reminder - TheGame", $message) )
{
  send_success();
}
else
{
  send_failure(EMAIL_FAILURE);
}

?>
