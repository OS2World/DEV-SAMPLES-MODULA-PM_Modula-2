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
(*    An example of how to create a "family" of windows. The two extra win-   *)
(*    dows that appear on the screen are child windows of the client window.  *)
(*    When you terminate the client window, its children will also be         *)
(*    terminated.                                                             *)
(*    Source code on page 61.                                                 *)
(*----------------------------------------------------------------------------*)

MODULE FAMILY;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  WINDOW_ID = 1;

VAR
  hab                   : HAB;
  hmq                   : Win.HMQ;
  qmsg                  : Win.QMSG;
  client,
  hwnd,
  hwndSibling1,
  hwndSibling2,
  hwndChildOf2          : HWND;
  r                     : Win.MRESULT;
  flcreateFlags1,
  flcreateFlags2        : LSET;

PROCEDURE Error;
BEGIN
END Error;

BEGIN
  flcreateFlags1 := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                    Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  flcreateFlags2 := Win.FCF_TITLEBAR + Win.FCF_SIZEBORDER +
                    Win.FCF_MINMAX + Win.FCF_SHELLPOSITION;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  hwndSibling1 := Win.CreateStdWindow(
                  Win.HWND_DESKTOP,
                  Win.WS_VISIBLE,flcreateFlags1,StrPtr(NULL)^,
                  ' - Sibling 1',0,NULL,0,client);

  hwndSibling2 := Win.CreateStdWindow(
                  Win.HWND_DESKTOP,
                  Win.WS_VISIBLE,flcreateFlags2,StrPtr(NULL)^,
                  ' Sibling 2',0,NULL,0,client);

  hwndChildOf2 := Win.CreateWindow(
                  hwndSibling2,
                  StrPtr(Win.WC_SCROLLBAR)^,
                  StrPtr(NULL)^,
                  Win.WS_VISIBLE + Win.SBS_HORZ,
                  100,100,400,30,NULL,Win.HWND_TOP,WINDOW_ID,
                  NIL,NIL);

  WHILE (Win.GetMsg(hab,qmsg,HWND(NULL),0,0)) DO
    r := Win.DispatchMsg( hab, qmsg );
  END;

  IF NOT Win.DestroyWindow(hwndChildOf2) THEN
    Error;
  END;

  IF NOT Win.DestroyWindow(hwndSibling2) THEN
    Error;
  END;

  IF NOT Win.DestroyWindow(hwndSibling1) THEN
    Error;
  END;

  IF NOT Win.DestroyMsgQueue( hmq ) THEN
    Error;
  END;

  IF NOT Win.Terminate( hab ) THEN            (* terminate the application    *)
    Error;
  END;

  HALT;

END FAMILY.
