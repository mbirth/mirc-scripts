;rbr-Quiz script
;(c)2002 by Markus Birth <mbirth@webwriters.de>
;
; Don't tamper with the variables or you could produce endless loops!


; #############
; ##  MENUs  ##
; #############

menu channel {
  rbr-Quiz
  .Initialize:rbrQinit
  .Load Quiz...:rbrQload
  .Reload current Quiz:rbrQreload
  .-
  .Start Quiz here:rbrQstart #
  .Stop Quiz:rbrQstop
  .-
  .SKIP current question:rbrQabort
  .-
  .RESET ALL POINTS:rbrQreset
  .-
  .Status:rbrQstatus
  .Toplist:rbrQtoplist
}



; ###############
; ##    ONs    ##
; ###############

ON 1:LOAD:{
  rbrQinit
}

ON 1:UNLOAD:{
  rbrQoutit
}

ON 1:TEXT:*:%qchan:{
  if ( %qrun != 0 ) {
    echo -ag Received $1- on $chan from $nick $+ .
    if ( $strip( $1- ) == $strip( %qa ) ) {
      rbrQanswered $nick
    }
  }
}


; ###############
; ##  ALIASes  ##
; ###############

alias rbrQinit {
  set -n %qver 1.0
  set -n %qnam 08,01|01,08|08,01|01,08|08,01|01,08 rbr-Quiz %qver 08,01|01,08|08,01|01,08|08,01|
  set -n %qchan #
  set -n %qini " $+ $scriptdir $+ rbr-quiz.ini $+ "
  rbrQload rbr-quiz.rqf
  set %qrun 0
  echo -ag %qnam initialized.
}

alias rbrQoutit {
  unset %qver
  unset %qchan
  unset %qrun
  unset %qfile
  unset %qcrea
  unset %qcread
  unset %qlamo
  unset %qquest
  unset %qhinttime
  unset %qnum
  unset %qa
  unset %qhint
  unset %qpts
  unset %qplayed
  unset %qinum
  echo -ag %qnam unloaded.
  unset %qnam
}

alias rbrQstart {
  if ( %qrun == 0 ) {
    set %qchan #$$?1="Channel to quiz:"
    set %qrun 1
    msg %qchan %qnam started.
    msg %qchan Category: 1,11 %qcat  with 11,2 %qquest  questions and 11,2 %qhinttime seconds until each hint
    msg %qchan Created by 11,2 %qcrea  on 11,2 %qcread 
    msg %qchan Last Modified on 11,2 %qlamo 
    set %qnum 1
    set %qplayed $str(0, %qquest)
    echo -ag Setting timer for first question.
    .timer2 1 3 rbrQgetQuest
    echo -ag 9Quiz started on channel %qchan $+ .
  }
  else {
    echo -ag 8Stop quiz on %qchan first!!
  }
}

alias rbrQabort {
  if ( ( %qnum = 0 ) || ( %qnum > %qquest ) ) {
    echo -ag 4No active question.
    halt
  }
  echo -ag Skipping question.
  .timer1 off
  .timer2 off
  msg %qchan Skipping question...
  msg %qchan The answer was:  %qa 
  .timer2 1 3 rbrQgetQuest  
}

alias rbrQstop {
  if ( %qrun != 0 ) {
    .timer1 off
    .timer2 off
    if ( %qnum <= %qquest ) {
      rbrQtoplist
    }
    set %qrun 0
    set %qchan #
    unset %qplayed
    unset %qhint
    unset %qqnum
    unset %qnum
    unset %qa
    unset %qpts
    unset %qinum
    unset %qhints
    msg %qchan %qnam stopped.
    echo -ag 4Quiz stopped.
  }
  else {
    echo -ag 4No quiz running!
  }
}

alias rbrQload {
  var %dateform mmm dd, yyyy
  var %qtemp $1-
  if ( $len(%qtemp) < 3 ) { var %qtemp $$?="Enter quiz-file (*.rqf):" }
  if ( $exists(%qtemp) == $false ) { set -n %qfile " $+ $scriptdir $+ %qtemp $+ " }
  else { set -n %qfile %qtemp }
  if ( $exists(%qfile) == $false ) {
    echo -ag 4FILE NOT FOUND!
    halt
  }
  echo -ag 7Loading %qfile ...
  set -n %qcat $readini(%qfile, Main, Topic)
  echo -ag Category:08,02 %qcat 
  set -n %qcrea $readini(%qfile, Main, Creator)
  set -n %qcread $readini(%qfile, Main, Date)
  echo -ag Created on %qcread by %qcrea
  set -n %qlamo $asctime($file(%qfile).mtime,%dateform)
  echo -ag Last modified on %qlamo
  set %qhinttime $readini(%qfile, Main, HintTime)
  echo -ag Time between hints is %qhinttime seconds.

  set %qquest 1
  set %qmaxpts 0
  var %i $ini(%qfile,Q1)
  while ( ( %i != 0 ) && ( %qquest <= 1000 ) ) {
    inc %qmaxpts $readini(%qfile, Q $+ %qquest, Points)
    inc %qquest
    var %i $ini(%qfile, Q $+ %qquest )
  }
  dec %qquest
  echo -ag File contains %qquest questions.
  echo -ag There are %qmaxpts points to earn.
  echo -ag 9Question file loaded.
}

alias rbrQreload {
  rbrQload %qfile
}

alias rbrQstatus {
  echo -ag %qnam
  echo -ag Quiz active?: %qrun
  echo -ag Quiz-Channel: %qchan
  echo -ag Quiz-File: %qfile
}

alias rbrQgetQuest {
  if ( %qnum > %qquest ) {
    echo -ag 4Sorry, no more questions.
    halt
  }
  set %qinum $rand(1,$eval(%qquest))
  while ( $mid(%qplayed, %qinum, 1) == 1 ) {
    set %qinum $rand(1,$eval(%qquest))
  }
  var %top Q $+ %qinum
  echo -ag Loading question %top ...
  var %t $readini(%qfile, $eval(%top), T)
  echo -ag Topic: %t 
  var %q $readini(%qfile, $eval(%top), Q)
  echo -ag Question: %q 
  set -n %qa $readini(%qfile, $eval(%top), A)
  echo -ag Answer: %qa 
  set %qpts $readini(%qfile, $eval(%top), Points)
  echo -ag Points to win: %qpts 

  set %qhint 1
  set %qhints 1
  var %i $ini(%qfile, $eval(%top), Hint1)
  while ( ( %i != 0 ) && ( %qhints <= 1000 ) ) {
    inc %qhints
    var %i $ini(%qfile, $eval(%top), Hint $+ %qhints )
  }
  dec %qhints
  echo -ag Number of hints: %qhints 

  msg %qchan Question %qnum out of %qquest $+ : 1,11( Category: %t )1,8 %q 
  var %hinttxt hints
  if ( %qhints == 1 ) { var %hinttxt hint }
  msg %qchan (You will get %qhints %hinttxt $+ .)



  inc %qnum
  if ( %qnum > %qquest ) {
    msg %qchan This is the last chance to earn some points!
  }

  echo -ag Enabling hinttimer...
  .timer1 0 %qhinttime rbrQHint
}

alias rbrQanswered {
  var %nick $1-
  echo -ag Halting hinttimer, if not already ...
  .timer1 off
  msg %qchan 1,8 QUESTION ANSWERED 
  if ( ( %qinum < 1 ) || ( %qinum > %qquest ) ) {
    echo -ag 4No question active.
    halt
  }
  echo -ag Marking this question as answered...
  var %qlp %qinum - 1
  var %qrp $len(%qplayed) - %qlp
  var %qrp %qrp - 1
  var %ql $left(%qplayed, $eval(%qlp))
  var %qr $right( %qplayed, $eval(%qrp))
  set %qplayed %ql $+ 1 $+ %qr
  echo -ag Played: %qplayed

  echo -ag Adding points to %nick $+ 's account.
  var %befpts $readini(%qini, Points, $1- )
  if ( %befpts == $null ) { var %befpts 0 }
  echo -ag Points before: %befpts
  var %befpts %befpts + %qpts
  echo -ag Points after: %befpts
  writeini %qini Points %nick %befpts
  msg %qchan Good, %nick $+ ! You got %qpts points and now have %befpts points!
  msg %qchan The correct answer was:  %qa 

  var %test %qnum - 1
  var %test %test % 5
  if ( %qnum > %qquest ) {
    echo -ag This was the last question. Showing toplist...
    rbrQtoplist
    echo -ag Stopping Quiz...
    rbrQstop
  }
  elseif ( %test == 0 ) {
    echo -ag This was a 5th question. Showing toplist...
    msg %qchan Okay, now let's take a look at the stats...
    rbrQtoplist
  }
  if ( %qnum <= %qquest ) {
    echo -ag Setting timer for next question.
    .timer2 1 5 rbrQgetQuest
  }
}

alias rbrQHint {
  if ( %qhint > %qhints ) {
    echo -ag 4All hints shown. Disabling timer.
    .timer1 off
    halt
  }
  var %hint $readini(%qfile,Q $+ %qinum,Hint $+ %qhint)
  msg %qchan Hint %qhint of %qhints $+ : %hint
  inc %qhint
}

alias rbrQtoplist {
  var %u1n -
  var %u1p 0
  var %u2n -
  var %u2p 0
  var %u3n -
  var %u3p 0
  var %u4n -
  var %u4p 0
  var %u5n -
  var %u5p 0
  var %u6n -
  var %u6p 0
  var %u7n -
  var %u7p 0
  var %u8n -
  var %u8p 0
  var %u9n -
  var %u9p 0
  var %u0n -
  var %u0p 0
  echo -ag Showing Toplist...
  msg %qchan %qnam
  msg %qchan 8,1 --==+ TOPLIST +==-- 
  var %entries $ini(%qini,Points,0)
  var %curent 1
  while ( %curent <= %entries ) {
    var %curuser $ini(%qini, Points, $eval(%curent))
    var %cini $readini(%qini, Points, $eval(%curuser))
    if ( %cini > %u0p ) {
      var %u0p %cini
      var %u0n %curuser
    }
    if ( %cini > %u9p ) {
      var %u0p %u9p
      var %u0n %u9n
      var %u9p %cini
      var %u9n %curuser
    }
    if ( %cini > %u8p ) {
      var %u9p %u8p
      var %u9n %u8n
      var %u8p %cini
      var %u8n %curuser
    }
    if ( %cini > %u7p ) {
      var %u8p %u7p
      var %u8n %u7n
      var %u7p %cini
      var %u7n %curuser
    }
    if ( %cini > %u6p ) {
      var %u7p %u6p
      var %u7n %u6n
      var %u6p %cini
      var %u6n %curuser
    }
    if ( %cini > %u5p ) {
      var %u6p %u5p
      var %u6n %u5n
      var %u5p %cini
      var %u5n %curuser
    }
    if ( %cini > %u4p ) {
      var %u5p %u4p
      var %u5n %u4n
      var %u4p %cini
      var %u4n %curuser
    }
    if ( %cini > %u3p ) {
      var %u4p %u3p
      var %u4n %u3n
      var %u3p %cini
      var %u3n %curuser
    }
    if ( %cini > %u2p ) {
      var %u3p %u2p
      var %u3n %u2n
      var %u2p %cini
      var %u2n %curuser
    }
    if ( %cini > %u1p ) {
      var %u2p %u1p
      var %u2n %u1n
      var %u1p %cini
      var %u1n %curuser
    }
    inc %curent
  }
  msg %qchan 1. %u1n ( %u1p points )    ---     6. %u6n ( %u6p points )
  msg %qchan 2. %u2n ( %u2p points )    ---     7. %u7n ( %u7p points )
  msg %qchan 3. %u3n ( %u3p points )    ---     8. %u8n ( %u8p points )
  msg %qchan 4. %u4n ( %u4p points )    ---     9. %u9n ( %u9p points )
  msg %qchan 5. %u5n ( %u5p points )    ---    10. %u0n ( %u0p points )
  if ( %qnum > %qquest ) {
    echo -ag The winner is %u1n with %u1p points!
    msg %qchan Congratulations, %u1n $+ , you are the absolute WINNER!
  }
  return
}

alias rbrQreset {
  echo -ag 4Resetting points...
  remini %qini Points
  rbrQmsg 4,2All points deleted.
}

alias rbrQmsg {
  if ( %qrun == 1 ) {
    msg %qchan $1-
  }
  return
}
