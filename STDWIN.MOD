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
(*    This is the basic program to create a standard client window with       *)
(*    scrollbars on the left and bottom and ability to resize itself.         *)
(*    Source code on page 55.                                                 *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE STDWIN;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  client,
  hwnd          : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;

PROCEDURE Error;
BEGIN
END Error;

BEGIN
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_VERTSCROLL + Win.FCF_HORZSCROLL +
                   Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  hwnd := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              flcreateFlags,
              StrPtr(NULL)^,
              ' - My first Window',
              0,
              NULL,
              0,
              client);


  WHILE( Win.GetMsg( hab, qmsg, HWND(NULL), 0, 0 ) ) DO
    r := Win.DispatchMsg( hab, qmsg );
  END;

  IF NOT Win.DestroyWindow(hwnd) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.DestroyMsgQueue( hmq ) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.Terminate( hab ) THEN            (* terminate the application    *)
    Error;
  END;

  HALT;

END STDWIN.

