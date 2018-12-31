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
(*    My first attempt at creating an encapsulated PM window library that     *)
(*    would simplify the task of creating PM windows.  This program           *)
(*    demonstrates the use of JPI's OOP extensions to Modula-2.               *)
(*                                                                            *)
(*----------------------------------------------------------------------------*)

MODULE PMTEST;

(*# call(same_ds => off) *)

FROM OS2DEF IMPORT LSET;
IMPORT Win,Pmwin;

VAR win1 : Pmwin.Stdwin;
    features : LSET;
    title    : ARRAY [0..40] OF CHAR;

BEGIN
  features := Win.FCF_TITLEBAR      + Win.FCF_SYSMENU    +
              Win.FCF_SIZEBORDER    + Win.FCF_MINMAX     +
              Win.FCF_VERTSCROLL    + Win.FCF_HORZSCROLL +
              Win.FCF_SHELLPOSITION + Win.FCF_TASKLIST;

  title := '- My First Window';

  win1.Init(features,title);
  win1.Process;
  win1.Done;
END PMTEST.
