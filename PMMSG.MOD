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
(*    Provides a excellent way to see what messages are really being sent     *)
(*    during the execution of this program.  When it first starts, you        *)
(*    hear beeps for about 15 seconds before the client window is drawn.      *)
(*    Every time you move the mouse a message will be posted.                 *)
(*    Source code on page 106.                                                *)
(*----------------------------------------------------------------------------*)

IMPLEMENTATION MODULE PMMSG;

BEGIN
  msglist := MsgArray('WM_NULL',
                      'WM_CREATE',
                      'WM_DESTROY',
                      'WM_OTHERWINDOWDESTOYED',
                      'WM_ENABLE',
                      'WM_SHOW',
                      'WM_MOVE',
                      'WM_SIZE',
                      'WM_ADJUSTWINDOWPOS',
                      'WM_CALCVALIDRECTS',
                      'WM_SETWINDOWPARAMS',
                      'WM_QUERYWINDOWPARAMS',
                      'WM_HITTEST',
                      'WM_ACTIVATE',
                      'VOID',
                      'WM_SETFOCUS',
                      'WM_SETSELECTION',
                      'WM_PPAINT',
                      'WM_PSETFOCUS',
                      'WM_PSYSCOLORCHANGE',
                      'WM_PSIZE',
                      'WM_PACTIVATE',
                      'WM_PCONTROL',
                      '???','???','???','???','???','???','???','???','???',
                      'WM_COMMAND',
                      'WM_SYSCOMMAND',
                      'WM_HELP',
                      'WM_PAINT',
                      'WM_TIMER',
                      'WM_SEM1',
                      'WM_SEM2',
                      'WM_SEM3',
                      'WM_SEM4',
                      'WM_CLOSE',
                      'WM_QUIT',
                      'WM_SYSCOLORCHNAGE',
                      '???',
                      'WM_SYSVALUECHANGED',
                      'WM_APPTERMINATENOTIFY',
                      'WM_PRESPARMCHANGED',
(* control notification messages *)
                      'WM_CONTROL',
                      'WM_VSCROLL',
                      'WM_HSCROLL',
                      'WM_INITMENU',
                      'WM_MENUSELECT',
                      'WM_MENUEND',
                      'WM_DRAWITEM',
                      'WM_MEASUREITEM',
                      'WM_CONTROLPOINTER',
                      'WM_CONTROLHEAP',
                      'WM_QUERYDLGCODE',
                      'WM_INITDLG',
                      'WM_SUBSTITUTESTRING',
                      'WM_MATCHMNEMONIC',
                      'WM_SAVEAPPLICATION',
                      '???',
(* frame manager messages *)
                      'WM_FLASHWINDOW',
                      'WM_FORMATFRAME',
                      'WM_UPDATEFRAME',
                      'WM_FOCUSCHANGE',
                      'WM_SETBORDERSIZE',
                      'WM_TRACKFRAME',
                      'WM_MINMAXFRAME',
                      'WM_SETICON',
                      'WM_QUERYICON',
                      'WM_SETACCELTABLE',
                      'WM_QUERYACCELTABLE',
                      'WM_TRANSLATEACCEL',
                      'WM_QUERYTRACKINFO',
                      'WM_QUERYBORDERSIZE',
                      'WM_NEXTMENU',
                      'WM_ERASEBACKGROUND',
                      'WM_QUERYFRAMEINFO',
                      'WM_QUERYFOCUSCHAIN',
                      '???',
                      'WM_CALCFRAMERECT',
                      '???',
                      'WM_WINDOWPOSCHANGED',
                      '???','???','???',
                      'WM_QUERYFRAMECTLCOUNT',
                      '???',
                      'WM_QUERYHELPINFO',
                      'WM_SETHELPINFO',
                      'WM__ERROR',
                      '???','???',
(* clipboard messages *)
                      'WM_RENDERFMT',
                      'WM_RENDERALLFMTS',
                      'WM_DESTROYCLIPBOARD',
                      'WM_PAINTCLIPBOARD',
                      'WM_SIZECLIPBOARD',
                      'WM_HSCROLLCLIPBOARD',
                      'WM_VSCROLLCLIPBOARD',
                      'WM_DRAWCLIPBOARD',
                      '???','???','???','???','???','???','???','???',
                      'WM_MOUSEMOVE',
                      'WM_BUTTON1DOWN',
                      'WM_BUTTON1UP',
                      'WM_BUTTON1DBLCLK',
                      'WM_BUTTON2DOWN',
                      'WM_BUTTON2UP',
                      'WM_BUTTON2DBLCLK',
                      'WM_BUTTON3DOWN',
                      'WM_BUTTON3UP',
                      'WM_BUTTON3DBLCLK',
(* character input messages *)
                      'WM_CHAR',
                      'WM_QUEUESYNC',
                      'WM_JOURNALNOTIFY');
END PMMSG.
