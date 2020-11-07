<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/secret.php');
require_once(__DIR__.'/db_update_user.php');

function fb_info($fbid)
{
  $token = implode('|', array('GG',FB_APP_ID,FB_APP_SECRET) );
  $url = FB_GRAPH_API . "/${fbid}?fields=name,picture&access_token=$token";

  $curl = curl_init($url);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  $response = json_decode(curl_exec($curl),true);

  $rval = array();

  if(isset($response['name']))
  {
    $rval[NAME] = $response['name'];
  }
  if( isset($response['picture']) ) {
    if( isset($response['picture']['data'] )) {
      if( isset($response['picture']['data']['url'] )) {
        $rval[PICTURE] = $response['picture']['data']['url'];
      }
    }
  }

  return $rval;
}
