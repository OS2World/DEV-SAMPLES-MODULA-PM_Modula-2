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
(*    Puts a big scrollbar on the screen.  This program should be run from    *)
(*    an OS/2 full screen session since there is no provision for the program *)
(*    to terminate itself.                                                    *)
(*    Source code on page 47.                                                 *)
(*----------------------------------------------------------------------------*)
MODULE SCROLLBR;

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;


TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  WINDOW_ID = 1;

VAR
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwndScrollBar : HWND;
  r             : Win.MRESULT;

PROCEDURE Error;
BEGIN
END Error;

BEGIN
  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);


  hwndScrollBar := Win.CreateWindow(
                   Win.HWND_DESKTOP,
                   StrPtr(Win.WC_SCROLLBAR)^,
                   'Test',
                   Win.WS_VISIBLE+Win.SBS_HORZ,
                   100, 100,
                   400, 30,
                   NULL,
                   Win.HWND_TOP,
                   WINDOW_ID,
                   NIL,
                   NIL);


  WHILE( Win.GetMsg( hab, qmsg, HWND(NULL), 0, 0 ) ) DO
    r := Win.DispatchMsg( hab, qmsg );
  END;

  IF NOT Win.DestroyMsgQueue( hmq ) THEN      (* and                          *)
    Error;
  END;

  IF NOT Win.Terminate( hab ) THEN            (* terminate the application    *)
    Error;
  END;

  HALT;

END SCROLLBR.
