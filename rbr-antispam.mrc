on @1:TEXT:*:#:{
  if (( $nick isprotect ) || ( $nick isop $chan ) || ( $chan != #lmg )) halt

  if ( $1- != %spam ) {
    set %spam $1-
    set %spamnick $nick
    set %spamcount 0
    halt
  }

  if (( $1- == %spam ) && ( %spamnick == $nick )) {
    inc %spamcount
  }

  if (%spamcount == 2 ) {
    msg $chan 8,1Spam Protection Hey $nick $+ ! Wir haben es gelesen!
    halt
  }
  if ( %spamcount == 3 ) {
    msg $chan 8,1Spam Protection $nick $+ ! Das ist die zweite Warnung. Beim nächsten Mal fliegst Du!
    inc %spamcount
    halt
  }
  if ( %spamcount >= 4 ) {
    msg $chan 8,1Spam Protection Ich hab Dich gewarnt, $nick $+ !
    kick $chan $nick 8,1Spam Protection Don't try this at home.
    unset %spamcount
    unset %spamnick
    unset %spam
  }
}
