<?php
namespace user;

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/notify.php');
require_once(__DIR__.'/const.php');

#################################################################################
# Facebook account connection
#################################################################################

function connect()
{
  $fbid    = get_required_arg(FBID);
  $userkey = get_optional_arg(USERKEY); 
  fail_on_extra_args();

  $fb_info = db_find_user_by_facebook_id($fbid);

  $reply = array();
  if( isset($userkey) )  # userkey specified
  {
    $user_info = db_find_user_by_userkey($userkey);

    if( empty($user_info) ) { send_failure(\RC::INVALID_USERKEY); }

    $userid = $user_info[USERID];

    if( isset($fb_info) )  # both FBID and userkey exist, verify they match
    {
      if( $fb_info[USERID] != $userid )   { send_failure(\RC::INVALID_USERKEY_FBID); }

      if( isset($user_info[USERNAME]) ) { $reply[USERNAME] = 1; }
      if( isset($user_info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$user_info[LASTLOSS]; }
    }
    else # new FBID, existing userkey
    {
      if( isset($user_info[FBID] ) )        { send_failure(\RC::INVALID_USERKEY_FBID);  } 
      if( !db_add_facebook($userid,$fbid) ) { send_failure(\RC::FAILED_TO_CREATE_FBID); }

      if( isset($user_info[USERNAME]) ) { $reply[USERNAME] = 1; }
      if( isset($user_info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$user_info[LASTLOSS]; }
    }
  }
  else if(isset($fb_info) ) # existing FBID
  {
    $reply[USERKEY] = $fb_info[USERKEY];
    if( isset($fb_info[USERNAME]) ) { $reply[USERNAME] = 1; }
    if( isset($fb_info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$fb_info[LASTLOSS]; }
  }
  else
  {
    $userkey = db_create_user_with_facebook_id($fbid);
    if( empty($userkey) ) { send_failure(\RC::FAILED_TO_CREATE_USER); }
    $reply[USERKEY] = $userkey;
  }

  send_success($reply);
}

#################################################################################
# User validation
#################################################################################

function validate()
{
  $username = get_optional_arg(USERNAME);

  $reply = array();
  if( isset($username) )
  {
    $password = get_required_arg(PASSWORD);
    $userkey  = get_optional_arg(USERKEY);
    fail_on_extra_args();

    $info = db_find_user_by_username($username);
    if( empty($info) )                                  { send_failure(\RC::INVALID_USERNAME);   }
    if( ! password_verify($password, $info[PASSWORD]) ) { send_failure(\RC::INCORRECT_PASSWORD); }

    if( isset($userkey) )
    {
      $keyinfo = db_find_user_by_userkey($userkey);
      if( empty($keyinfo) ) { send_failure(\RC::INVALID_USERKEY); }

      if( $info[USERKEY] != $userkey ) { 
        if( isset($keyinfo[EMAIL]) )
        {
          $reply[EMAIL] = (int)($keyinfo[EMAIL_VAL] == VALIDATED);
        }
        send_failure(\RC::INCORRECT_USERNAME,$reply); 
      }
    }
    else
    {
      $reply[USERKEY] = $userkey;
    }

    if( isset($info[ALIAS]) ) { $reply[ALIAS] = $info[ALIAS]; }
    if( isset($info[EMAIL]) ) { $reply[EMAIL] = $info[EMAIL]; }
  }
  else
  {
    $userkey  = get_required_arg(USERKEY);
    fail_on_extra_args();

    $info = db_find_user_by_userkey($userkey);
    if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }
  }

  if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = (int)$info[LASTLOSS]; }

  db_drop_password_reset($info[USERID]);

  send_success($reply);
}


#################################################################################
# User account creation
#################################################################################

function create()
{
  $username = get_required_arg(USERNAME);
  $password = get_required_arg(PASSWORD);
  $alias    = get_optional_arg(ALIAS);
  $email    = get_optional_arg(EMAIL);
  fail_on_extra_args();

  $info = db_find_user_by_username($username);

  if( isset($info) )
  { 
    $reply = array();
    if( isset($info[EMAIL]) )
    {
      $reply[EMAIL] = (int)( $info[EMAIL_VAL] == VALIDATED );
    }
    send_failure(\RC::USER_EXISTS, $reply);
  }

  $userkey = db_create_user_with_username($username,$password,$alias,$email);
  if( empty($userkey) )
  {
    send_failure(\RC::FAILED_TO_CREATE_USER);
  }

  send_success( array(USERKEY => $userkey) );
}


#################################################################################
# Drop User 
#################################################################################

function drop()
{
  $userkey = get_required_arg(USERKEY);
  $scope   = get_required_arg(SCOPE);
  $notify  = get_optional_arg(NOTIFY);
  fail_on_extra_args();

  $dropF = ($scope == 'F' || $scope == 'FU');
  $dropU = ($scope == 'U' || $scope == 'FU');
  if( ! ( $dropF || $dropU ) ) { api_error("Invalid scope: '$scope'"); }

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }

  $userid = $info[USERID];
  
  if( isset($notify) )
  {
    error_log('@@@ Need to add drop notification logic');
  }

  $reply = array();

  if( $dropF ) 
  {
    db_drop_facebook($userid);
    if( isset($info[FBID]) ) { $reply[FBID] = 1; }
  }
  if( $dropU )
  {
    db_drop_username($userid);
    if( isset($info[USERNAME]) ) { $reply[USERNAME] = 1; }
  }

  $t = db_find_user_by_userkey($userkey);
  if( empty($t) ) { $reply[USERKEY] = 1; }

  send_success($reply);
}


#################################################################################
# Add username to Facbook connection 
# Add facebook ID to userkey connection
#################################################################################

function add()
{
  $userkey  = get_required_arg(USERKEY);
  $id       = get_exclusive_arg(FBID,USERNAME);

  $info = db_find_user_by_userkey($userkey); 
  if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }

  $userid = $info[USERID];

  if( $id[0] == 1 ) # Add facebook
  {
    $fbid = $id[1];
    fail_on_extra_args();

    $fb_info = db_find_user_by_facebook_id($fbid);
    if( isset($fb_info) )
    {
      if( $fb_info[USERID] != $userid ) { send_failure(\RC::USER_EXISTS); }
    }
    else
    {
      if( ! db_add_facebook($userid,$fbid) ) 
      { 
        send_failure(\RC::FAILED_TO_UPDATE_USER); 
      }
    }
  }
  else # Add username
  {
    $username = $id[1];
    $password = get_required_arg(PASSWORD);
    $alias    = get_optional_arg(ALIAS);
    $email    = get_optional_arg(EMAIL);
    fail_on_extra_args();

    $user_info = db_find_user_by_username($username);
    if( isset($user_info) )
    {
      if( $user_info[USERID] != $userid ) { send_failure(\RC::USER_EXISTS); }

      db_update_user_password($userid,$password);
      db_update_user_alias($userid,$alias);
      db_update_user_email($userid,$email);
    }
    else
    {
      if( ! db_add_username($userid,$username,$password,$alias,$email) )
      {
        send_failure(\RC::FAILED_TO_UPDATE_USER);
      }
    }
  }

  send_success();
}

#################################################################################
# User account updates
#################################################################################

function update()
{
  $userkey  = get_required_arg(USERKEY);
  $password = get_optional_arg(PASSWORD);
  $alias    = get_optional_arg(ALIAS);
  $email    = get_optional_arg(EMAIL);
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) send_failure(\RC::INVALID_USERKEY);

  $userid = $info[USERID];

  $updated = array();

  if( !empty($password) )
  {
    if( db_update_user_password($userid,$password) ) { $updated[] = PASSWORD; }
  }

  if( isset($alias) ) 
  { 
    if( db_update_user_alias($userid,$alias) ) { $updated[] = ALIAS; }
  }

  if( isset($email) ) 
  { 
    if( db_update_user_email($userid,$email) ) { $updated[] = EMAIL; }
  }

  send_success( array(UPDATED => $updated) );
}

function pwreset()
{
  $username  = get_required_arg(USERNAME);
  $password  = get_required_arg(PASSWORD);
  $reset_key = get_required_arg(RESET_KEY);
  fail_on_extra_args();

  $info = db_find_user_by_username($username);
  if( empty($info) ) send_failure(\RC::INVALID_USERNAME);

  $userid = $info[USERID];

  if( db_reset_user_password($userid,$password,$reset_key) )
  {
    send_success( array(USERKEY => $info[USERKEY]) );
  }
  else
  {
    send_failure(\RC::FAILED_TO_UPDATE_USER);
  }
}


#################################################################################
# User Info
#################################################################################

function lookup()
{
  $key = get_exclusive_arg(USERKEY,EMAIL);
  fail_on_extra_args();

  $reply = array();

  if($key[0] == 1)
  {
    $userkey = $key[1];

    $info = db_find_user_by_userkey($userkey);
    if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }

    $reply = array();
    if( isset($info[USERNAME]) ) { $reply[USERNAME] = 1; }
    if( isset($info[FBID])     ) { $reply[FBID]     = 1; }

    if( isset($info[EMAIL]) )
    {
      $reply[EMAIL] = (int)($info[EMAIL_VAL] == VALIDATED);
    }
  }
  elseif($key[0] == 2)
  {
    $email = $key[1];

    $info = db_find_user_by_email($email);
    if( empty($info) ) { send_failure(\RC::INVALID_EMAIL); }
  }

  send_success( $reply );
}
