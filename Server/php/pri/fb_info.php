<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/secret.php');
require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_update_user.php');

function fb_info($fbid)
{
  $now = time();

  $db = new TGDB;
  $sql = 'select * from tg_fb_cache where fbid=?';
  $result = $db->get($sql,'s',$fbid);
  $n = $result->num_rows;

  if($n > 0)
  {
    $row = $result->fetch_assoc();
    if( $now < $row['expires'] && !empty($row['name'] ) )
    {
      $rval = array(NAME => $row['name']);
      if(!empty($row['picture'])) { $rval[PICTURE] = $row['picture']; }
      return $rval;
    }
  }

  $token = implode('|', array('GG',FB_APP_ID,FB_APP_SECRET) );
  $url = FB_GRAPH_API . "/${fbid}?fields=name,picture&access_token=$token";

  $curl = curl_init($url);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  $response = json_decode(curl_exec($curl),true);

  if(isset($response['name']))
  {
    $name = $response['name'];
  }
  if( isset($response['picture']) ) {
    if( isset($response['picture']['data'] )) {
      if( isset($response['picture']['data']['url'] )) {
        $picture = $response['picture']['data']['url'];
      }
    }
  }

  if( isset($name) )
  {
    if( isset($picture) )
    {
      $sql = 'replace into tg_fb_cache (fbid,name,picture,expires) values (?,?,?,?)';
      $db->get($sql,'sssi', $fbid, $name, $picture, $now + 3600);
      return array(NAME=>$name, PICTURE=>$picture);
    }
    else
    {
      $sql = 'replace into tg_fb_cache (fbid,name,expires) values (?,?,?)';
      $db->get($sql,'ssi', $fbid, $name, $now + 3600);
      return array(NAME=>$name);
    }
  }
  else
  {
    $sql = 'replace into tg_fb_cache (fbid,expires) values (?,?)';
    $db->get($sql,'si', $fbid, $now + 900);
  }
  return array();

}
