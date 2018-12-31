





                  Writing Presentation Manager Programs in Modula-2

                                   by Chris Barker

                                   August 4, 1990

     The files contained in this zipped file constitute my attempt to write OS/2
     Presentation Manager programs using JPI's Modula-2 for OS/2 version 2.0.  I
     am both new to Modula-2 and to programming for the Presentation Manager.
     Previously I have been programming extensively with Turbo Pascal and less
     extensively with Turbo C.

     Since the preponderance of documentation for writing PM code is in C, I
     thought the world might benefit from some examples written in another
     language such as Modula-2.  I have taken a very clearly written book,"OS/2
     Presentation Manager - Programming Primer" by Asael Dror and Robert Lafore,
     and adapted their "C" examples to Modula-2.  Hopefully, my adaptions have
     been correct!

     Personally, I find the protective environment of Pascal/Modula-2 (i.e.
     strong type checking, promoting modular projects, etc.) a much more
     comfortable and rewarding programming experience.  I am a very high level
     minded kind of programmer that would prefer to adapt and reuse mine or
     someone else's code (OOP?) to get a job done rather than wallowing down in
     the internals of my computer's CPU.  I am always impressed by the
     blindingly fast routines of a Zen assembler master like Michael Abrash, but
     I'd rather work on a higher level.  Jeff Duntemann is programmer I look up
     to.

     Speaking of OOP, my other reason for being attracted to JPI's M2 for OS/2
     is its inclusion of object extensions to Modula-2.  The example program,
     PMTEST, is my own cursory attempt at encapsulating some of the complexity
     of PM programming using OOPS.  I hope to extend this and leverage some real
     power.  I hope to hear from others that may be trying the same thing.

     While adapting these programs, I came across a few puzzling issues that
     JPI's fairly sparse documentation didn't enlighten me on.  In the cases
     where I got stumped, I spent a lot of time scanning JPI's WIN.DEF file for
     possible answers.  Sometimes I was lucky, other times I wasn't.  For
     example, I am still puzzled by JPI's implementation of PM's two message
     queues.  I have often found that the "correct" M2 code was the opposite of
     the "C" code (e.g. using mp2 instead of mp1).  I am probably missing
     something and would love to be enlightened.  Also, has anyone figured out
     the equivalent M2 routine for the "C" macro: #define SHORT1FROMMP(mp)
     ((USORT)(ULONG)(mp))?  I have tried for example: SHORTCARD(LONGCARD(mp1)),
     but this does not return the correct values.

     So far I have gotten through chapter six of the book and will hopefully
     update this file as I adapt further examples.  Please read the header
     comments in each program before you run the program so you will understand
     what each is supposed to do.  I hope these examples will encourage others
     to try a hand at PM programming using Modula-2.


     Writing OS/2 PM Programs in Modula-2          August 4, 1990         Page 2



     I would love to hear from other programmers.  Please send a message to me,
     Chris Barker, at one of the following:

         -  Compuserve ID: 72261,2312

         -  Pete Norloff's OS/2 Shareware BBS - (703) 385-4325

         -  Max's Doghouse BBS - (703) 548-7849

            The above two BBS carry the Fidonet OS/2 echo which I read
            regularly.

         -  Programmer's Corner - (301) 596-1180

         -  CPCUG Mix (Window Sig) BBS - (301) 738-9060

     Enjoy!








































                                        - 2 -
