<?php

require_once(__DIR__.'/pri/util.php');

try
{
  $action = get_required_arg('q');

//  elseif ( $action == 'user_add'       ) { require(__DIR__.'/pri/user_add.php');       }
  if     ( $action == 'eex' ) { require(__DIR__.'/pri/email_exists.php');        } 
  elseif ( $action == 'erc' ) { require(__DIR__.'/pri/email_recovery_code.php'); } 
  elseif ( $action == 'err' ) { require(__DIR__.'/pri/email_error.php');         } 
  elseif ( $action == 'gdt' ) { require(__DIR__.'/pri/game_dev_token.php');      }
  elseif ( $action == 'gem' ) { require(__DIR__.'/pri/game_end_match.php');      }
  elseif ( $action == 'ilg' ) { require(__DIR__.'/pri/user_lost.php');           } 
  elseif ( $action == 'mat' ) { require(__DIR__.'/pri/user_matches.php');        } 
  elseif ( $action == 'pok' ) { require(__DIR__.'/pri/game_poke.php');           }
  elseif ( $action == 'ucr' ) { require(__DIR__.'/pri/user_create.php');         }
  elseif ( $action == 'udr' ) { require(__DIR__.'/pri/user_drop.php');           } 
  elseif ( $action == 'ufb' ) { require(__DIR__.'/pri/user_fb_connect.php');     } 
  elseif ( $action == 'ufd' ) { require(__DIR__.'/pri/user_fb_drop.php');        } 
  elseif ( $action == 'uin' ) { require(__DIR__.'/pri/user_lookup.php');         } 
  elseif ( $action == 'uup' ) { require(__DIR__.'/pri/user_update.php');         } 
  elseif ( $action == 'uvl' ) { require(__DIR__.'/pri/user_validate.php');       } 
  else
  {
    api_error('Unknown query: ' . $action);
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

?>
