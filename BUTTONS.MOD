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
(*    After creating the client window, two push buttons are displayed whose  *)
(*    function should be obvious.                                             *)
(*    Source code on page 125.                                                *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE BUTTONS;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  ID_BUTTON1 = 1;
  ID_BUTTON2 = 2;
  CWPM_CREATE = Win.WM_USER;
  ID_WINDOW = 1;

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndClient,
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;

(*--------------------  Error reporting procedure  ---------------------*)
PROCEDURE Error;
VAR
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
  textsettings = Win.WS_VISIBLE+Win.WS_CLIPSIBLINGS+
                 Win.SS_TEXT+CARDINAL(Win.DT_LEFT)+CARDINAL(Win.DT_TOP)+
                 CARDINAL(Win.DT_WORDBREAK);

VAR
  hwndControl1,
  hwndControl2           : HWND;
  rcl                    : RECTL;
  cx, cy,
  x , y                  : INTEGER;
  cm                     : Win.COMMANDMSG;

BEGIN
  CASE msg OF
    | Win.WM_CREATE :
        IF NOT Win.PostMsg(hwnd,CWPM_CREATE,0,0) THEN
          Error;
        END;
        RETURN Win.MPARAM(FALSE);

    | CWPM_CREATE :
        x := 60; y := 30;
        Win.QueryWindowRect(hwnd,rcl);
        cx := INTEGER(INTEGER(rcl.xRight - rcl.xLeft) DIV 2 - x - x DIV 2);
        cy := INTEGER(INTEGER(rcl.yTop - rcl.yBottom) DIV 2 - y DIV 2);

        hwndControl1 := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_BUTTON)^,
                          'Beep',
                          Win.WS_VISIBLE + Win.BS_PUSHBUTTON,
                          cx,cy,x,y,
                          hwnd,Win.HWND_TOP,ID_BUTTON1,NIL,NIL);

        cx := cx + x;
        cx := cx + x;

        hwndControl2 := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_BUTTON)^,
                          'Quit',
                          Win.WS_VISIBLE + Win.BS_PUSHBUTTON,
                          cx,cy,x,y,
                          hwnd,
                          Win.HWND_TOP,ID_BUTTON2,NIL,NIL);


    | Win.WM_COMMAND :
        IF (SHORT1FROMMP(mp2) = Win.CMDSRC_PUSHBUTTON) THEN
          IF (SHORT1FROMMP(mp1) = ID_BUTTON1) THEN
            Win.Alarm(Win.HWND_DESKTOP,Win.WA_NOTE);
          ELSE
            IF (SHORT1FROMMP(mp1) = ID_BUTTON2) THEN
              Win.PostMsg(hwnd,Win.WM_QUIT,0,0);
            END;
          END;
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
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  IF NOT Win.RegisterClass(             (* Register window class        *)
     hab,                               (* Anchor block handle          *)
     szClientClass,                     (* Window class name            *)
     ClientWinProc,                  (* Address of window procedure  *)
     Win.CS_SIZEREDRAW,
     0                                  (* No extra window words        *)
     ) THEN Error END;

  hwnd := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              flcreateFlags,
              szClientClass,
              ' - Controls',
              0,
              NULL,
              0,
              hwndClient);


  WHILE( Win.GetMsg( hab, qmsg, HWND(NULL), 0, 0 ) ) DO
    r := Win.DispatchMsg( hab, qmsg );
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

END BUTTONS.
