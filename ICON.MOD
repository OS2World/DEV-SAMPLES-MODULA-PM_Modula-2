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
(*  Page 177.                                                                 *)
(*  Creates a client window.  When window is minimized the icon is displayed  *)
(*  which was created with the icon editor and named ICON.ICO.                *)
(*----------------------------------------------------------------------------*)
(*  Compiling Notes:                                                          *)
(*                                                                            *)
(*  The following files should be available:                                  *)
(*  ICON.H, ICON.RC                                                           *)
(*                                                                            *)
(*  Add the line: "run rc %N" to the end of your project file.  This will     *)
(*  cause TS to invode the Microsoft resource compiler after it has created   *)
(*  the EXE file.  You also should have rc.exe in your path along with the    *)
(*  OS/2 header files located in a directory that is referenced by the OS/2   *)
(*  environment variable: INCLUDE.  For example SET INCLUDE = C:\TS\INCLUDE.  *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE ICON;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;
FROM OS2MAC IMPORT SHORT1FROMMP,SHORT2FROMMP,MPFROMSHORT,MPFROM2SHORT;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

CONST
  szClientClass = 'Client Window';
  ID_FRAMERC    = 1;

VAR
  rslt          : INTEGER;
  hab           : HAB;
  hmq           : Win.HMQ;
  qmsg          : Win.QMSG;
  hwnd          : HWND;
  r             : Win.MRESULT;
  flcreateFlags : LSET;

(*--------------------  Error reporting procedure  ---------------------*)
PROCEDURE Error;
VAR
BEGIN
END Error;
(*-----------------  End of Error reporting procedure  ------------------*)


BEGIN
  flcreateFlags := Win.FCF_TITLEBAR + Win.FCF_SYSMENU + Win.FCF_SIZEBORDER +
                   Win.FCF_MINMAX + Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST +
                   Win.FCF_ICON;

  hab := Win.Initialize(NULL);
  hmq := Win.CreateMsgQueue(hab,0);

  hwnd := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              flcreateFlags,
              StrPtr(NULL)^,
              ' - Minimize this window to see the icon',
              0,
              NULL,
              ID_FRAMERC,
              HWND(NullVar));


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

END ICON.
