<?php

require_once(__DIR__.'/pri/init.php');
require_once(__DIR__.'/pri/db.php');
require_once(__DIR__.'/pri/notify.php');

try
{
  $action = get_required_arg('action');

  if     ( $action == 'create' ) { user_create(); }
  elseif ( $action == 'update' ) { user_update(); }
  elseif ( $action == 'info'   ) { user_info();   }
  elseif ( $action == 'drop'   ) { user_drop();   }
  else
  {
    api_error('Unknown action: ' . $action);
  }
}
catch (Exception $e)
{
  $code = $e->getCode();

  $msg  = $e->getMessage();
  $file = $e->getFile();
  $line = $e->getLine();

  send_http_code(500);
}

#################################################################################
# User account creation
#################################################################################

function user_create()
{
  $id = get_exclusive_arg('username','fbid');

  if( $id[0] == 1 ) # create account with username and password
  {
    $username = $id[1];
    $password = get_required_arg('password');
    $alias    = get_optional_arg('alias');
    $email    = get_optional_arg('email');
    fail_on_extra_args();

    $user_data = db_find_user_by_username($username);

    if( ! empty($user_data) ) { send_failure(1); }

    $userkey = db_create_user_with_username($username,$password,$alias,$email);

    if( empty($userkey) ) { send_failure(2); }

    send_success( array('userkey' => $userkey) );
  }
  else # create account with Facebook ID
  {
    $fbid = $id[1];
    send_http_code(420);
  }
}


#################################################################################
# User account updates
#################################################################################

function user_update()
{
  $userkey  = get_required_arg('userkey');
  $password = get_optional_arg('password');
  $alias    = get_optional_arg('alias');
  $email    = get_optional_arg('email');
  fail_on_extra_args();

  $userinfo = db_find_user_by_userkey($userkey);
  if( empty($userinfo) ) send_failure(3);
  $userid = $userinfo['userid'];

  $updated = array();

  if( isset($password) )
  {
    if( empty($password) ) { api_error('Cannot set empty password'); }
    $result = db_update_user_password($userid,$password);
    if( ! $result ) send_failure(5);
    $updated[] = 'password';
  }

  if( isset($alias) ) 
  { 
    $result = db_update_user_alias($userid,$alias);
    if( ! $result ) send_failure(5);
    $updated[] = 'alias';
  }

  if( isset($email) ) 
  { 
    $result = db_update_user_email($userid,$email);
    if( ! $result ) send_failure(5);
    $updated[] = 'email';
  }

  send_success( array('updated' => $updated) );
}

#################################################################################
# User info queries
#################################################################################

function user_info()
{
  $id = get_exclusive_arg('userkey','fbid');
  fail_on_extra_args();

  if( $id[0] == 1 )  # user key
  {
    $userkey = $id[1];
    $user_info = db_find_user_by_userkey($userkey);

    if( empty($user_info) ) { send_failure(3); }

    $reply = array(
      'name' => $user_info['username'],
      'lost' => $user_info['last_loss'],
    );

    if( isset($user_info['alias']) ) { $reply['name'] = $user_info['alias']; }

    send_success($reply);
  }
  else # Facebook ID
  {
    $fbid = $id[1];
    send_http_code(420);
  }
}

#################################################################################
# Drop User 
#################################################################################

function user_drop()
{
  $id = get_exclusive_arg('userkey','fbid');
  $notify = get_required_arg('notify');
  $all    = get_optional_arg('all');
  fail_on_extra_args();

  if($id[0] == 1)  # user key
  {
    $user_info = db_find_user_by_userkey($id[1]);
    if( empty($user_info) ) { send_failure(3); }
  }
  else  # Facebook ID
  {
    $user_info = db_find_user_by_facebook_id($id[1]);
    if( empty($user_info) ) { send_failure(4); }
  }

  $userid = $user_info['userid'];

  if( ($id[0] == 1) || ($all == 1) )
  {
    unset($user_info['userkey']);
    unset($user_info['username']);
    unset($user_info['password']);
    unset($user_info['alias']);
    unset($user_info['email']);
    $dropped[] = 'userkey';
  }
  if( ($id[0] == 2) || ($all == 1) )
  {
    unset($user_info['fb_id']);
    $dropped[] = 'fbid';
  }

  if(empty($user_info['userkey']) && empty($user_info['fb_id']))
  {
    if($notify) {notify_quit($userid); }
    $result = db_drop_user($userid);
    $dropped = 'all';
  }
  elseif(empty($user_info['userkey'])) 
  { 
    $result = db_drop_username($userid);
    $dropped = 'login';
  }
  else
  {
    $result = db_drop_facebook($userid);
    $dropped = 'facebook';
  }

  if( ! $result ) { send_failure(6); }

  send_success( array( 'dropped'=>$dropped ) );
}

?>
