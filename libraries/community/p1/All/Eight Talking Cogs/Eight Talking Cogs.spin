{{
    *****************************************************
    *       Eight Talking Cogs Educational Object       *
    *                 Version 1.3                       *
    *                   2/28/07                         *
    *          Main Author: James A. Coleman            *
    *             jamesacoleman@aol.com                 *
    *             Category: Educational                 *
    *   Questions? Please post on the Propeller forum   *
    *        http://forums.parallax.com/forums/         *
    * Uses Martin Hebel's BS2 Function Library Routines *
    *****************************************************

    Eight Talking Cogs is an educational program that demonstrates simultaneous/continuous
    Cog-to-Cog and Cog-to-PC communication in both synchronized/independent Cog operation.
    Eight Talking Cogs utilize BS2 Function Library Routines for Cog communication and Spin
    Lock Commands for Cog timing and resource allocation.  Each Cog controls an Led to
    visually display synchronization between Cog work functions and PC output messages.

    For educational simplicity, each Cog is treated as a microprocessor consisting of one
    Receive pin, one Transmit pin, one Led pin, one shared Debug pin and one shared DebugIn
    pin. All pins have a discrete input or output function to enhance clarity of operation.
    Pin function sharing is not done.  BS2 Function Library Routines, Version 1.3.5, is the
    main language with a few Spin Commands to glue the program together. It was necessary
    to provide a separate copy of the BS2 Function Library Routines to each Cog to insure
    that no interference would occur between BS2 Routines.  For multi-Cog PC terminal
    transmissions I would recommend this.
  
    Circuitry for Eight Talking Cogs consists of 8 Leds, 8 resistors, and 8 jumper wires.

                    ┌─────────────┐                ┌─────┬──────┬──────┬──────┬───┬───┐
    ┌───────────────┤A0        A31│                │Micro│LedPin│RecPin│TrnPin│Obj│Cog│
    │             ┌─┤A1        A30│                ├─────┼──────┼──────┼──────┼───┼───┤
    │           ┌─┼─┤A2        A29│                │  1  │  A16 │  A0  │  A8  │ 0 │ 0 │
    │         ┌─┼─┼─┤A3        A28│                ├─────┼──────┼──────┼──────┼───┼───┤
    │       ┌─┼─┼─┼─┤A4        A27│                │  2  │  A17 │  A1  │  A9  │ 1 │ 1 │
    │     ┌─┼─┼─┼─┼─┤A5        A26│                ├─────┼──────┼──────┼──────┼───┼───┤
    │   ┌─┼─┼─┼─┼─┼─┤A6        A25│                │  3  │  A18 │  A2  │  A10 │ 2 │ 2 │
    │ ┌─┼─┼─┼─┼─┼─┼─┤A7        A24│                ├─────┼──────┼──────┼──────┼───┼───┤
    │ │ │ │ │ │ │ │ │Gnd      3.3V│                │  4  │  A19 │  A3  │  A11 │ 3 │ 3 │
    │ │ │ │ │ │ │ │ │BOEn       XO│                ├─────┼──────┼──────┼──────┼───┼───┤
    │ │ │ │ │ │ │ │ │RSTn       X1│                │  5  │  A20 │  A4  │  A12 │ 4 │ 4 │
    │ │ │ │ │ │ │ │ │3.3V      Gnd│  100Ω          ├─────┼──────┼──────┼──────┼───┼───┤
    │ │ │ │ │ │ │ └─┤A8        A23├─────────┐   │  6  │  A21 │  A5  │  A13 │ 5 │ 5 │
    │ │ │ │ │ │ └───┤A9        A22├─────────┫   ├─────┼──────┼──────┼──────┼───┼───┤
    │ │ │ │ │ └─────┤A10       A21├─────────┫   │  7  │  A22 │  A6  │  A14 │ 6 │ 6 │
    │ │ │ │ └───────┤A11       A20├─────────┫   ├─────┼──────┼──────┼──────┼───┼───┤
    │ │ │ └─────────┤A12       A19├─────────┫   │  8  │  A23 │  A7  │  A15 │ 7 │ 7 │
    │ │ └───────────┤A13       A18├─────────┫   └─────┴──────┴──────┴──────┴───┴───┘
    │ └─────────────┤A14       A17├─────────┫
    └───────────────┤A15       A16├─────────┘
                    └─────────────┘
                       
    Essentially, all Cogs are using only one PUB routine in which four work functions
    or program sections are in essence talking to themselves.  There are four repeated work
    functions: (1)Cog-to-Cog Serial; (2)Cog-to-Cog Parallel; (3)Cog-Alone Random Blinking;
    and (4)Cog-Alone Keyboard Input.  Eight Talking Cogs is designed to be used with the
    Stamp v2.2 Debug window only, not the hyper terminal.  Since all Cog operations are
    synchronized with the 8 Leds, it is interesting to watch the Stamp Debug window with
    one eye and the individual Cog Leds with the other and try to imagine all 8 Cogs
    operating together at one time and then independently at another time, all the while
    communicating with the Stamp Debug terminal without interference.  The Propeller is
    certainly a beautiful piece of work.

    Note: In these software descriptions it is important to note that all message
    transmissions to the PC terminal are from within the Cogs.  There is no faking message
    transmission from a single Cog.  
 
    More specifically, Eight Talking Cogs does the following:
    
    Demonstrates the BS2 Debug/DebugIn/SerIn/SerOut Function Library Routines operating at
    9600 baud for Cog-to-Cog and Cog-to-PC communication without interference.

    Demonstrates the Spin Locknew/Lockset/Lockclr Commands to control Cog synchronization
    and to insure that the PC Debug terminal window is available to only one Cog work
    function at a time to prevent interference.

    Demonstrates the use of one Led for each Cog to show synchronization between Cog Output
    and PC terminal window display.

    Demonstrates a Cog-to-Cog Serial work function in which each Cog receives a message
    from a previous Cog and sends a message to the next Cog until all eight Cogs have
    completed this serial cycle.  All messages sent and received by individual Cogs are
    displayed on the PC. 

    Demonstrates a Cog-to-Cog Parallel work function in which four Cogs simultaneously send
    a message to four other Cogs.  All messages sent and received by individual Cogs are
    displayed on the PC. 

    Demonstrates a Cog-Alone Random Blinking work function in which the Spin Random Command
    is used to set a new and different blink rate for each Cog and for each pass through
    the work function based on a different initial seed value for each Cog.

    Demonstrates a Cog-Alone Keyboard Input work function in which seven Cogs request an
    input from the terminal keyboard to set their blink rate.  A Cog watchdog 3 second
    timer is also used to provide a default terminal input to the requesting seven
    Cogs when the PC operator's response is delayed which insures that Eight Taking Cogs
    will cycle continuously without operator input.

    Even more specifically, Eight Talking Cogs does the following:

    PROGRAM START 0.0:

    Cog0 initializes 8 BS2 Objects, Rx and Tx pins for DEBUG (BLOCK 0.1)
    Cog0 check out SemID0 lock to control the Debug resource (BLOCK 0.2)
    Cog0 check out SemID1 lock for Cog synchronization at PROGRAM END (BLOCK 0.2)
    Cog0 check out SemID2 lock for Cog control between WORK FUNCTION 1.0 and 2.0 (BLOCK 0.2)
    Cog0 check out SemID3 lock for Cog control between WORK FUNCTION 2.0 and 3.0 (BLOCK 0.2)
    Cog0 start Cog1 thru Cog7 to run Spin method Blink (BLOCK 0.3/6.1)
    Cog1 start Debug running  with 6 carriage return's and a clear screen (BLOCK 6.2)
    thru initialize each Cog's Random operator seed to their LedPin number (BLOCK 6.3) 
    Cog7 initialize the synchronization control variables (BLOCK 6.4)
    Cog0 set Random16 variable and lock the semaphore's SemID1, SemID2, SemID3 (BLOCK 0.4) 

    Cog-to-Cog Serial Work Function 1.0:
        
    Cog0 lock the semaphore SemID2 with lockset (BLOCK 0.4/5.2)
    Cog0 enters PUB Blink method (BLOCK 0.5/6.1)
    Cog0 start Debug running with 6 carriage return's and a clear screen (BLOCK 6.2)
    Cog0 initialize Random operator seed(LedPin16): Random := Random16 (BLOCK 6.3) 
    Cog0 initialize the synchronization control variables (BLOCK 6.4)
    
    Cog0 blinks LedPin16 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog0 blinks LedPin16 at 700ms and sends message to Cog1 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog0 receives message from Cog7 and,
           activates Cog0 Serin command x == 1 z == 2 (BLOCK 1.4)
    Cog0 sends received message to PC x == 1 z == 2 (BLOCK 1.5)
    Cog0 exits repeat-loop x == 1 z == 2 and starts x == 2,3,4 z == 1,2 (BLOCK 1.5)
    Cog0 blinks LedPin16 at 0ms sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog0 blinks LedPin16 at 0ms sends message to Cog1 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog0 receives message from Cog7 and,
           activates Cog0 Serin command x == 2,3,4 z == 2 (BLOCK 1.4)    
    Cog0 sends received message to PC (BLOCK 1.5)
    Cog0 exits repeat-loop x == 2,3,4 z == 2 (BLOCK 1.5)
    Cog0 for each repeat-loop x == 1,2,3,4 sends carriage return to PC (BLOCK 1.9)

    Cog1 receives message from Cog0 and,
           activates Cog1 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog1 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog1 blinks LedPin17 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog1 blinks LedPin17 at 700ms and sends message to Cog2 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog1 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog1 blinks LedPin17 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog1 blinks LedPin17 at 0ms and sends message to Cog2 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog1 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog1 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog2 receives message from Cog1 and,
           activates Cog2 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog2 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog2 blinks LedPin18 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog2 blinks LedPin18 at 700ms and sends message to Cog3 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog2 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog2 blinks LedPin18 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog2 blinks LedPin18 at 0ms and sends message to Cog3 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog2 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog2 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog3 receives message from Cog2 and,
           activates Cog3 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog3 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog3 blinks LedPin19 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog3 blinks LedPin19 at 700ms and sends message to Cog4 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog3 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog3 blinks LedPin19 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog3 blinks LedPin19 at 0ms and sends message to Cog4 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog3 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog3 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog4 receives message from Cog3 and,
           activates Cog4 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog4 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog4 blinks LedPin20 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog4 blinks LedPin20 at 700ms and sends message to Cog5 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog4 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog4 blinks LedPin20 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog4 blinks LedPin20 at 0ms and sends message to Cog5 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog4 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog4 locked until semaphore SemID2 is cleared (BLOCK 1.10)
        
    Cog5 receives message from Cog4 and,
           activates Cog5 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog5 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog5 blinks LedPin21 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog5 blinks LedPin21 at 700ms and sends message to Cog6 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog5 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog5 blinks LedPin21 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog5 blinks LedPin21 at 0ms and sends message to Cog6 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog5 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog5 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog6 receives message from Cog5 and,
           activates Cog6 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog6 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog6 blinks LedPin22 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog6 blinks LedPin22 at 700ms and sends message to Cog7 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog6 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog6 blinks LedPin22 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog6 blinks LedPin22 at 0ms and sends message to Cog7 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog6 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog6 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog7 receives message from Cog6 and,
           activates Cog7 Serin command x == 1 z == 1 (BLOCK 1.4)
    Cog7 sends received message to PC x == 1 z == 1 (BLOCK 1.5)
    Cog7 blinks LedPin23 at 700ms and sends message to PC during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.6)
    Cog7 blinks LedPin23 at 700ms and sends message to Cog0 during,
           first pass thru repeat-loop's x == 1 z == 1 (BLOCK 1.7)
    Cog7 quits repeat-loop after first pass x == 1 z == 1 (BLOCK 1.8)
    Cog7 blinks LedPin23 at 0ms and sends message to PC for,            
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.6)
    Cog7 blinks LedPin23 at 0ms and sends message to Cog0 for,
           next three passes thru repeat-loop's x == 2,3,4 z == 1 (BLOCK 1.7)
    Cog7 quits repeat-loop after each pass x == 2,3,4 z == 1 (BLOCK 1.8)
    Cog7 locked until semaphore SemID2 is cleared (BLOCK 1.10)
    
    Cog0 waits 2000ms (BLOCK 1.11)  
    Cog0 clears semaphore SemID2 and releases Cog1 thru Cog7 to unlock (BLOCK 1.12)
    Cog0 starts WORK FUNCTION 2.0 after unlocking itself (BLOCK 1.12)

    Cog1 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog2 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog3 clears semaphore SemId2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog4 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog5 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog6 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)
    Cog7 clears semaphore SemID2/unlocks itself/starts WORK FUNCTION 2.0 (BLOCK 1.10)

    Cog-to-Cog Parallel Work Function 2.0:
                                                           
    Cog0 locks the semaphore SemID3 with lockset (BLOCK 0.4/5.2)
    
    Select (Cog1-LedPin17 Cog3-LedPin19 Cog5-LedPin21 Cog7-LedPin23) as sender (BLOCK 2.5) 

    Cog7 blinks LedPin23 sends message to PC (BLOCK 2.7)
    Cog7 locked until CogWait5[17,19,21,23] == 0 (BLOCK 2.9)

    Cog5 waits 2000ms (BLOCK 2.6)
    Cog5 blinks LedPin21 sends message to PC (BLOCK 2.7)
    Cog5 locked until CogWait5[17,19,21,23] == 0 (BLOCK 2.9)

    Cog3 waits 4000ms (BLOCK 2.6)
    Cog3 blinks LedPin19 sends message to PC (BLOCK 2.7)
    Cog3 locked until CogWait5[17,19,21,23] == 0 (BLOCK 2.9)

    Cog1 waits 6000ms (BLOCK 2.6)
    Cog1 blinks LedPin17 sends message to PC (BLOCK 2.7)
    Cog1 sends carriage return to PC (BLOCK 2.8)
    Cog1 locked until CogWait5[17,19,21,23] == 0 (BLOCK 2.9)

    Cog7 unlocks when CogWait5[17,19,21,23] == 0 (BLOCK 2.9)
    Cog7 blinks LedPin23 sends message to Cog0  (BLOCK 2.10)
    Cog7 locked until semaphore SemID3 is cleared (BLOCK 2.12)        

    Cog5 unlocks when CogWait5[17,19,21,23] == 0 (BLOCK 2.9)
    Cog5 blinks LedPin21 sends message to Cog6  (BLOCK 2.10)
    Cog5 locked until semaphore SemID3 is cleared (BLOCK 2.12)    

    Cog3 unlocks when CogWait5[17,19,21,23] == 0 (BLOCK 2.9)
    Cog3 blinks LedPin19 sends message to Cog4  (BLOCK 2.10)
    Cog3 locked until semaphore SemID3 is cleared (BLOCK 2.12)        

    Cog1 unlocks when CogWait5[17,19,21,23] == 0 (BLOCK 2.9)
    Cog1 blinks LedPin17 sends message to Cog2  (BLOCK 2.10)
    Cog1 locked until semaphore SemID3 is cleared (BLOCK 2.12)        

    Cog1 sends message to PC announcing release of Cog1/Cog3/Cog5/Cog7 (BLOCK 2.11)
    
    Select (Cog0-LedPin16 Cog2-LedPin18 Cog4-LedPin20 Cog6-LedPin22) as receiver (BLOCK 2.1)
     
    Cog6 receives message from Cog5 and activates Cog6 Serin command (BLOCK 2.2)
    Cog6 waits 2000ms (BLOCK 2.3)
    Cog6 blinks LedPin22 sends received message to PC (BLOCK 2.4)
    Cog6 locked until semaphore SemID3 is cleared (BLOCK 2.12)

    Cog4 receives message from Cog3 and activates Cog4 Serin command (BLOCK 2.2)
    Cog4 waits 4000ms (BLOCK 2.3)
    Cog4 blinks LedPin20 sends received message to PC (BLOCK 2.4)
    Cog4 locked until semaphore SemID3 is cleared (BLOCK 2.12)

    Cog2 receives message from Cog1 and activates Cog2 Serin command (BLOCK 2.2)
    Cog2 waits 6000ms (BLOCK 2.3)
    Cog2 blinks LedPin18 sends received message to PC (BLOCK 2.4)
    Cog2 locked until semaphore SemID3 is cleared (BLOCK 2.12)

    Cog0 receives message from Cog7 and activates Cog0 Serin command (BLOCK 2.2)
    Cog0 waits 8000ms (BLOCK 2.3)
    Cog0 blinks LedPin16 sends received message to PC (BLOCK 2.4)
    Cog0 sends carriage return to PC (BLOCK 2.13) 
    Cog0 clears semaphore SemID3 and releases Cog1 thru Cog7 to unlock (BLOCK 2.14)
    Cog0 starts WORK FUNCTION 3.0 after unlocking itself

    Cog1 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog2 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog3 clears semaphore SemId3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog4 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog5 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog6 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)
    Cog7 clears semaphore SemID3/unlocks itself/starts WORK FUNCTION 3.0 (BLOCK 2.12)

    Cog-Alone Random Blinking Work Function 3.0:

    Cog0 calculates Pause using Spin Random Command with Random16 (Global) (BLOCK 3.1)
    Cog0 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog0 blinks LedPin16 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog0 save Random16 := Random and quit PUB BLINK method (BLOCK 3.4)
    Cog0 locked until release by CogWait6[17,18,19,20,21,22,23] == 0 (BLOCK 3.6)
    Cog0 starts WORK FUNCTION 4.0 after being released (BLOCK 4.1)

    Cog1 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog1 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog1 blinks LedPin17 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog1 setup release of Cog0 with CogWait6[17] := 0 (BLOCK 3.5)
    Cog1 locked until CogWait4[17] == 0 (BLOCK 4.2)

    Cog2 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog2 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog2 blinks LedPin18 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog2 setup release of Cog0 with CogWait6[18] := 0 (BLOCK 3.5)
    Cog2 locked until CogWait4[18] == 0 (BLOCK 4.2)

    Cog3 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog3 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog3 blinks LedPin19 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3))
    Cog3 setup release of Cog0 with CogWait6[19] := 0 (BLOCK 3.5)
    Cog3 locked until CogWait4[19] == 0 (BLOCK 4.2)

    Cog4 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog4 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog4 blinks LedPin20 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog4 setup release of Cog0 with CogWait[20} := 0 (BLOCK 3.5)
    Cog4 locked until CogWait4[20] == 0 (BLOCK 4.2)

    Cog5 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog5 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog5 blinks LedPin21 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog5 setup release of Cog0 with CogWait[21] := 0 (BLOCK 3.5)
    Cog5 locked until CogWait4[21] == 0 (BLOCK 4.2)

    Cog6 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog6 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog6 blinks LedPin22 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog6 setup release of Cog0 with CogWait[22] := 0 (BLOCK 3.5)
    Cog6 locked until CogWait4[22] == 0 (BLOCK 4.2)

    Cog7 calculates Pause using Spin Random Command with Random (Local) (BLOCK 3.1)
    Cog7 sends Pause calculation message to PC (BLOCK 3.2) 
    Cog7 blinks LedPin23 10 cycles with On/Off time equal to Pause/Pause (BLOCK 3.3)
    Cog7 setup release of Cog0 with CogWait[23] := 0 (BLOCK 3.5)
    Cog7 locked until CogWait4[23] == 0 (BLOCK 4.2)

    Cog-Alone Keyboard Input WORK FUNCTION 4.0:
    
    Cog0 locks the semaphore SemID1 with lockset (BLOCK 0.4/5.2)
    Cog0 releases Cog1 with CogWait4[17] := 0 to start WORK FUNCTION 4.0   
    Cog0 starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog1 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog1 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog1 kills Cog0 WatchDog timer by CogWait2[17] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog1 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog1 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog1 signals completion of Work Function 4.0 by CogWait3[17] := 0 (BLOCK 5.1)
    Cog1 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog2 with CogWait4[18] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog2 requests keyboard input from PC to set LedPin18 blink rate 1 to 9 (BLOCK 4.3)
    Cog2 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog2 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog2 kills Cog0 WatchDog timer by CogWait2[18] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog2 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog2 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog2 signals completion of Work Function 4.0 by CogWait3[18] := 0 (BLOCK 5.1)
    Cog2 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog3 with CogWait4[19] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog3 requests keyboard input from PC to set LedPin19 blink rate 1 to 9 (BLOCK 4.3)
    Cog3 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog3 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog3 kills Cog0 WatchDog timer by CogWait2[19] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog3 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog3 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog3 signals completion of Work Function 4.0 by CogWait3[19] := 0 (BLOCK 5.1)
    Cog3 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog4 with CogWait4[20] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog4 requests keyboard input from PC to set LedPin20 blink rate 1 to 9 (BLOCK 4.3)
    Cog4 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog4 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog4 kills Cog0 WatchDog timer by CogWait2[20] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog4 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog4 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog4 signals completion of Work Function 4.0 by CogWait3[20] := 0 (BLOCK 5.1)
    Cog4 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog5 with CogWait4[21] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog5 requests keyboard input from PC to set LedPin21 blink rate 1 to 9 (BLOCK 4.3)
    Cog5 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog5 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog5 kills Cog0 WatchDog timer by CogWait2[21] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog5 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog5 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog5 signals completion of Work Function 4.0 by CogWait3[21] := 0 (BLOCK 5.1)
    Cog5 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog6 with CogWait4[22] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog6 requests keyboard input from PC to set LedPin22 blink rate 1 to 9 (BLOCK 4.3)
    Cog6 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog6 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog6 kills Cog0 WatchDog timer by CogWait2[22] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog6 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog6 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog6 signals completion of Work Function 4.0 by CogWait3[22] := 0 (BLOCK 5.1)
    Cog6 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    Cog0 releases Cog7 with CogWait4[23] := 0 to continue WORK FUNCTION 4.0 and,
           starts 3 sec WatchDog timer (BLOCK 4.1/4.2)
    Cog7 requests keyboard input from PC to set LedPin23 blink rate 1 to 9 (BLOCK 4.3)
    Cog7 accepts DebugIn input Pause from keyboard (BLOCK 4.4)
    Cog7 tests Pause for proper entry and echos final value to PC (BLOCK 4.5)
    Cog7 kills Cog0 WatchDog timer by CogWait2[23] := 0 for any keyboard entry (BLK 4.5/4.1)
    Cog0 if WatchDog timer times out because of no keyboard entry, then
           Cog0 sends 0 to Cog7 DebugIn pin and sends message to PC (BLOCK 4.1)
    Cog7 receives 0 DebugIn input from Cog0 sets Pause := 1 (BLOCK 4.6)
    Cog7 signals completion of Work Function 4.0 by CogWait3[23] := 0 (BLOCK 5.1)
    Cog7 locked until semaphore SemID1 is cleared (BLOCK 5.1)

    PROGRAM END 5.0:

    Cog0 released by CogWait3[17,18,19,20,21,22,23] == 0 (BLOCK 5.2)
    Cog0 blinks LedPin16,17,18,19,20,21,22,23 10 cycles (BLOCK 5.2)
    Cog0 sends messages to PC (BLOCK 5.2)
    Cog0 waits 4000ms 
    Cog0 sends clear screen to PC (BLOCK 5.2)
    Cog0 clears semaphore SemID1 and releases Cog1 thru Cog7 to unlock (BLOCK 5.2)
    Cog0 locks the semaphores SemID1, SemID2 and SemID3 with lockset (BLOCK 5.2)
    Cog0 starts WORK FUNCTION 1.0 (BLOCK 1.1)
    
    Cog1 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog2 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog3 clears semaphore SemId1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog4 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog5 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog6 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)
    Cog7 clears semaphore SemID1/unlocks itself/starts WORK FUNCTION 1.0 (BLOCK 5.1/6.4)

    Software FLOW DIAGRAM, BLOCK STRUCTURE:
    
    ********************************
    BLOCK 0.1   PUB START METHOD 0.0
    BLOCK 0.1      PROGRAM START 0.0
    BLOCK 0.2
    BLOCK 0.3
    BLOCK 0.4
    BLOCK 0.5
    ********************************
    BLOCK 3.6      WORK FUNCTION 3.0
    ********************************
    BLOCK 4.1      WORK FUNCTION 4.0
    ********************************
    BLOCK 5.2        PROGRAM END 5.0
    ********************************
    BLOCK 6.1   PUB BLINK METHOD 6.0
    BLOCK 6.2
    BLOCK 6.3
    BLOCK 6.4
    ********************************
    BLOCK 1.1      WORK FUNCTION 1.0
    BLOCK 1.2
    BLOCK 1.3
    BLOCK 1.4
    BLOCK 1.5
    BLOCK 1.6
    BLOCK 1.7
    BLOCK 1.8
    BLOCK 1.9
    BLOCK 1.10
    BLOCK 1.11
    BLOCK 1.12
    ********************************
    BLOCK 2.1      WORK FUNCTION 2.0
    BLOCK 2.2
    BLOCK 2.3
    BLOCK 2.4
    BLOCK 2.5
    BLOCK 2.6
    BLOCK 2.7
    BLOCK 2.8
    BLOCK 2.9
    BLOCK 2.10
    BLOCK 2.11
    BLOCK 2.12
    BLOCK 2.13
    BLOCK 2.14
    ********************************
    BLOCK 3.1      WORK FUNCTION 3.0
    BLOCK 3.2
    BLOCK 3.3
    BLOCK 3.4
    BLOCK 3.5
    ********************************
    BLOCK 4.2      WORK FUNCTION 4.0
    BLOCK 4.3
    BLOCK 4.4
    BLOCK 4.5
    BLOCK 4.6
    BLOCK 4.7
    ********************************
    BLOCK 5.1        PROGRAM END 5.0
    BLOCK 5.2 

___________________________________________________________________
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
                   
VAR    ' Global Variables and Cog Stack Space
  Long stack1[300],stack2[300],stack3[300],stack4[300],stack5[300],stack6[300],stack7[300]   
  Byte SemID0,SemID1,SemID2,SemID3,Random16    
  Byte CogWait1[50],CogWait2[50],CogWait3[50],CogWait4[50],CogWait5[50],CogWait6[50]
  
OBJ

    BS2[8] : "BS2_Functions_1_3_5"                  'Create 8 BS2 Objects


PUB Start | x

'********************************************************************************************
'************************************ BLOCK 0.1 *********************** PROGRAM START 0.0 ***
'************************************ BLOCK 0.1 ******************** PUB START METHOD 0.0 ***
'********************************************************************************************
 
    BS2[0].start (31,30)
    BS2[1].start (31,30)
    BS2[2].start (31,30)
    BS2[3].start (31,30)
    BS2[4].start (31,30)
    BS2[5].start (31,30)
    BS2[6].start (31,30)
    BS2[7].start (31,30)
  
'************************************ BLOCK 0.2

    SemID0 := locknew
    SemID1 := locknew
    SemID2 := locknew
    SemID3 := locknew

'************************************ BLOCK 0.3

    CogNew(Blink(17,1,9,1),@Stack1) 
    CogNew(Blink(18,2,10,2),@Stack2)
    CogNew(Blink(19,3,11,3),@Stack3)
    CogNew(Blink(20,4,12,4),@Stack4)
    CogNew(Blink(21,5,13,5),@Stack5)
    CogNew(Blink(22,6,14,6),@Stack6)
    CogNew(Blink(23,7,15,7),@Stack7)

'************************************ BLOCK 0.4  

    Random16 := 16

    repeat until not lockset(SemID1)
    repeat until not lockset(SemID2)
    repeat until not lockset(SemID3)

'************************************ BLOCK 0.5

    repeat 
 
      Blink(16,0,8,0)

'********************************************************************************************
'************************************ BLOCK 3.6 *********************** WORK FUNCTION 3.0 ***
'********************************************************************************************

      repeat until(CogWait6[17]+CogWait6[18]+CogWait6[19]+CogWait6[20]+CogWait6[21]+CogWait6[22]+CogWait6[23] == 0)

'********************************************************************************************
'************************************ BLOCK 4.1 *********************** WORK FUNCTION 4.0 ***
'********************************************************************************************

      repeat until not lockset(SemID0)
      BS2[0].Debug_Str(string(13,9,9,9,9,"WORK FUNCTION 4.0",13))  
      dira[30]~
      lockclr(SemID0)
      repeat x from 1 to 7
        CogWait4[16 + x] := 0
        BS2[0].Pause(3000)
        if CogWait2[16 + x] == 1
          BS2[0].Pause(200)
          BS2[0].Serout_Char(31,0,9600,1,8)
          dira[31]~ 
          repeat until not lockset(SemID0)
          BS2[0].Debug_Str(string("......too late I'm gone!"))
          dira[30]~
          lockclr(SemID0)
        repeat until CogWait3[16 + x] == 0

'********************************************************************************************
'************************************ BLOCK 5.2 ************************* PROGRAM END 5.0 ***
'********************************************************************************************       

      repeat until(CogWait3[17]+CogWait3[18]+CogWait3[19]+CogWait3[20]+CogWait3[21]+CogWait3[22]+CogWait3[23] == 0)
      BS2[0].Pause(2000)
      repeat until not lockset(SemID0) 
      dira[23..16]~~
      outa[23..16]~
      BS2[0].Debug_Str(string(13,13)) 
      repeat 14
        outa[23..16]~~
        BS2[0].Debug_Str(string("Yeh.....")) 
        BS2[0].Pause(100)
        outa[23..16]~
        BS2[0].Pause(100)
      BS2[0].Debug_Str(string("See Ya"))   
      dira[23..16]~
      BS2[0].Pause(4000) 
      BS2[0].Debug_Char(0)
      dira[30]~
      lockclr(SemID0)
      lockclr(SemID1)
      BS2[0].Pause(2000)
      repeat until not lockset(SemID1)
      repeat until not lockset(SemID2)
      repeat until not lockset(SemID3)
      
'********************************************************************************************
'************************************ BLOCK 6.1 ******************** PUB BLINK METHOD 6.0 ***
'********************************************************************************************

PUB Blink(LedPin, RecPin, TrnPin, Object) |  Pause, Random, z, x, myString[50]

'************************************ BLOCK 6.2

      repeat until not lockset(SemID0)
      BS2[Object].Debug_Str(string(13,13,13,13,13,13))
      BS2[Object].Debug_Char(0)
      dira[30]~    
      lockclr(SemID0)

'************************************ BLOCK 6.3

    if LedPin == 16    
      Random := Random16
    else  
      Random := LedPin

'************************************ BLOCK 6.4

    repeat

      CogWait2[LedPin] := 1
      CogWait3[LedPin] := 1
      CogWait4[LedPin] := 1
      CogWait5[LedPin] := 1
      CogWait6[LedPin] := 1

'********************************************************************************************
'************************************ BLOCK 1.1 *********************** WORK FUNCTION 1.0 ***
'********************************************************************************************

      repeat x from 1 to 4  ' called x repeat-loop

'************************************ Block 1.2

        if x == 1
          Pause := 700
          
        if x > 1
          Pause := 0

'************************************ BLOCK 1.3

        repeat z from 1 to 2  ' called z repeat-loop

'************************************ BLOCK 1.4

          if (z == 2 and LedPin == 16) or (z == 1 and LedPin > 16) 
            BS2[Object].Serin_Str(RecPin,@myString,9600,1,8) 'Discard First Message Sent
            BS2[Object].Serin_Str(RecPin,@myString,9600,1,8)

'************************************ BLOCK 1.5

            repeat until not lockset(SemID0) 
            BS2[Object].Debug_Str(string("Cog "))
            BS2[Object].Debug_Dec(cogid)
            BS2[Object].Debug_Str(string(" RecPin "))
            BS2[Object].Debug_Dec(RecPin)
            BS2[Object].Debug_Char(9)
            BS2[Object].Debug_Str(string(" received this message........"))
            BS2[Object].Debug_Str(@myString)
            dira[30]~
            lockclr(SemID0)

'************************************ BLOCK 1.6

          if (z == 1) 
            repeat until not lockset(SemID0)
            dira[LedPin]~~
            outa[LedPin]~~
            if LedPin == 16
              BS2[Object].Debug_Str(string(9,9,9,9,"WORK FUNCTION 1.0",13,13)) 
            BS2[Object].Debug_Str(string("Cog "))
            BS2[Object].Debug_Dec(cogid)
            BS2[Object].Debug_Str(string(" TrnPin "))
            BS2[Object].Debug_Dec(TrnPin)
            BS2[Object].Debug_Char(9)
            BS2[Object].Debug_Str(string(" sent this message............"))
            BS2[Object].Debug_Str(string("Cog "))
            BS2[Object].Debug_Dec(cogid)
            BS2[Object].Debug_Str(string(" TrnPin "))
            BS2[Object].Debug_Dec(TrnPin)
            BS2[Object].Debug_Str(string(" is alive and well!",13))
            BS2[Object].Pause(Pause)
            dira[LedPin]~
            BS2[Object].Pause(Pause)

'************************************ BLOCK 1.7
        
            dira[LedPin]~~
            outa[LedPin]~~
            BS2[Object].Serout_Str(TrnPin,string("Send Extra Message To Start Serin",13),9600,1,8)
            BS2[Object].Serout_Str(TrnPin,string("Cog "),9600,1,8)
            BS2[Object].Serout_Dec(TrnPin,cogid,9600,1,8)             
            BS2[Object].Serout_Str(TrnPin,string(" TrnPin "),9600,1,8)
            BS2[Object].Serout_Dec(TrnPin,TrnPin,9600,1,8)
            BS2[Object].Serout_Str(TrnPin,string(" is alive and well!",13),9600,1,8)
            BS2[Object].Pause(Pause)
            dira[LedPin]~
            BS2[Object].Pause(Pause)
            dira[30]~
            lockclr(SemID0)

'************************************ BLOCK 1.8

          if z == 1 and LedPin > 16
            quit

'************************************ BLOCK 1.9

        if LedPin == 16
          repeat until not lockset(SemID0)
          BS2[Object].Debug_Char(13)
          dira[30]~
          lockclr(SemID0)

'************************************ BLOCK 1.10

      if LedPin > 16
        repeat until not lockset(SemID2)
        lockclr(SemID2)

'************************************ BLOCK 1.11

      if LedPin == 16
        BS2[Object].Pause(2000)        

'************************************ BLOCK 1.12

        lockclr(SemID2)

'********************************************************************************************
'************************************ BLOCK 2.1 *********************** WORK FUNCTION 2.0 ***
'********************************************************************************************

      if LedPin == 16 or LedPin == 18 or LedPin == 20 or LedPin == 22

'************************************ Block 2.2

        BS2[Object].Serin_Str(RecPin,@myString,9600,1,8) 'Discard First Message Sent
        BS2[Object].Serin_Str(RecPin,@myString,9600,1,8)

'************************************ BLOCK 2.3

        if LedPin == 22
          BS2[Object].Pause(2000)

        if LedPin == 20
          BS2[Object].Pause(4000)

        if LedPin == 18
          BS2[Object].Pause(6000)

        if LedPin == 16
          BS2[Object].Pause(8000)

'************************************ BLOCK 2.4
          
        repeat until not lockset(SemID0)
        dira[LedPin]~~
        outa[LedPin]~~ 
        BS2[Object].Debug_Str(string("Cog "))
        BS2[Object].Debug_Dec(cogid)
        BS2[Object].Debug_Str(string(" RecPin "))
        BS2[Object].Debug_Dec(RecPin)
        BS2[Object].Debug_Char(9)
        BS2[Object].Debug_Str(string(" received this message........"))
        BS2[Object].Debug_Str(@myString)
        BS2[Object].Pause(700)
        dira[LedPin]~
        BS2[Object].Pause(700)
        dira[30]~
        lockclr(SemID0)

'************************************ BLOCK 2.5

      if LedPin == 17 or LedPin == 19 or LedPin == 21 or LedPin == 23

'************************************ BLOCK 2.6

        if LedPin == 21
          BS2[Object].Pause(2000)

        if LedPin == 19
          BS2[Object].Pause(4000)

        if LedPin == 17
          BS2[Object].Pause(6000)

'************************************ BLOCK 2.7

        repeat until not lockset(SemID0)
        dira[LedPin]~~
        outa[LedPin]~~
        if LedPin == 23
          BS2[Object].Debug_Str(string(9,9,9,9,"WORK FUNCTION 2.0",13,13))         
        BS2[Object].Debug_Str(string("Cog "))
        BS2[Object].Debug_Dec(cogid)
        BS2[Object].Debug_Str(string(" TrnPin "))
        BS2[Object].Debug_Dec(TrnPin)
        BS2[Object].Debug_Char(9)
        BS2[Object].Debug_Str(string(" is going to send this message............"))
        BS2[Object].Debug_Str(string("Cog "))
        BS2[Object].Debug_Dec(cogid)
        BS2[Object].Debug_Str(string(" TrnPin "))
        BS2[Object].Debug_Dec(TrnPin)
        BS2[Object].Debug_Str(string(" is alive and well!",13))
        BS2[Object].Pause(700)
        dira[LedPin]~
        BS2[Object].Pause(700)
        dira[30]~
        lockclr(SemID0)

'************************************ BLOCK 2.8

        if LedPin == 17
          BS2[Object].Pause(2000)
          repeat until not lockset(SemID0)
          BS2[Object].Debug_Char(13)
          dira[30]~
          lockclr(SemID0)

'************************************ BLOCK 2.9

        CogWait5[LedPin] := 0
        repeat until CogWait5[17]+CogWait5[19]+CogWait5[21]+CogWait5[23] == 0

'************************************ BLOCK 2.10

        dira[LedPin]~~
        outa[LedPin]~~
        BS2[Object].Serout_Str(TrnPin,string("Send Extra Message to Start Serin",13),9600,1,8)
        BS2[Object].Serout_Str(TrnPin,string("Cog "),9600,1,8)
        BS2[Object].Serout_Dec(TrnPin,cogid,9600,1,8)             
        BS2[Object].Serout_Str(TrnPin,string(" TrnPin "),9600,1,8)
        BS2[Object].Serout_Dec(TrnPin,TrnPin,9600,1,8)
        BS2[Object].Serout_Str(TrnPin,string(" is alive and well!",13),9600,1,8)

'************************************ BLOCK 2.11

        if LedPin == 17
          repeat until not lockset(SemID0)
          BS2[Object].Debug_Str(string("  Cog 1  Cog 3  Cog 5  Cog 7  sends message now !!!",13,13))
          dira[30]~
          lockclr(SemID0)
          
        BS2[Object].Pause(1000)
        dira[LedPin]~ 
        BS2[Object].Pause(1000)

'************************************ BLOCK 2.12

      ifnot LedPin == 16
        repeat until not lockset(SemID3)
        lockclr(SemID3)

'************************************ BLOCK 2.13

      if LedPin == 16
        BS2[Object].Pause(2000)
        repeat until not lockset(SemID0)
        BS2[Object].Debug_Char(13)
        BS2[Object].Debug_Str(string(9,9,9,9,"WORK FUNCTION 3.0",13,13))  
        dira[30]~
        lockclr(SemID0)

'************************************ BLOCK 2.14

        lockclr(SemID3)

'********************************************************************************************
'************************************ BLOCK 3.1 *********************** WORK FUNCTION 3.0 ***
'********************************************************************************************

      Pause := ||((?Random // 10) * 100) + 100

'************************************ BLOCK 3.2

      repeat until not lockset(SemID0)
      BS2[Object].Debug_Str(string("Cog "))
      BS2[Object].Debug_Dec(cogid)
      BS2[Object].Debug_Str(string(" LedPin "))
      BS2[Object].Debug_Dec(LedPin)
      BS2[Object].Debug_Str(string(" "))
      BS2[Object].Debug_Str(string(" ||((?Random // 10) * 100) + 100 = "))
      BS2[Object].Debug_Dec(Pause)
      BS2[Object].Debug_Str(string(" ms")) 
      BS2[Object].Debug_Char(9)
      BS2[Object].Debug_Char(3)  ' move cursor one character to left
      BS2[Object].Debug_Char(3)
      BS2[Object].Debug_Char(3)
      BS2[Object].Debug_Char(3)
      BS2[Object].Debug_Char(3)
      BS2[Object].Debug_Str(string("blink rate"))
      BS2[Object].Debug_Char(9) 
      BS2[Object].Debug_Str(string("Random = "))
      BS2[Object].Debug_Dec(Random)  
      BS2[Object].Debug_Str(string(13))
      dira[30]~  
      lockclr(SemID0)

'************************************ BLOCK 3.3

      dira[LedPin]~~
      repeat 10
        outa[LedPin]~~
        BS2[Object].Pause(Pause)
        outa[LedPin]~
        BS2[Object].Pause(Pause)
      dira[LedPin]~

'************************************ BLOCK 3.4

      if LedPin == 16
        Random16 := Random
        quit

'************************************ BLOCK 3.5

      CogWait6[LedPin] := 0

'********************************************************************************************
'************************************ BLOCK 4.2 *********************** WORK FUNCTION 4.0 ***
'********************************************************************************************

      repeat until CogWait4[LedPin] == 0

'************************************ BLOCK 4.3
 
      repeat until not lockset(SemID0)
      BS2[Object].Debug_Str(string(13,"Enter Cog "))
      BS2[Object].Debug_Dec(cogid)
      BS2[Object].Debug_Str(string(" blink rate 1 to 9 in 3 secs or blink rate of 1 will default: "))
      dira[30]~
      lockclr(SemID0)

'************************************ BLOCK 4.4

      Pause := BS2[Object].DebugIn_Char

'************************************ BLOCK 4.5

      if Pause > 48 and Pause < 58
        CogWait2[LedPin] := 0
        repeat until not lockset(SemID0)
        BS2[Object].Debug_Char(" ") 'Send Extra Character To Start Debug 
        BS2[Object].Debug_Char(9) 'Send Tab For Positioning 
        BS2[Object].Debug_Char(Pause)
        dira[30]~
        lockclr(SemID0)

      if Pause <> 0 and Pause > 57
        Pause := 49
        CogWait2[LedPin] := 0
        repeat until not lockset(SemID0)
        BS2[Object].Debug_Char(" ") 'Send Extra Character To Start Debug 
        BS2[Object].Debug_Char(9) 'Send Tab For Positioning  
        BS2[Object].Debug_Char(Pause)
        dira[30]~
        lockclr(SemID0)

      if Pause <> 0 and Pause < 49
        Pause := 49
        CogWait2[LedPin] := 0
        repeat until not lockset(SemID0)
        BS2[Object].Debug_Char(" ") 'Send Extra Character To Start Debug
        BS2[Object].Debug_Char(9) 'Send Tab For Positioning 
        BS2[Object].Debug_Char(Pause)
        dira[30]~
        lockclr(SemID0)

'************************************ BLOCK 4.6

      if Pause == 0
        Pause := 49

'************************************ BLOCK 4.7
            
      dira[LedPin]~~
      repeat 10
        outa[LedPin]~~
        BS2[Object].Pause((Pause - 48) * 100)
        outa[LedPin]~
        BS2[Object].Pause((Pause - 48) * 100)
      dira[LedPin]~

'********************************************************************************************
'************************************ BLOCK 5.1 *********************** PROGRAM END 5.0 *****
'********************************************************************************************

      CogWait3[LedPin] := 0
      repeat until not lockset(SemID1)
      lockclr(SemID1)
                             