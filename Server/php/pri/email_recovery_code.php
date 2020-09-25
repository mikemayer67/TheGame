<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

$email = get_required_arg(EMAIL);
$salt  = get_required_arg(SALT);

$result = db_find_user_by_email($email);
$n = count($result);

if( $n == 0 ) { send_failure(INVALID_EMAIL); }

$s = ( $n > 1 ? 's' : '' );

$message = "
      <div><b>We found the following display name$s associated with $email:</b></div>
      <div><br></div>
      <table style='margin-left:1em;'>";

foreach ( $result as $row )
{
  $name   = $row[NAME];
  $userid = $row[USERID];

  $code = db_gen_recovery_code($userid,$salt);

  $message .= "<tr><td>$name</td>";
  $message .= "<td>&nbsp;-&nbsp;</td>";
  $message .= "<td>$code</td>";
}
$message .= "
      </table>
      <br>
      <div>
      The recovery code will only work on the device from which you requested it.
      </div><div>
      The next time you start TheGame, select the option to enter a recovery code
      on the startup screen and enter the code listed above.
      </div";

if( send_email($email, "Recovery Code - TheGame", $message) )
{
  send_success();
}
else
{
  send_failure(EMAIL_FAILURE);
}

?>
