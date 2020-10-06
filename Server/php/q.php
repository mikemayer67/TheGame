<?php

$pri = __DIR__.'/pri/';

require_once($pri.'util.php');

try
{
  $action = get_required_arg('q');

//  elseif ( $action == 'user_add'       ) { require(__DIR__.'/pri/user_add.php');       }
  if     ( $action == 'eex' ) { require($pri.'email_exists.php');    } 
  elseif ( $action == 'erc' ) { require($pri.'email_recovery.php');  } 
  elseif ( $action == 'err' ) { require($pri.'email_error.php');     } 
  elseif ( $action == 'gdt' ) { require($pri.'game_dev_token.php');  }
  elseif ( $action == 'gem' ) { require($pri.'game_end_match.php');  }
  elseif ( $action == 'ilg' ) { require($pri.'user_lost.php');       } 
  elseif ( $action == 'mat' ) { require($pri.'user_matches.php');    } 
  elseif ( $action == 'pok' ) { require($pri.'game_poke.php');       }
  elseif ( $action == 'ucr' ) { require($pri.'user_create.php');     }
  elseif ( $action == 'udr' ) { require($pri.'user_drop.php');       } 
  elseif ( $action == 'ufb' ) { require($pri.'user_fb_create.php');  } 
  elseif ( $action == 'ufd' ) { require($pri.'user_fb_drop.php');    } 
  elseif ( $action == 'uin' ) { require($pri.'user_lookup.php');     } 
  elseif ( $action == 'uup' ) { require($pri.'user_update.php');     } 
  elseif ( $action == 'uvl' ) { require($pri.'user_validate.php');   } 
  elseif ( $action == 'uxc' ) { require($pri.'user_xfer_code.php');  }
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
