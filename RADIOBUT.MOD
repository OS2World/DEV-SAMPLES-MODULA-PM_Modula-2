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
(*    Three choices will displayed on the client window in the Radio Button   *)
(*    style.  Selecting one of the choices will subsequently change the desk- *)
(*    top background to the color indicated.  When the program ends the desk- *)
(*    top should be returned to its original color.                           *)
(*    Source code on page 131.                                                *)
(*----------------------------------------------------------------------------*)

MODULE RADIOBUT;

(*# call(same_ds => off) *)

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM,IO;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  ID_BUTTON1 = 1;
  ID_BUTTON2 = 2;
  ID_BUTTON3 = 3;
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
  clrOldIndRGB  : COLOR;
  flcreateFlags : LSET;

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
VAR
  hwndControl1,
  hwndControl2,
  hwndControl3           : HWND;
  rcl                    : RECTL;
  cx, cy                 : INTEGER;
  aclrIndRGB             : ARRAY [0..1] OF COLOR;
  cm                     : Win.COMMANDMSG;

BEGIN
  aclrIndRGB[0] := Win.SYSCLR_BACKGROUND;

  CASE msg OF
    | Win.WM_CREATE :
        Win.PostMsg(hwnd,CWPM_CREATE,0,0);
        RETURN Win.MPARAM(FALSE);

    | CWPM_CREATE :
        IF NOT Win.QueryWindowRect(hwnd,rcl) THEN Error END;
        cx := INTEGER(INTEGER(rcl.xRight - rcl.xLeft) DIV 2);
        cy := INTEGER(INTEGER(rcl.yTop - rcl.yBottom) DIV 2);

        hwndControl1 := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_BUTTON)^,
                          'Red',
                          Win.WS_VISIBLE + Win.BS_AUTORADIOBUTTON,
                          cx,cy + 20,60,15,
                          hwnd,Win.HWND_TOP,ID_BUTTON1,NIL,NIL);

        hwndControl2 := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_BUTTON)^,
                          'Green',
                          Win.WS_VISIBLE + Win.BS_AUTORADIOBUTTON,
                          cx,cy,60,15,
                          hwnd,
                          Win.HWND_TOP,ID_BUTTON2,NIL,NIL);

        hwndControl3 := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_BUTTON)^,
                          'Blue',
                          Win.WS_VISIBLE + Win.BS_AUTORADIOBUTTON,
                          cx,cy -20,60,15,
                          hwnd,
                          Win.HWND_TOP,ID_BUTTON3,NIL,NIL);

        clrOldIndRGB := Win.QuerySysColor(Win.HWND_DESKTOP,Win.SYSCLR_BACKGROUND,
                                          0);

        RETURN Win.MPARAM(TRUE);


    | Win.WM_CONTROL :
        cm := Win.COMMANDMSG(mp1);
        CASE cm.source OF
          | ID_BUTTON1 : aclrIndRGB[1] := Gpi.RGB_RED;
          | ID_BUTTON2 : aclrIndRGB[1] := Gpi.RGB_GREEN;
          | ID_BUTTON3 : aclrIndRGB[1] := Gpi.RGB_BLUE;
        END;
        IF NOT Win.SetSysColors(Win.HWND_DESKTOP,0,Gpi.LCOLF_INDRGB,0,2,
                                aclrIndRGB) THEN Error END;
        RETURN Win.MPARAM(TRUE);

    | Win.WM_DESTROY :
        aclrIndRGB[1] := clrOldIndRGB;
        IF NOT Win.SetSysColors(Win.HWND_DESKTOP,0,Gpi.LCOLF_INDRGB,0,2,
                         aclrIndRGB) THEN Error END;
        RETURN Win.MPARAM(TRUE);

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

END RADIOBUT.
