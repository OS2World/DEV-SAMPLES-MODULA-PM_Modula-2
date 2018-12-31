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
(*    My very first PM program! All this program does is beep once and exits. *)
(*    Source code on page 25.                                                 *)
(*                                                                            *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

(*# call(same_ds => off) *)
(*# data(heap_size=> 3000) *)

MODULE SOUND;

IMPORT OS2DEF,Win,Gpi,Dos,Lib,SYSTEM;
FROM OS2DEF IMPORT HAB,NULL;

VAR
  Hab       : HAB;

PROCEDURE Error;
BEGIN
END Error;

BEGIN
  Hab := Win.Initialize(NULL);
  IF NOT Win.Alarm(Win.HWND_DESKTOP, Win.WA_NOTE) THEN
     Error;
  END;
  IF NOT Win.Terminate(Hab) THEN
     Error;
  END;
END SOUND.

