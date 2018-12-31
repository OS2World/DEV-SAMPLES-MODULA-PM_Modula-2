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
(*    Puts a text entry box in the bottom left corner of the client window.   *)
(*    Text will be echoed above box as user enters new data.                  *)
(*    Source code on page 146.                                                *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE LISTBOX;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM,IO;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT,
            SHORT1FROMMR,MPFROMCHAR;

CONST
  NWORDS = 9;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;
  ShortStr = ARRAY [0..50] OF CHAR;
  ShortStrArray = ARRAY [0..1],[0..NWORDS] OF ShortStr;

CONST
  szClientClass = 'Client Window';
  CWP_CREATE = Win.WM_USER;
  ID_WINDOW = 1;

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndFrame,
  hwndClient,
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  clrOldIndRGB  : COLOR;
  flcreateFlags : LSET;
  ItemIndex     : CARDINAL;
  hwndControl   : HWND;
  statvar       : BOOLEAN;
  aszGlossary   : ShortStrArray;

PROCEDURE Error;
BEGIN
END Error;

(*--------------------  Start of window procedure  ---------------------*)
(*# save,call(near_call=>off,reg_param=>(),reg_saved=>(di,si,ds,es,st1,st2)) *)

PROCEDURE ClientWinProc(hwnd : HWND;
                       msg:CARDINAL;
                       mp1,mp2:Win.MPARAM)
                       : Win.MRESULT;
VAR
  hps           : HPS;
  rcl           : RECTL;
  rslt          : BOOLEAN;
  mrslt         : Win.MRESULT;

BEGIN
  CASE msg OF
    | Win.WM_CREATE :
        Win.PostMsg(hwnd,CWP_CREATE,0,0);
        RETURN Win.MPARAM(FALSE);


    | CWP_CREATE :
        hwndControl := Win.CreateWindow(
                          hwnd,
                          StrPtr(Win.WC_LISTBOX)^,
                          'Glossary',
                          Win.WS_VISIBLE,
                          10,40,150,70,
                          hwnd,Win.HWND_TOP,ID_WINDOW,
                          NIL,NIL);

        FOR ItemIndex := 0 TO NWORDS - 1 DO
            Win.SendMsg(hwndControl,Win.LM_INSERTITEM,
                      MPFROMSHORT(ItemIndex),
                      MPFROMCHAR(aszGlossary[0,INTEGER(ItemIndex)]));
        END;


    | Win.WM_CONTROL :
        IF (SHORT2FROMMP(mp1) = Win.LN_SELECT) THEN
          ItemIndex := SHORT1FROMMR(Win.SendMsg(hwndControl,Win.LM_QUERYSELECTION,
                                 NULL,NULL));
        Win.InvalidateRect(hwnd,RECTL(NullVar),B_FALSE);
        END;


    | Win.WM_PAINT :
        hps := Win.BeginPaint(hwnd,HPS(NULL),RECTL(NullVar));
        Gpi.Erase(hps);
        rcl.xLeft := 10;
        rcl.xRight := 500;
        rcl.yBottom := 10;
        rcl.yTop := 30;
        Win.DrawText(hps,-1,aszGlossary[1,INTEGER(ItemIndex)],rcl,0,0,
                     Win.DT_LEFT+Win.DT_VCENTER+Win.DT_ERASERECT+Win.DT_TEXTATTRS);
        Win.EndPaint(hps);

  ELSE
    RETURN Win.DefWindowProc(hwnd,msg,mp1,mp2)
  END;
  RETURN Win.MPARAM(FALSE);
END ClientWinProc;

(*# restore *)
(*---------------------  End of window procedure  ----------------------*)

BEGIN
  aszGlossary[0,0] := 'Active window';
  aszGlossary[1,0] := 'Frame window ancestor of Keyboard focus window';
  aszGlossary[0,1] := 'Class';
  aszGlossary[1,1] := 'Windows sharing a common procedure';
  aszGlossary[0,2] := 'Controls';
  aszGlossary[1,2] := 'What this chapter is all about';
  aszGlossary[0,3] := 'List box';
  aszGlossary[1,3] := 'The type of control window you are looking at';
  aszGlossary[0,4] := 'Message';
  aszGlossary[1,4] := 'Information sent to a window';
  aszGlossary[0,5] := 'Owner';
  aszGlossary[1,5] := 'Window to which owner sends notification messages';
  aszGlossary[0,6] := 'Parent';
  aszGlossary[1,6] := 'Window to which child is clipped';
  aszGlossary[0,7] := 'Standard window';
  aszGlossary[1,7] := 'Frame window plus children';
  aszGlossary[0,8] := 'Window';
  aszGlossary[1,8] := 'An object';
  aszGlossary[0,9] := '';
  aszGlossary[1,9] := 'Select a word';

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

END LISTBOX.
