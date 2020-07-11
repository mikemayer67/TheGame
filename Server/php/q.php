<?php

require_once(__DIR__.'/pri/util.php');

try
{
  $action = get_required_arg('q');

//  elseif ( $action == 'user_add'       ) { require(__DIR__.'/pri/user_add.php');       }
  if     ( $action == 'connect'        ) { require(__DIR__.'/pri/user_connect.php');   }
  elseif ( $action == 'create_user'    ) { require(__DIR__.'/pri/user_create.php');    }
  elseif ( $action == 'drop_user'      ) { require(__DIR__.'/pri/user_drop.php');      }
  elseif ( $action == 'matches'        ) { require(__DIR__.'/pri/user_matches.php');   }
  elseif ( $action == 'pwreset'        ) { require(__DIR__.'/pri/user_pwreset.php');   }
  elseif ( $action == 'update_user'    ) { require(__DIR__.'/pri/user_update.php');    }
  elseif ( $action == 'user_info'      ) { require(__DIR__.'/pri/user_lookup.php');    }
  elseif ( $action == 'user_lost'      ) { require(__DIR__.'/pri/user_lost.php');      }
  elseif ( $action == 'validate'       ) { require(__DIR__.'/pri/user_validate.php');  }
  elseif ( $action == 'email_exists'   ) { require(__DIR__.'/pri/email_exists.php');   }
  elseif ( $action == 'email_pwreset'  ) { require(__DIR__.'/pri/email_pwreset.php');  }
  elseif ( $action == 'email_username' ) { require(__DIR__.'/pri/email_username.php'); }
  elseif ( $action == 'error'          ) { require(__DIR__.'/pri/email_error.php');    }
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
