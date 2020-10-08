<?php

require_once(__DIR__.'/util.php');
require_once(__DIR__.'/const.php');

$json = file_get_contents('php://input');
$data = json_decode($json);

$email = \Admin::email;

$headers = "MIME-Version: 1.0\r\n";
$headers .= "Content-type:text;charset=UTF-8\r\n";
$headers .= "From: <$email>\r\n";

$subject = "TheGame - InternalError Report";
$message = $data->{'details'};

if( mail($email,$subject,$message,$headers) )
{
  send_success();
}
else
{
  error_log("Failed to send $subject email to $email");
  send_failure(EMAIL_FAILURE);
}

?>

