<?php

require_once(__DIR__.'/secret.php');
require_once(__DIR__.'/db_update_user.php');

const GRAPH_API = 'https://graph.facebook.com';

function fb_confirm($fbid)
{
  $url = GRAPH_API . "/${fbid}?access_token=" . FB_APP_ID . "|" . FB_APP_SECRET;

  $curl = curl_init($url);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  $response = json_decode(curl_exec($curl),true);

  if(isset($response['id']))
  {
    return true;
  }

//  if( isset($response['error']) && isset($response['error']['code']) )
//  {
//    $code = $response['error']['code'];
//    if( $code == 803 )
//    {
//      error_log("remove from database");
//    }
//  }

  return false;
    
}
