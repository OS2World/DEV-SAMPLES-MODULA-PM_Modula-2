(*----------------------------------------------------------------------------*)
(* Example OS/2 Presentation Manager Program adapted from the book            *)
(* "OS/2 Presentation Manager - Programming Primer" by Asael Dror &           *)
(* Robert Lafore                                                              *)
(*                                                                            *)
(* Example programs converted to JPI Modula-2 Version 2 for OS/2 1.2 by       *)
(* Chris Barker, October 1990                                                 *)
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
(*                                                                            *)
(*  Creates a Client Window with two menu selections which are defined        *)
(*  in the resource file BEEP.RC.                                             *)
(*  Page 198.                                                                 *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(*  Compiling Notes:                                                          *)
(*                                                                            *)
(*  The following files should be available:                                  *)
(*  BEEP.H, BEEP.RC                                                           *)
(*                                                                            *)
(*  Add the line: "run rc %N" to the end of your project file.  This will     *)
(*  cause TS to invoke the Microsoft resource compiler after it has created   *)
(*  the EXE file.  You also should have rc.exe in your path along with the    *)
(*  OS/2 header files located in a directory that is referenced by the OS/2   *)
(*  environment variable: INCLUDE.  For example SET INCLUDE = C:\TS\INCLUDE.  *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE BEEP;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  ID_FRAMERC    = 1;
  ID_BEEP =     101;
  ID_EXIT =     103;

VAR
  rslt          : INTEGER;
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwnd,
  hwndClient    : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;

(*--------------------  Error reporting procedure  ---------------------*)
PROCEDURE Error;
VAR
BEGIN
END Error;
(*-----------------  End of Error reporting procedure  ------------------*)

(*--------------------  Start of window procedure  ---------------------*)
(*# save,call(near_call=>off,reg_param=>(),reg_saved=>(di,si,ds,es,st1,st2)) *)

PROCEDURE ClientWinProc(hwnd : HWND;
                        msg:CARDINAL;
                        mp1,mp2:Win.MPARAM)
                        : Win.MRESULT;

BEGIN
  CASE msg OF
    | Win.WM_COMMAND :
        CASE SHORT1FROMMP(mp1) OF
          | ID_BEEP :
              Win.Alarm(Win.HWND_DESKTOP,Win.WA_NOTE);

          | ID_EXIT :
              Win.PostMsg(hwnd,Win.WM_QUIT,NULL,NULL);
        END;

    | Win.WM_ERASEBACKGROUND :
        RETURN Win.MPARAM(TRUE);

  ELSE
    RETURN Win.DefWindowProc(hwnd, msg, mp1, mp2)
  END;
  RETURN Win.MPARAM(FALSE);
END ClientWinProc;

(*# restore *)
(*---------------------  End of window procedure  ----------------------*)

BEGIN
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST +
                   Win.FCF_MENU;

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
              ' - Menu',
              0,
              NULL,
              ID_FRAMERC,
              hwndClient);


  WHILE (Win.GetMsg(hab,qmsg,HWND(NULL),0,0)) DO
    r := Win.DispatchMsg(hab,qmsg);
  END;

  IF NOT Win.DestroyWindow(hwnd) THEN
    Error;
  END;

  IF NOT Win.DestroyMsgQueue(hmq) THEN
    Error;
  END;

  IF NOT Win.Terminate(hab) THEN
    Error;
  END;

  HALT;

END BEEP.
