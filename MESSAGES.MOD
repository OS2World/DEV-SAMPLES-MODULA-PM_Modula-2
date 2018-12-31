(*----------------------------------------------------------------------------*)
(* Example OS/2 Presentation Manager Program adapted from the book            *)
(* "OS/2 Presentation Manager - Programming Primer" by Asael Dror &           *)
(* Robert Lafore                                                              *)
(*                                                                            *)
(* Example programs converted to JPI Modula-2 Version 2 for OS/2 1.2 by       *)
(* Chris Barker, August 1990                                                  *)
(*                                                                            *)
(* Notes:  I am distributing these programs so that others can learn and also *)
(*         so I can elicit feedback from the user community on programming for*)
(*         OS/2 PM using Modula-2.  If your have any questions, suggestions,  *)
(*         or comments I'd love to hear from you.  I may be reached at the    *)
(*         following addresses:                                               *)
(*                                                                            *)
(*         Compuserve ID: 72261,2312                                          *)
(*         Pete Norloff's OS/2 Shareware BBS - (703) 385-4325                 *)
(*         Max's Doghouse BBS - (703) 548-7849                                *)
(*           The above two BBS carry the Fidonet OS/2 echo which I read       *)
(*           regularly.                                                       *)
(*         Programmer's Corner - (301) 596-1180                               *)
(*         CPCUG Mix (Window Sig) BBS - (301) 738-9060                        *)
(*                                                                            *)
(*         I hope I hear from you!                                            *)
(*                                                                            *)
(*               - Chris                                                      *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

(*----------------------------------------------------------------------------*)
(*  Program Notes:                                                            *)
(*    Provides a excellent way to see what messages are really being sent     *)
(*    during the execution of this program.  When it first starts, you        *)
(*    hear beeps for about 15 seconds before the client window is drawn.      *)
(*    Every time you move the mouse a message will be posted.                 *)
(*    Source code on page 106.                                                *)
(*----------------------------------------------------------------------------*)

MODULE MESSAGES;

(*# call(same_ds => off) *)

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM,IO,Str;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM PMMSG IMPORT msglist,NumMsg;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Display Messages';

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndClient,
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;
  route         : ARRAY [0..10] OF CHAR;

PROCEDURE Error;
BEGIN
END Error;

(*--------------------  Start of window procedure  ---------------------*)
(*# save,call(near_call=>off,reg_param=>(),reg_saved=>(di,si,ds,es,st1,st2)) *)

PROCEDURE ClientWinProc(
                       hwnd : HWND;
                       msg:CARDINAL;
                       mp1,mp2:Win.MPARAM)
                       : Win.MRESULT;
CONST
  questions = '??? ';
  delim = ' ';
VAR
  hps : HPS;
  rcl : RECTL;
  szText,
  str1,
  str2,
  str3,
  msgnumstr : ARRAY [0..80] OF CHAR;
  Done : BOOLEAN;
BEGIN
  Str.CardToStr(VAL(LONGCARD,msg),msgnumstr,10,Done);

  IF (msg > NumMsg + 1) THEN
    Str.Concat(str1,questions,delim);
    Str.Concat(str2,msgnumstr,delim);
    Str.Concat(str3,str1,str2);
    Str.Concat(szText,str3,route);
  ELSE
    Str.Concat(str1,msglist[msg],delim);
    Str.Concat(str2,msgnumstr,delim);
    Str.Concat(str3,str1,str2);
    Str.Concat(szText,str3,route);
  END;

  hps := Win.GetPS(hwnd);
  Win.QueryWindowRect(hwnd,rcl);
  Win.DrawText(hps,-1,szText,rcl,0,0,
               Win.DT_CENTER+Win.DT_VCENTER+Win.DT_ERASERECT+Win.DT_TEXTATTRS);
  Win.ReleasePS(hps);
  Win.Alarm(Win.HWND_DESKTOP,Win.WA_NOTE);
  Dos.Sleep(300);
  RETURN Win.DefWindowProc(hwnd, msg, mp1, mp2)
END ClientWinProc;

(*# restore *)
(*---------------------  End of window procedure  ----------------------*)

BEGIN
  route := 'sent';
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  IF NOT Win.RegisterClass(             (* Register window class        *)
     hab,                               (* Anchor block handle          *)
     szClientClass,                     (* Window class name            *)
     ClientWinProc,                  (* Address of window procedure  *)
     0,
     0                                  (* No extra window words        *)
     ) THEN Error END;

  hwnd := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              flcreateFlags,
              szClientClass,
              'Messages',
              0,
              NULL,
              0,
              hwndClient);


  WHILE( Win.GetMsg( hab, qmsg, HWND(NULL), 0, 0 ) ) DO
    route := 'posted';
    r := Win.DispatchMsg( hab, qmsg );
    route := 'sent';
  END;

  IF NOT Win.DestroyWindow(hwndClient) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.DestroyWindow(hwnd) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.DestroyMsgQueue(hmq) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.Terminate(hab) THEN            (* terminate the application    *)
    Error;
  END;

  HALT;

END MESSAGES.
