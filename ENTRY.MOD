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
(*    Puts a text entry box in the bottom left corner of the client window.   *)
(*    Text will be echoed above box as user enters new data.                  *)
(*    Source code on page 138.                                                *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE ENTRY;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM,IO;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  ID_BUTTON = 1;
  CWPM_CREATE = Win.WM_USER;
  ID_WINDOW = 1;
  MAXTEXT = 25;

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndControl,
  hwndFrame,
  hwndClient,
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  clrOldIndRGB  : COLOR;
  flcreateFlags : LSET;
  fsButtonState : BOOLEAN;
  pszText  : ARRAY [0..MAXTEXT] OF CHAR;
  cchText : CARDINAL;

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
TYPE
  EFData = POINTER TO Win.ENTRYFDATA;

VAR
  hps           : HPS;
  rcl                    : RECTL;
  EFCtlData              : EFData;
  rslt                   : BOOLEAN;

BEGIN
  CASE msg OF
    | Win.WM_CREATE :
        Win.PostMsg(hwnd,CWPM_CREATE,0,0);
        RETURN Win.MPARAM(FALSE);

    | CWPM_CREATE :
        EFCtlData^.cb := 8;
        EFCtlData^.EditLimit := MAXTEXT -1;
        EFCtlData^.MinSel := 0;
        EFCtlData^.MaxSel := MAXTEXT - 1;

        hwndControl := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_ENTRYFIELD)^,
                          'Initial text',
                          Win.WS_VISIBLE + Win.ES_MARGIN,
                          10,10,175,20,
                          hwnd,Win.HWND_TOP,ID_WINDOW,
                          EFCtlData,NIL);

        Win.PostMsg(hwnd,Win.WM_CONTROL,MPFROM2SHORT(0,Win.EN_CHANGE),0);
        Win.SetFocus(Win.HWND_DESKTOP,hwndControl);

    | Win.WM_CONTROL :
        IF (SHORT2FROMMP(mp1) = Win.EN_CHANGE) THEN
          cchText := CARDINAL(Win.QueryWindowText(hwndControl,MAXTEXT,pszText));
          rslt := Win.InvalidateRect(hwnd,RECTL(NullVar),B_FALSE)
        END;

    | Win.WM_PAINT :
        hps := Win.BeginPaint(hwnd,HPS(NULL),rcl);
        Gpi.Erase(hps);
        rcl.xLeft := 10;
        rcl.xRight := 400;
        rcl.yBottom := 40;
        rcl.yTop := 60;
        Win.DrawText(hps,INTEGER(cchText),pszText,rcl,0,0,
                     Win.DT_LEFT+Win.DT_VCENTER+Win.DT_ERASERECT+Win.DT_TEXTATTRS);
        Win.EndPaint(hps);
        RETURN Win.DefWindowProc(hwnd,msg,mp1,mp2);

  ELSE
    RETURN Win.DefWindowProc(hwnd,msg,mp1,mp2)
  END;
  RETURN Win.MPARAM(FALSE);
END ClientWinProc;

(*# restore *)
(*---------------------  End of window procedure  ----------------------*)

BEGIN
  cchText := 0;
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  IF NOT Win.RegisterClass(             (* Register window class        *)
     hab,                               (* Anchor block handle          *)
     szClientClass,                     (* Window class name            *)
     ClientWinProc,                  (* Address of window procedure  *)
     Win.CS_SIZEREDRAW+
     Win.CS_CLIPCHILDREN,
     0                                  (* No extra window words        *)
     ) THEN Error END;

  hwndFrame := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              flcreateFlags,
              szClientClass,
              ' - Controls',
              0,
              NULL,
              0,
              hwndClient);


  WHILE( Win.GetMsg(hab,qmsg,HWND(NULL),0,0)) DO
    r := Win.DispatchMsg(hab,qmsg);
  END;

  IF NOT Win.DestroyWindow(hwndFrame) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.DestroyMsgQueue(hmq) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.Terminate(hab) THEN            (* terminate the application    *)
    Error;
  END;

  HALT;

END ENTRY.
