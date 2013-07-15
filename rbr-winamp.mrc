;rbr-WinAMP script
;(c)2004 by Markus Birth <mbirth@webwriters.de>
;
;Works perfectly with gen_mirc.dll of WinAMP.
;
;Set command string in WinAMP-plugin as follows:
;        /musicbox %s


; #############
; ##  MENUs  ##
; #############

menu status {
  rbr-WinAMP
  .Status: musicboxstatus
  .-
  .Enable Auto-Announce: musicboxon
  .Disable Auto-Announce: musicboxoff
}

menu channel {
  rbr-WinAMP
  .Announce Song: musicboxannounce
  .-
  .Status: musicboxstatus
  .-
  .Enable Auto-Announce: musicboxon
  .Disable Auto-Announce: musicboxoff
}


; ###############
; ##  ALIASes  ##
; ###############

alias musicbox {
  set %rbrwinampsong $1-
  if ( %rbrwinamp == ON ) {
    musicboxannounce
  }
}

alias musicboxannounce {
  echo WinAMP now playing:  $+ %rbrwinampsong $+ 
  ame is listening to  $+ %rbrwinampsong $+ 
}

alias musicboxstatus {
  if ( %rbrwinamp == ON ) {
    echo rbr-WinAMP Auto-Announce is currently 9ACTIVATED.
  }
  else {
    echo rbr-WinAMP Auto-Announce is currently 4DEACTIVATED.
  } 
}

alias musicboxon {
  set %rbrwinamp ON
  echo rbr-WinAMP Auto-Announce is now 9ACTIVATED.
}

alias musicboxoff {
  unset %rbrwinamp
  echo rbr-WinAMP Auto-Announce is now 4DEACTIVATED.
}
