(*----------------------------------------------------------------------------*)
(* Example programs written in JPI Modula-2 Version 2 for OS/2 1.2 by         *)
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
(*    My first attempt at creating an encapsulated PM window library that     *)
(*    would simplify the task of creating PM windows.  This program           *)
(*    demonstrates the use of JPI's OOP extensions to Modula-2.               *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

IMPLEMENTATION MODULE Pmwin;

(*# call(same_ds => off) *)


IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HDC,HRGN,HAB,HPS,HBITMAP,HWND,HMODULE,HSEM,
                   POINTL,RECTL,PID,TID,LSET,NULL,
                   COLOR,NullVar,NullStr,BOOL ;

TYPE
  StrPtr = POINTER TO ARRAY[0..0] OF CHAR;

  Stdwin = CLASS
    x , y,
    cx, cy        : INTEGER;
    hab           : HAB;
    hmq           : Win.HMQ;
    qmsg          : Win.QMSG;
    client,
    hwnd          : HWND;
    r             : Win.MRESULT;

    PROCEDURE Init(details : LSET; titlestr : ARRAY OF CHAR);
    BEGIN
      hab := Win.Initialize(NULL);
      hmq := Win.CreateMsgQueue(hab,0);

      hwnd := Win.CreateStdWindow(
              Win.HWND_DESKTOP,
              Win.WS_VISIBLE,
              details,
              StrPtr(NULL)^,
              titlestr,
              0,
              NULL,
              0,
              client);
    END Init;

    PROCEDURE Error;
    BEGIN
    END Error;

    PROCEDURE Done;
    BEGIN
      IF NOT Win.DestroyWindow(hwnd) THEN
        Error;
      END;

      IF NOT Win.DestroyMsgQueue( hmq ) THEN
        Error;
      END;

      IF NOT Win.Terminate(hab) THEN
        Error;
      END;
    END Done;

    PROCEDURE Draw;
    BEGIN
    END Draw;

    PROCEDURE Process;
    BEGIN
      WHILE( Win.GetMsg(hab, qmsg, HWND(NULL),0,0)) DO
        r := Win.DispatchMsg(hab,qmsg);
      END;
    END Process;

  END;

END Pmwin.
