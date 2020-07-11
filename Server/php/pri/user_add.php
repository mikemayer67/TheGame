<?php

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

#################################################################################
# Add username to Facbook connection 
# Add facebook ID to userkey connection
#################################################################################

function add()
{
  send_failure(NOT_YET_IMPLEMENTED);
//  $userkey  = get_required_arg(USERKEY);
//  $id       = get_exclusive_arg(FBID,USERNAME);
//
//  $info = db_find_user_by_userkey($userkey); 
//  if( empty($info) ) { send_failure(INVALID_USERKEY); }
//
//  $userid = $info[USERID];
//
//  if( $id[0] == 1 ) # Add facebook
//  {
//    $fbid = $id[1];
//    fail_on_extra_args();
//
//    $fb_info = db_find_user_by_facebook_id($fbid);
//    if( isset($fb_info) )
//    {
//      if( $fb_info[USERID] != $userid ) { send_failure(USER_EXISTS); }
//    }
//    else
//    {
//      if( ! db_add_facebook($userid,$fbid) ) 
//      { 
//        send_failure(FAILED_TO_UPDATE_USER); 
//      }
//    }
//  }
//  else # Add username
//  {
//    $username = $id[1];
//    $password = get_required_arg(PASSWORD);
//    $alias    = get_optional_arg(ALIAS);
//    $email    = get_optional_arg(EMAIL);
//    fail_on_extra_args();
//
//    $user_info = db_find_user_by_username($username);
//    if( isset($user_info) )
//    {
//      if( $user_info[USERID] != $userid ) { send_failure(USER_EXISTS); }
//
//      db_update_user_password($userid,$password);
//      db_update_user_alias($userid,$alias);
//      db_update_user_email($userid,$email);
//    }
//    else
//    {
//      if( ! db_add_username($userid,$username,$password,$alias,$email) )
//      {
//        send_failure(FAILED_TO_UPDATE_USER);
//      }
//    }
//
//    if( ! empty($email) )
//    {
//      $intro = "This email address was added to the user account $username for TheGame";
//      email_validation_request($intro,$userid);
//    }
//  }
//
//  send_success();
}
?>
