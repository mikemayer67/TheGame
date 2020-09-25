<?php

class TGDB {
  public static $db = null;

  const DB_USER = 'vmwishes_thegame';
  const DB_PASS = 'Dj4UFGJISrdG';
  const DB_NAME = 'vmwishes_thegame';
  const DB_HOST = 'localhost';

  function __construct()
  {
    if(is_null(TGDB::$db))
    {
      $mysqli = new mysqli(self::DB_HOST, self::DB_USER, self::DB_PASS, self::DB_NAME);

      $err = $mysqli->connect_error;
      if( $err )
      {
        $errno = $mysqli->connect_errno;
        throw new Exception( "Failed to connect to database[$errno]: $err", 500 );
      }

      if( ! $mysqli->set_charset('utf8') ) 
      { 
        throw new Exception('Failed to set charset to utf8',500); 
      }

      TGDB::$db = $mysqli;
    }
  }

  public function get($sql, $fmt=null, ...$args)
  {
    $stmt = TGDB::$db->stmt_init();
    if( ! $stmt->prepare($sql) )
    {
      $sql = preg_replace('/\s+/',' ',$sql);
      $sql = preg_replace('/^\s/','',$sql);
      $sql = preg_replace('/\s$/','',$sql);

      $trace = debug_backtrace();
      $file = $trace[0]["file"];
      $line = $trace[0]["line"];

      throw new Exception("Invalid SQL: $sql  [invoked at: $file:$line]",500); 
    }
    if( ! is_null($fmt) )
    {
      if( ! $stmt->bind_param($fmt,...$args) )
      {
        $sql = preg_replace('/\s+/',' ',$sql);
        $sql = preg_replace('/^\s/','',$sql);
        $sql = preg_replace('/\s$/','',$sql);

        $trace = debug_backtrace();
        $file = $trace[0]["file"];
        $line = $trace[0]["line"];

        $args = implode(',',$args);

        throw new Exception("Incorrect number of parms passed to SQL at: $file:$line\n" .
          "SQL: $sql\n  FMT: $fmt\n ARGS: $args\n[invoked at: $file:$line]",
          500); 
      }
    }

    $result = $stmt->execute();
    if( $result && preg_match('/^select\b/i', $sql) )
    {
      $result = $stmt->get_result();
    }

    return $result;
  }

  public function last_insert_id()
  {
    return TGDB::$db->insert_id;
  }

  public function escape($value)
  {
    return TGDB::$db->real_escape_string($value);
  }
};

?>
