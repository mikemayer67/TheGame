<?php
namespace email;

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/const.php');

const KEY = 'key';

function confirm()
{
  $key = get_required_arg(KEY);

  $username = db_confirm_email($key);

  if( isset($username) )
  {
    $html = file_get_contents(__DIR__.'/tmpl/confirm_email.htm');
    $html = preg_replace('/{USERNAME}/',$username,$html);
  }
  else
  {
    $html = file_get_contents(__DIR__.'/tmpl/old_key.htm');
  }
  print $html;
}

function username()
{
  $email = get_required_arg('email');
  $salt  = get_required_arg('salt');

  $result = db_find_user_by_email($email);
  $n = count($result);

  if( $n == 0 ) { send_failure(\RC::INVALID_EMAIL); }

  $s = ( $n > 1 ? 's' : '' );

  $message = "
      <div><b>We found the following username$s and password reset code$s associated with $email:</b></div>
      <div><br></div>
      <table style='margin-left:1em;'>";

  foreach ( $result as $row )
  {
    $username = $row[USERNAME];
    $userid   = $row[USERID];

    $code = gen_pw_reset_code($userid,$salt);

    $message .= "<tr><td>$username</td>";
    $message .= "<td>&nbsp;-&nbsp;</td>";
    $message .= "<td>$code</td>";
  }
  $message .= "</table>";

  send_email($email, "Username Reminder - TheGame", $message);
}

function password()
{
  $username  = get_required_arg('username');
  $salt      = get_required_arg('salt');

  $result = db_find_user_by_username($username);
  if( ! isset($result) ) { send_failure(\RC::INVALID_USERNAME); }

  $userid    = $result[USERID];
  $email     = $result[EMAIL];
  $email_val = $result[EMAIL_VAL];

  if( ! isset($email)  )       { send_failure(\RC::INVALID_EMAIL); }
  if( $email_val != VALIDATED) { send_failure(\RC::INVALID_EMAIL); }

  $code = gen_pw_reset_code($userid,$salt);

  $message = "
      <div><b>A password reset code was requested for $username:</b></div>
      <div><br></div>
      <div style='margin-left:1em;'>
      You requested code is: <b>$code</b>
      </div>";

  send_email($email, "Password Reset - TheGame", $message);
}

function gen_pw_reset_code($userid,$salt)
{
  $user_code = rand(1,999999);
  $reset_key = $user_code ^ $salt; 

  $code = str_split($user_code);

  while( count($code) < 6 ) { array_unshift($code,0); }

  $code = implode(' ',$code);

  db_set_password_reset($userid,$reset_key);

  return $code;
}

function error()
{
  $json = file_get_contents('php://input');
  $data = json_decode($json);

  $email = \Admin::email;
  $email = 'mikemayer67@vmwishes.com';

  $headers = "MIME-Version: 1.0\r\n";
  $headers .= "Content-type:text;charset=UTF-8\r\n";
  $headers .= "From: <$email>\r\n";

  $subject = "TheGame - InternalError Report";
  $message = $data->{'details'};

  if( mail($email,$subject,$message,$headers) )
  {
    error_log("$subject email sent to $email");
    send_success();
  }
  else
  {
    error_log("Failed to send $subject email to $email");
    send_failure(\RC::EMAIL_FAILURE);
  }
}


function send_email($email, $subject,$message)
{
  $headers = "MIME-Version: 1.0\r\n";
  $headers .= "Content-type:text/html;charset=UTF-8\r\n";

  // More headers
  $admin_email = \Admin::email;
  $admin_name  = \Admin::name;

  $headers .= "From: <$admin_email>\r\n";

  $br = '%0d%0a%0d%0a';

  $mailto = "mailto:$admin_email?subject=TheGame - Email Removal Request&body=Please remove all references to the email address %27$email%27 from TheGame databasees.${br}I understand that this means I will no longer be able to request username reminders or password resets.";

  $message = "
    <html>
    <head><meta http-equiv='Content-Type' content='text/html charset=us-ascii'></head>
    <body style='word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;'>
    <div><br></div>
    $message
    <div><br></div>
    <div><i>If you did not make this request, please feel free to ignore this email.</i></div>
    <div><i>If you with this email address be removed from TheGame database, send your request to 
    <a href='$mailto'>".\Admin::name."</a>.</i></div>
    </body>
    </html>";

  if( mail($email,$subject,$message,$headers) )
  {
    error_log("$subject email sent to $email");
    send_success();
  }
  else
  {
    error_log("Failed to send $subject email to $email");
    send_failure(\RC::EMAIL_FAILURE);
  }
}

