<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/email.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/apn.php');

require_once(__DIR__.'/db_find_user.php');
require_once(__DIR__.'/db_keys.php');

$email  = get_required_arg(EMAIL);
$q_code = get_required_arg(QCODE);
fail_on_extra_args();

if( ! preg_match('/^\w{8}$/', $q_code) ) { send_failure(INVALID_QS_CODE); }

$result = db_find_user_by_email($email);
$n = count($result);

if( $n == 0 ) { send_failure(INVALID_EMAIL); }


$s = ( $n > 1 ? 's' : '' );

$message = "
      <div><b>We found the following display name$s associated with your email address:</b></div>
      <div><br></div>
      <table style='margin-left:1em;'>";

foreach ( $result as $row )
{
  $name   = $row[NAME];
  $userid = $row[USERID];

  $s_code = db_gen_recovery_code($userid,$q_code);
  $s_code = chunk_split($s_code,2,' ');

  $message .= "<tr><td>$name</td>";
  $message .= "<td>&nbsp;-&nbsp;</td>";
  $message .= "<td>$s_code</td>";

  if( isset($row[DEVTOKEN]) )
  {
    send_apn_message($userid, 'Alert', '',
      "A recovery code request was made for accounts associated with your email address."
    );
  }
}

$appropriate = ( $n > 1 ? ' appropriate' : '');

$message .= "
      </table>
      <br>
      <div>
      The code$s will only work on the device from which you made the recovery request
      and will only be good for the next 24 hours.</div><br>
      <div>
      The next time you start TheGame, select <i>recover existing account</i>
      on the startup screen and enter the$appropriate recovery code using the <i>Enter Recovery Code</i> option.
      </div";

if( send_email($email, "Recovery Code$s - TheGame", $message) )
{
  send_success(array(CODECOUNT=>$n));
}
else
{
  send_failure(EMAIL_FAILURE);
}

?>
