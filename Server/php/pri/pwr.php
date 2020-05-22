<?php

require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db.php');

$reset_key = get_required_arg('_');

$info = db_find_user_by_password_reset_key($reset_key);

$username = $info['username'];
error_log($username);
$title = "TheGame Password Reset for $username";

?>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title class=tg-title>TheGame Password Reset for <?=$title?></title>

<!-- Include meta tag to ensure proper rendering and touch zooming -->
<meta name="viewport" content="width=device-width, initial-scale=1">


<!-- Include jQuery Mobile 1.4.5 -->
<link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css" />
<script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>

<script>
  $(document).on("mobileinit", function(){
    $.extend( $.mobile, { linkBindingEnabled: false, ajaxEnabled: false } );
  });
</script>

<script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

<script src='js/pwr.js?v=<?=rand()?>'></script>
<link rel='stylesheet' type='text/css' href='tg.css?v=<?=rand()?>'>

</head>
<body class=tg>

<form>
     <label for="password">New Password:</label>
     <input type="password" data-clear-btn="true" name="password" id="password" value="" autocomplete="off">
     <label for="confirm">Confirm Password:</label>
     <input type="password" data-clear-btn="true" name="confirm" id="confirm" value="" autocomplete="off">
</form>

</body>
</html>

