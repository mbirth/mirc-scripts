;rbr-Answerz script
;(c)2002 by Markus Birth <mbirth@webwriters.de>
;
; Don't tamper with the variables or you could produce endless loops!


; #############
; ##  MENUs  ##
; #############

menu channel {
  rbr-Answerz
  .Status:rbrAstatus
  .Initialize
  ..Set Answerz-file:set %afile " $+ $sfile( $scriptdir , Select RAF file , Select ) $+ "
  ..Set Quizmaster:set %aqm $$?="Enter nickname of quizmaster:"
  ..Set question indicator:set %aindi $$?="Enter part of message BEFORE the question:"
  ..Set answer indicator:set %aaindi $$?="Enter text BEFORE answer:"
  ..Set solved indicator:set %aainds $$?="Enter text BEFORE aborted answer:"
  ..Set additional delay for answers: set %aaddtime $$?="Enter seconds to add to answer delay:"
  ..-
  ..Reset counters: set %acq 0 | set %aca 0 | set %acsq 0 | set %acsa 0 | set %acas 0
  .-
  .Learning mode
  ..$iif(%alrun == 1,$style(1)) ON:rbrAlearnOn
  ..$iif(%alrun == 0,$style(1)) OFF:rbrAlearnOff
  .Answer mode
  ..$iif(%arun == 1,$style(1)) ON:rbrAon
  ..$iif(%arun == 0,$style(1)) OFF:rbrAoff
  .Auto-say
  ..$iif(%aasay == 1,$style(1)) ON:set %aasay 1
  ..$iif(%aasay == 0,$style(1)) OFF:set %aasay 0
}



; ###############
; ##    ONs    ##
; ###############

ON 1:LOAD:{
  rbrAinit
}

ON 1:UNLOAD:{
  rbrAoutit
}

ON 1:TEXT:*:%achan:{
  set %arecvd $strip( $1- )
  if ( $nick == %aqm ) {
    if ( $poscs( %arecvd , %aaindi ) > 0 || $poscs( %arecvd , %aainds ) > 0 ) {
      .timer off
      set %aanext 1
    }
    if ( %aqnext != 0) {
      if ( %arun != 0 ) {
        echo -tg %achan 2,8 A  Received " $+ %arecvd $+ " on $chan $+ . Searching for answer...
        inc %acq
        ;        set %srch * $+ %arecvd $+ *
        set %srch %arecvd
        if ( $read( %afile , w, %srch ) != $null ) {
          set %aqinmem 1
          set %aaline $readn
          inc %aaline
          set %atemp $read( %afile, n, %aaline )
          echo -tg %achan 2,8 A 9,2 Possible answer: %atemp 
          inc %aca
          set %atemp $lower( %atemp )
          if ( %aasay != 0 ) {
            set %aalen $len( %atemp )
            set %atlen %aalen / 4
            set %atlen $round( %atlen , 0 )
            set %atlen %atlen + %aaddtime
            .timer 1 %atlen msg %achan %atemp
            inc %acas
          }
          unset %atemp
          unset %aaline
        }
        else {
          set %aqinmem 0
          echo -tg %achan 2,8 A 4,2 No answer found.
        }
        unset %srch
      }
      if ( %alrun != 0 && %aqinmem == 0 ) {
        echo -tg %achan 2,8 L  Storing question " $+ %arecvd $+ " from $chan $+ ...
        write %afile %arecvd
        inc %acsq
      }
    }
    if ( %aanext != 0 ) {
      if ( %alrun != 0 && %aqinmem == 0 ) {
        set %arlen $len( %arecvd )
        if ( $poscs( %arecvd , %aainds ) > 0 ) set %ailen $len( %aainds )
        else set %ailen $len( %aaindi )
        set %arlen %arlen - %ailen
        set %aans $right( %arecvd , %arlen )
        unset %arlen
        unset %ailen
        echo -tg %achan 2,8 L  Storing answer " $+ %aans $+ " from $chan $+ ...
        write %afile %aans
        write -i %afile
        unset %aans
        set %aqinmem 0
        inc %acsa
      }
    }
    set %aqnext 0
    set %aanext 0
    if ( $poscs( %arecvd , %aindi ) > 0 ) set %aqnext 1
  }
  unset %arecvd
}


; ###############
; ##  ALIASes  ##
; ###############

alias rbrAstatus {
  echo -tag Currently used answerz-file: %afile ( $+ $file( %afile ).size Bytes)
  echo -tag Created: $asctime( $file( %afile ).ctime , yyyy-mm-dd HH:mm.ss ) $+ , Last-Modified: $asctime( $file( %afile ).mtime , yyyy-mm-dd HH:mm.ss ) $+ , Last-Accessed: $asctime( $file( %afile ).atime , yyyy-mm-dd HH:mm.ss )
  echo -tag .
  echo -tag Channel: %achan
  echo -tag Quizmaster: %aqm
  echo -tag .
  if ( %arun != 0 ) set %asta 9ON
  else set %asta 4OFF
  echo -tag 2,8 A  Answer mode is %asta $+ .
  if ( %aasay != 0 ) set %asta 9ON
  else set %asta 4OFF
  echo -tag 2,8 A  Auto-say is %asta $+ .
  set %asp %aca / %acq
  set %asp %asp * 100
  set %asp $round( %asp , 2 )
  set %aspa %acas / %acq
  set %aspa %aspa * 100
  set %aspa $round( %aspa , 2 )
  echo -tag 2,8 A  rbr-Answerz processed %acq questions, did know %aca answers of them ( $+ %asp $+ % $+ ) and answered %acas times for you. ( $+ %aspa $+ % $+ )
  if ( %alrun != 0 ) set %asta 9ON
  else set %asta 4OFF
  echo -tag 2,8 L  Learning mode is %asta $+ .
  echo -tag 2,8 L  rbr-Answerz stored %acsq questions and %acsa answers. (Should be equal after each question!)
  unset %asta
  unset %asp
  unset %aspa
}

alias rbrAlearnOff {
  if ( %arun == 0 ) set %achan ##
  set %alrun 0
}

alias rbrAlearnOn {
  if ( %arun == 0 ) set %achan $chan
  set %aqnext 0
  set %aqinmem 0
  set %alrun 1
}

alias rbrAon {
  if ( %alrun == 0 ) set %achan $chan
  set %aqnext 0
  set %aqinmem 0
  set %arun 1
}

alias rbrAoff {
  if ( %alrun == 0 ) set %achan ##
  set %arun 0
}

alias rbrAinit {
  set -n %anam 08,01|01,08|08,01|01,08|08,01|01,08 rbr-Answerz 08,01|01,08|08,01|01,08|08,01|
  set -n %achan ##
  set -n %aindi Frage Nr.
  set -n %aaindi Die Antwort war: 
  set -n %aainds Die Antwort ist:
  set -n %aqnext 0
  set -n %aanext 0
  set -n %aqinmem 0
  set -n %aasay 0
  set -n %aaddtime 0
  set -n %afile " $+ $scriptdir $+ rbr-answerz.raf $+ "
  set %alrun 0
  set %arun 0
  set %aqm Quizmaster
  echo -tag %anam initialized.
}

alias rbrAoutit {
  unset %achan
  unset %afile
  unset %aaddtime
  unset %aindi
  unset %aqinmem
  unset %aaindi
  unset %aqnext
  unset %aanext
  unset %aqm
  unset %arun
  unset %aasay
  unset %alrun
  unset %acq
  unset %aca
  unset %acsq
  unset %acsa
  echo -tag %anam unloaded.
  unset %anam
}
