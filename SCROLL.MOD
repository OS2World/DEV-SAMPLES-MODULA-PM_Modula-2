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
(*  Program Notes: page 155.                                                  *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE SCROLL;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM,IO,Str;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  SBM_SETTHUMBSIZE = 2;
  szClientClass = 'Client Window';
  CWPM_CREATE = Win.WM_USER;
  szString    = 'This is a very long line of text that does not '+
                'not fit in the window, and so should be scrolled in order to see the '+
                'entire line. Scrolling is done using the scroll bar of the standard '+
                'window, which is an ownee of the frame, and so transmits its messages to the '+
                'client window procedure which scrolls the text by redisplaying it in the '+
                'appropriate location';

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndScrollBar,
  hwndControl,
  hwndFrame,
  hwndClient,
  client,
  hwnd          : HWND;
  rclText       : RECTL;
  MaxLeft,
  TextLen,
  WindowLen     : CARDINAL;
  r             : Win.MRESULT;
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
  ptlText : ARRAY [0..Gpi.TXTBOX_COUNT] OF POINTL;
  hps           : HPS;
  fSliderMoved,
  rslt          : BOOLEAN;

BEGIN
  CASE msg OF
    | Win.WM_CREATE :
        hwndScrollBar := Win.WindowFromID(Win.QueryWindow(hwnd,Win.QW_PARENT,
                                           B_FALSE),Win.FID_HORZSCROLL);
        hps := Win.GetPS(hwnd);
        Gpi.QueryTextBox(hps,LONGCARD(Str.Length(szString)),szString,
                           Gpi.TXTBOX_COUNT,ptlText);

        Win.ReleasePS(hps);
        rclText.yBottom := 0;
        rclText.yTop    := ptlText[Gpi.TXTBOX_TOPLEFT].y -
                           ptlText[Gpi.TXTBOX_BOTTOMLEFT].y;
        TextLen         := CARDINAL(ptlText[Gpi.TXTBOX_TOPRIGHT].x -
                           ptlText[Gpi.TXTBOX_TOPLEFT].x);
        rclText.xLeft := 0;

    | Win.WM_SIZE :
        WindowLen := SHORT1FROMMP(mp2);
        rclText.xRight := LONGINT(WindowLen - CARDINAL(rclText.xLeft));
        MaxLeft := WindowLen - TextLen;
        Win.SendMsg(hwndScrollBar,Win.SBM_SETSCROLLBAR,
          MPFROMSHORT(CARDINAL(-rclText.xLeft)),
          MPFROM2SHORT(0,CARDINAL(-LONGINT(MaxLeft))));
        Win.SendMsg(hwndScrollBar,SBM_SETTHUMBSIZE,
          MPFROM2SHORT(WindowLen,TextLen),NULL);

    | Win.WM_HSCROLL :
        fSliderMoved := TRUE;
        CASE (SHORT2FROMMP(mp2)) OF
          | Win.SB_LINERIGHT :
              DEC(rclText.xLeft);

          | Win.SB_PAGERIGHT :
              rclText.xLeft := rclText.xLeft - LONGINT(WindowLen);

          | Win.SB_LINELEFT :
              INC(rclText.xLeft);

          | Win.SB_PAGELEFT :
              rclText.xLeft := rclText.xLeft + LONGINT(WindowLen);

          | Win.SB_SLIDERTRACK :
              rclText.xLeft := -LONGINT(SHORT1FROMMP(mp2));

        ELSE
          fSliderMoved := FALSE;
        END;
        IF (fSliderMoved) THEN
          IF (rclText.xLeft > 0) THEN rclText.xLeft := 0
          ELSIF (rclText.xLeft < LONGINT(MaxLeft)) THEN
            rclText.xLeft := LONGINT(MaxLeft);
          END;

          Win.SendMsg(hwndScrollBar,Win.SBM_SETPOS,
                      MPFROMSHORT(CARDINAL(-rclText.xLeft)),NULL);
          Win.InvalidateRect(hwnd,RECTL(NullVar),B_FALSE);
        END;

    | Win.WM_PAINT :
        hps := Win.BeginPaint(hwnd,HPS(NULL),RECTL(NullVar));
        Win.DrawText(hps,-1,szString,rclText,0,0,
                     Win.DT_LEFT+Win.DT_VCENTER+Win.DT_ERASERECT+Win.DT_TEXTATTRS);
        Win.EndPaint(hps);

    | Win.WM_ERASEBACKGROUND :
       RETURN Win.MPARAM(TRUE);

  ELSE
    RETURN Win.DefWindowProc(hwnd,msg,mp1,mp2)
  END;

  RETURN Win.MPARAM(FALSE);

END ClientWinProc;

(*# restore *)
(*---------------------  End of window procedure  ----------------------*)

BEGIN
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST +
                   Win.FCF_HORZSCROLL;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  IF NOT Win.RegisterClass(             (* Register window class        *)
     hab,                               (* Anchor block handle          *)
     szClientClass,                     (* Window class name            *)
     ClientWinProc,                  (* Address of window procedure  *)
     Win.CS_SIZEREDRAW,
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


  WHILE (Win.GetMsg(hab,qmsg,HWND(NULL),0,0)) DO
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

END SCROLL.
