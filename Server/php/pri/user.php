<?php
namespace user;

require_once(__DIR__.'/db.php');
require_once(__DIR__.'/notify.php');

const USERID      = 'userid';
const FBID        = 'fbid';
const USERKEY     = 'userkey';
const USERNAME    = 'username';
const PASSWORD    = 'password';
const ALIAS       = 'alias';
const EMAIL       = 'email';
const EMAIL_VAL   = 'email_validation';
const LASTLOSS    = 'last_loss';
const VALIDATED   = 'Y';
const DROPPED     = 'dropped';
const UPDATED     = 'updated';
const SCOPE       = 'scope';
const NOTIFY      = 'notify';

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
      if( isset($user_info[LASTLOSS]) ) { $reply[LASTLOSS] = $user_info[LASTLOSS]; }
    }
    else # new FBID, existing userkey
    {
      if( isset($user_info[FBID] ) )        { send_failure(\RC::INVALID_USERKEY_FBID);  } 
      if( !db_add_facebook($userid,$fbid) ) { send_failure(\RC::FAILED_TO_CREATE_FBID); }

      if( isset($user_info[USERNAME]) ) { $reply[USERNAME] = 1; }
      if( isset($user_info[LASTLOSS]) ) { $reply[LASTLOSS] = $user_info[LASTLOSS]; }
    }
  }
  else if(isset($fb_info) ) # existing FBID
  {
    $reply[USERKEY] = $fb_info[USERKEY];
    if( isset($fb_info[USERNAME]) ) { $reply[USERNAME] = 1; }
    if( isset($fb_info[LASTLOSS]) ) { $reply[LASTLOSS] = $fb_info[LASTLOSS]; }
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
  }
  else
  {
    $userkey  = get_required_arg(USERKEY);
    fail_on_extra_args();

    $info = db_find_user_by_userkey($userkey);
    if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }
  }

  if( isset($info[LASTLOSS]) ) { $reply[LASTLOSS] = $info[LASTLOSS]; }

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

  $dropped = array();

  if( $dropF ) 
  {
    db_drop_facebook($userid);
    if( isset($info[FBID]) ) { $dropped[] = 'F'; }
  }
  if( $dropU )
  {
    db_drop_username($userid);
    if( isset($info[USERNAME]) ) { $dropped[] = 'U'; }
  }

  send_success( array( DROPPED=>$dropped ) );
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


#################################################################################
# User Info
#################################################################################

function info()
{
  $userkey = get_required_arg(USERKEY);
  fail_on_extra_args();

  $info = db_find_user_by_userkey($userkey);
  if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }

  $reply = array();
  if( isset($info[USERNAME]) ) { $reply[USERNAME] = 1; }
  if( isset($info[FBID])     ) { $reply[FBID]     = 1; }

  if( isset($info[EMAIL]) )
  {
    $reply[EMAIL] = (int)($info[EMAIL_VAL] == VALIDATED);
  }

  send_success( $reply );
}

#################################################################################
# Send Email
#################################################################################

function email()
{
  $id = get_exclusive_arg(USERKEY,USERNAME);
  fail_on_extra_args();

  if( $id[0] == 1 )
  {
    $info = db_find_user_by_userkey($id[1]);
    if( empty($info) ) { send_failure(\RC::INVALID_USERKEY); }
  }
  else
  {
    $info = db_find_user_by_username($id[1]);
    if( empty($info) ) { send_failure(\RC::INVALID_USERNAME); }
  }

  if( empty($info[EMAIL]) ) { send_failure(\RC::NO_VALIDATED_EMAIL); }

  if( $info[EMAIL_VAL] != VALIDATED )
  {
    send_failure(\RC::NO_VALIDATED_EMAIL, array(EMAIL => 0) );
  }
  
  error_log('@@@ Need to add username/password email');

  send_success();
}

