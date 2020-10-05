<?php

// Query Keys
const DEVTOKEN    = 'dev_token';
const EMAIL       = 'email';
const FBID        = 'fbid';
const FBNAME      = 'fb_name';
const LASTLOSS    = 'last_loss';
const NAME        = 'name';
const MATCHID     = 'match_id';
const MATCHSTART  = 'match_start';
const NOTIFY      = 'notify';
const OPPONENT    = 'opponent';
const RESET_KEY   = 'reset';
const QCODE       = 'qcode';
const SCODE       = 'scode';
const UPDATED     = 'updated';
const USERID      = 'userid';
const USERKEY     = 'userkey';
const VALIDATED   = 'validated';
const VALID       = 'valid';

// Return Codes
const SUCCESS                  =  0;
const FAILED                   =  1;
const USER_EXISTS              =  2;
const INVALID_USERKEY          =  3;
const INVALID_FBID             =  4;  
const FAILED_TO_CREATE_FBID    =  5;
const FAILED_TO_CREATE_USER    =  6;
const FAILED_TO_UPDATE_USER    =  7;
const NO_EMAIL                 =  8; 
const INVALID_EMAIL            =  9;
const EMAIL_FAILURE            = 10;
const INVALID_OPPONENT         = 11;
const INVALID_QS_CODE          = 12;
const NOTIFICATION_FAILURE     = 13;
const CURL_FAILURE             = 14;
const APNS_FAILURE             = 15;

const NOT_YET_IMPLEMENTED      = 99;
?>
