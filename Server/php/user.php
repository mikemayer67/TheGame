<?php

require_once(__DIR__.'/pri/util.php');
require_once(__DIR__.'/pri/user.php');

try
{
  $action = get_required_arg('action');

  if     ( $action == 'create'   ) { user\create();   }
  elseif ( $action == 'connect'  ) { user\connect();  }
  elseif ( $action == 'add'      ) { user\add();      }
  elseif ( $action == 'update'   ) { user\update();   }
  elseif ( $action == 'lookup'   ) { user\lookup();   }
  elseif ( $action == 'validate' ) { user\validate(); }
  elseif ( $action == 'drop'     ) { user\drop();     }
  elseif ( $action == 'pwreset'  ) { user\pwreset();  }
  elseif ( $action == 'matches'  ) { user\matches();  }
  elseif ( $action == 'lost'     ) { user\lost();     }
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

?>
