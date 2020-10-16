<?php

require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_email.php');

function email_validation_request($email,$userid,$intro)
{
  $key = db_email_validation_key($userid);

  if( empty($email) || empty($key) ) return;
  
  $url = 'https://' . $_SERVER['SERVER_NAME'] . "/thegame/confirm?key=$key";

  $message = "
    <div><b>$intro</b></div>
    <br>
    <div style='margin-left:1em;'>
    Please click <a href='$url'>here</a> to confirm your email address.
    </div>";

  send_email($email, "TheGame email confirmation", $message);
}


function send_email($email, $subject, $message)
{
  $headers = "MIME-Version: 1.0\r\n";
  $headers .= "Content-type:text/html;charset=UTF-8\r\n";

  // More headers
  $admin_email = \Admin::email;
  $admin_name  = \Admin::name;

  $headers .= "From: <$admin_email>\r\n";

  $br = '%0d%0a%0d%0a';

  $mailto = "mailto:$admin_email?subject=TheGame - Email Removal Request&body=Please remove all references to the email address %27$email%27 from TheGame databasees.${br}I understand that this means I will no longer be able to request a recovery code.";

  $message = "
    <html>
    <head><meta http-equiv='Content-Type' content='text/html charset=us-ascii'></head>
    <body style='word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space;'>
    <div><br></div>
    $message
    <div><br></div>
    <div><i>If you did not make this request, please feel free to ignore this email.</i></div>
    <div><i>If you wish this email address be removed from TheGame database, send your request to 
    <a href='$mailto'>".\Admin::name."</a>.</i></div>
    </body>
    </html>";

  if( mail($email,$subject,$message,$headers) )
  {
    return true;
  }
  else
  {
    error_log("Failed to send $subject email to $email");
    return null;
  }
}

