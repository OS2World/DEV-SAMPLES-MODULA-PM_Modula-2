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
(*                                                                            *)
(*  Creates a Client Window with two menu selections which are defined        *)
(*  in the resource file ROTATE.RC.                                           *)
(*  Page 226.                                                                 *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(*  Compiling Notes:                                                          *)
(*                                                                            *)
(*  The following files should be available:                                  *)
(*  ROTATE.H, ROTATE.RC                                                       *)
(*                                                                            *)
(*  Add the line: "run rc %N" to the end of your project file.  This will     *)
(*  cause TS to invoke the Microsoft resource compiler after it has created   *)
(*  the EXE file.  You also should have rc.exe in your path along with the    *)
(*  OS/2 header files located in a directory that is referenced by the OS/2   *)
(*  environment variable: INCLUDE.  For example SET INCLUDE = C:\TS\INCLUDE.  *)
(*                                                                            *)
(*  In addition, the following def should be set to true in Win.def:          *)
(*  i_TIMER           = TRUE;    (* Timer routines *)                         *)
(*                                                                            *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)
(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE ROTATE;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT,MPFROMCHAR;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass   = 'Client Window';
  ID_FRAMERC      = 1;
  ID_START_STOP   = 10;
  ID_OPTIONS_SUBMENU = 11;
  ID_COLORS_SUBMENU = 111;
  ID_CSET0          = 1111;
  ID_CSET1          = 1112;
  ID_CSET2          = 1113;
  ID_CSET3          = 1114;
  ID_CSET4          = 1115;
  ID_CSET5          = 1116;
  ID_DELAY_SUBMENU  = 20;
  ID_DELAY0000      = 20000;
  ID_DELAY0100      = 20100;
  ID_DELAY0250      = 20250;
  ID_DELAY0500      = 20500;
  ID_DELAY1000      = 21000;
  ID_EXIT           = 12;
  TID_ROTATE        = 1;

VAR
  rslt          : INTEGER;
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndMenu      : HWND;
  hwnd,
  hwndClient    : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;
  fsSound       : Win.WA;
  idCheckedItem : CARDINAL;
  fRunning      : BOOLEAN;
  iColorSet     : CARDINAL;
  dtDelay       : CARDINAL;
  aclr          : ARRAY [0..5],[0..3] OF COLOR;

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

VAR
  hps : HPS;
  rcl,
  rclWindow : RECTL;
  clrTemp : LONGCARD;


BEGIN
  CASE msg OF
    | Win.WM_COMMAND :
        CASE SHORT1FROMMP(mp1) OF
          | ID_START_STOP :
              IF NOT fRunning THEN
                Win.SendMsg(hwndMenu,Win.MM_SETITEMTEXT,
                            MPFROMSHORT(ID_START_STOP),MPFROMCHAR('~Stop'));
                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(ID_OPTIONS_SUBMENU,CARDINAL(FALSE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_DISABLED),
                                         CARDINAL(Win.MIA_DISABLED)));
                Win.StartTimer(hab,hwnd,TID_ROTATE,dtDelay);
              ELSE
                Win.StopTimer(hab,hwnd,TID_ROTATE);
                Win.SendMsg(hwndMenu,Win.MM_SETITEMTEXT,
                            MPFROMSHORT(ID_START_STOP),MPFROMCHAR('~Start'));
                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(ID_OPTIONS_SUBMENU,CARDINAL(FALSE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_DISABLED),0));
              END;
              fRunning := NOT fRunning;

          | ID_CSET0, ID_CSET1, ID_CSET2, ID_CSET3, ID_CSET4, ID_CSET5 :
                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(iColorSet+ID_CSET0,CARDINAL(TRUE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_CHECKED),0));

                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(CARDINAL(SHORT1FROMMP(mp1)),CARDINAL(TRUE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_CHECKED),
                            CARDINAL(Win.MIA_CHECKED)));

                iColorSet := SHORT1FROMMP(mp1) - ID_CSET0;
                Win.InvalidateRect(hwnd,RECTL(NullVar),B_FALSE)

          | ID_DELAY0000, ID_DELAY0100, ID_DELAY0250, ID_DELAY0500,
            ID_DELAY1000 :
                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(dtDelay+ID_DELAY0000,CARDINAL(TRUE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_CHECKED),0));

                Win.SendMsg(hwndMenu,Win.MM_SETITEMATTR,
                            MPFROM2SHORT(SHORT1FROMMP(mp1),CARDINAL(TRUE)),
                            MPFROM2SHORT(CARDINAL(Win.MIA_CHECKED),
                            CARDINAL(Win.MIA_CHECKED)));

                dtDelay := SHORT1FROMMP(mp1) - ID_DELAY0000;

          | ID_EXIT :
              Win.PostMsg(hwnd,Win.WM_QUIT,NULL,NULL);
        END;

    | Win.WM_TIMER :
        IF (SHORT1FROMMP(mp1) = TID_ROTATE) THEN
          clrTemp := aclr[INTEGER(iColorSet),3];
          aclr[INTEGER(iColorSet),3] := aclr[INTEGER(iColorSet),2];
          aclr[INTEGER(iColorSet),2] := aclr[INTEGER(iColorSet),1];
          aclr[INTEGER(iColorSet),1] := aclr[INTEGER(iColorSet),0];
          aclr[INTEGER(iColorSet),0] := clrTemp;
          Win.InvalidateRect(hwnd,RECTL(NullVar),B_FALSE)
        END;

    | Win.WM_PAINT :
        hps := Win.BeginPaint(hwnd,HPS(NULL),RECTL(NullVar));
        Win.QueryWindowRect(hwnd,rclWindow);

        rcl.xLeft := 0;
        rcl.yBottom := 0;
        rcl.xRight := rclWindow.xRight DIV 2;
        rcl.yTop := rclWindow.yTop DIV 2;
        Win.FillRect(hps,rcl,aclr[INTEGER(iColorSet),0]);

        rcl.yBottom := rcl.yTop;
        rcl.yTop := rclWindow.yTop;
        Win.FillRect(hps,rcl,aclr[INTEGER(iColorSet),1]);

        rcl.xLeft := rcl.xRight;
        rcl.xRight := rclWindow.xRight;
        Win.FillRect(hps,rcl,aclr[INTEGER(iColorSet),2]);

        rcl.yTop := rcl.yBottom;
        rcl.yBottom := 0;
        Win.FillRect(hps,rcl,aclr[INTEGER(iColorSet),3]);

        Win.EndPaint(hps);

    | Win.WM_CREATE :
        hwndMenu := Win.WindowFromID(Win.QueryWindow(hwnd,Win.QW_PARENT,
                                         B_FALSE),Win.FID_MENU);

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

  aclr[0,0]   := Gpi.CLR_RED;
  aclr[0,1]   := Gpi.CLR_RED;
  aclr[0,2]   := Gpi.CLR_RED;
  aclr[0,3]   := Gpi.CLR_WHITE;

  aclr[1,0]   := Gpi.CLR_BLUE;
  aclr[1,1]   := Gpi.CLR_BLUE;
  aclr[1,2]   := Gpi.CLR_BLUE;
  aclr[1,3]   := Gpi.CLR_RED;

  aclr[2,0]   := Gpi.CLR_RED;
  aclr[2,1]   := Gpi.CLR_WHITE;
  aclr[2,2]   := Gpi.CLR_RED;
  aclr[2,3]   := Gpi.CLR_WHITE;

  aclr[3,0]   := Gpi.CLR_RED;
  aclr[3,1]   := Gpi.CLR_BLUE;
  aclr[3,2]   := Gpi.CLR_RED;
  aclr[3,3]   := Gpi.CLR_BLUE;

  aclr[4,0]   := Gpi.CLR_RED;
  aclr[4,1]   := Gpi.CLR_RED;
  aclr[4,2]   := Gpi.CLR_BLUE;
  aclr[4,3]   := Gpi.CLR_WHITE;

  aclr[5,0]   := Gpi.CLR_RED;
  aclr[5,1]   := Gpi.CLR_GREEN;
  aclr[5,2]   := Gpi.CLR_BLUE;
  aclr[5,3]   := Gpi.CLR_WHITE;

  iColorSet := 5;
  dtDelay   := 250;
  fRunning  := FALSE;

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
              ' - Rotate',
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

END ROTATE.
