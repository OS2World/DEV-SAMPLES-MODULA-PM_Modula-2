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
(*----------------------------------------------------------------------------*)
(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE STRING;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  CWPM_CREATE = Win.WM_USER;
  ID_TITLE = 1;
  ID_MSG = 2;

VAR
  rslt          : INTEGER;
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndClient,
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;
  chBuf         : ARRAY [0..257] OF CHAR;
  szBuf         : ARRAY [0..100] OF CHAR;

(*--------------------  Error reporting procedure  ---------------------*)
PROCEDURE Error;
VAR
BEGIN
END Error;

(*--------------------  Start of window procedure  ---------------------*)
(*# save,call(near_call=>off,reg_param=>(),reg_saved=>(di,si,ds,es,st1,st2)) *)

PROCEDURE ClientWinProc(hwnd : HWND;
                        msg:CARDINAL;
                        mp1,mp2:Win.MPARAM)
                        : Win.MRESULT;

VAR
  hps                    : HPS;
  rectl                    : RECTL;

BEGIN
  CASE msg OF
    | Win.WM_CREATE :
        rslt := Win.LoadString(hab,NULL,ID_MSG,SIZE(szBuf),szBuf);

    | Win.WM_PAINT:
        hps := Win.BeginPaint(hwnd,HPS(NULL),RECTL(NullVar));
        Win.QueryWindowRect(hwnd,rectl);
        Win.DrawText(hps,-1,szBuf,rectl,0,0,
          Win.DT_CENTER+Win.DT_VCENTER+Win.DT_ERASERECT+Win.DT_TEXTATTRS);
        Win.EndPaint(hps);

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

  rslt := Win.LoadString(hab,NULL,ID_TITLE,SIZE(chBuf),chBuf);

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
              chBuf,
              0,
              NULL,
              0,
              hwndClient);


  WHILE( Win.GetMsg( hab, qmsg, HWND(NULL), 0, 0 ) ) DO
    r := Win.DispatchMsg(hab,qmsg);
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

END STRING.
