{{
  Prop Bus, Bus Controller
  File: PropBusBC.spin
  Version: 3.0
  Copyright (c) 2014 Mike Christle

  The purpose of the Prop Bus is to provide a communications link
  between two or more Propeller chips. This interface is very 
  loosely based on the MIL-STD-1553 interface. One chip becomes the
  Bus Controller (BC) and all others are Remote Terminals (RT).
  The interface uses a 1, 2 or 3 wire interface to support a variety
  of external drivers. The data is transferred using Manchester 
  encoding. All data consist of 16 bit words.

  One chip is assigned to be the BC and uses the object PropBusBC.
  All other chips are RTs and use the object PropBusRT. The object
  PropBusRT_RC supports an RT running is RCFast clock mode.

  First the user defines a set of data buffers. The BC will 
  periodically send out a command for each buffer. Then the owner 
  of that buffer transmits the buffer, and any device that needs 
  that data will receive that buffer. This repeats at a user 
  specified cycle frequency. The cycle frequency can be controlled
  by the BC automatically, or the user can control the cycle rate
  using the SendCommand method. Optionally, the last word in a
  buffer can be automatically incremented each time it is tranmitted.

Constants

  The constant MAX_BUFFER_COUNT determines the maximum number
  of buffers that each device can support. Each buffer requires
  a long word to store a buffer descriptor. The default is 10 and
  the maximum is 255.

Hardware Interface

  This interface uses three IO pins, Transmit (TX), Receive (RX) and
  Output Enable (OE). The OE signal goes HI when a word is tranmitted and 
  is used to enable an external driver. Using -1 for the pin number 
  disables the OE signal, this supports a two wire interface. The TX pin 
  only drives when a word is transmitted, it is tri-stated otherwise. 

  If the propeller chips are on the same PCB, or very close together, 
  the bus can be used in one wire mode by specifing the same IO pin for 
  both TX and RX. The driver only gets turned on when a word is being 
  transmitted, the protocol insures that only one chip will transmit a 
  time. There should always be a pull-up resistor on the transmit line 
  to insure that an idle bus stays in a logic HI state. I prefer to 
  daisy chain each chip with a single wire, with a 100K ohm pull-up 
  resistor on each end of the wire.

  The file TestCircuits.pdf is a schematic of the circuits that I used
  to test with. 

Bit Rate

  The Bit Rate in Bits Per Second specifies the data rate. The maximum 
  bit rate can be calculated by taking the lowest clock rate in the system
  and dividing by 80. If the minimum clock rate is 80MHz then the minimum
  bit rate is 80M / 80 = 1M BPS. For a Propeller running in RCFast mode
  the minimum clock rate is 8MHz which gives a bit rate of 100K BPS.

Cycle Frequency

  The Cycle Frequency specifies how often the BC will send out commands.
  The period must be long enough to allow all data to be transmitted 
  without causing a cycle overrun. All timing on the bus is related to
  the bit time, which is the time to transmit one bit on the bus, or the
  recipical of the bit rate. To calculate the minimum period needed to
  tranmit all data buffers use this formula:

  DW = Total Number of Data Words
  NB = Number of Buffers
  (DW + NB) X 32 X 2 X Bit Time

  The X2 factor makes the bus 50% loaded. This allows room to add data as
  the project develops without changing the cycle frequency.
}}

CON

    MAX_BUFFER_COUNT = 10
    #0, RECEIVE_BUFFER, TRANSMIT_BUFFER, TRAN_INCR_BUFFER

VAR

    byte Cog, BDCount
    word Command
    long BDBuffer[MAX_BUFFER_COUNT]

PUB Start(TXPin, RXPin, OEPin, Freq, BCount)
{{
  Starts the BC and starts cycling. This should be delayed until
  all the RTs have had time to setup their buffers.

  TXPin:  The port number of the Transmit pin.

  RXPin:  The port number of the Receive pin.

  OEPin:  The port number of the Output Enable pin.
          Set to -1 if not used.

  Freq:   The frequency that buffers will be transfered.
          A 20Hz frequency will transfer buffers every 50 mSec.
          To calculate the max frequency:
          Total number of words times 20 uSec plus
          total number of buffers times 50 uSec.
          Then multiply by two to insure bus is not more 
          than 50% loaded.

  BCount: The number of buffers that the BC will automatically 
          command to be transfered at the cycle rate. If this is
          set to zero then no buffers will be transferred
          automatically so the user can control buffer timing using
          the SendCommand method. If BCount is zero Freq should be 
          set to 10Hz.
}}
    Stop

    cycle_time := clkfreq / Freq
    bit_time := clkfreq / bit_rate

    tx_pin := 1 << TXPin
    rx_pin := 1 << RXPin
    if OEPin => 0
        oe_pin := 1 << OEPin

    buffer_ptr := @BDBuffer
    count_ptr := @BDCount
    command_ptr := @Command
    Command := 0
    message_count := BCount

    Cog := cognew(@bc_loop, 0) + 1

PUB Stop
{{
  Will stop and reset the BC.
}}
    if Cog > 0
        cogstop(Cog - 1)
    Cog := 0

PUB SetBitRate(BitRate)
{{
  Sets the bit rate for the bus. Must be called before
  calling Start. All devices on the bus must have the
  same bit rate. Default is 1 MBit.

  BitRate:  Bit Rate in bits per second
}}

    bit_rate := BitRate

PUB AddBuffer(Number, Adrs, Count, Send) | T
{{
  Defines the buffers that this chip is sending or recieving.
  This should be called before the BC starts cycling.

  Number: The buffer number. Each buffer in the system must have
          a unique buffer number from 1 to 255. Buffer numbers
          should be consecutive starting at 1. If they are not the
          bus will still work, but you are wasting bandwidth.

  Adrs:   The local address of the start of the buffer.

  Count:  The number of 16 bit words in the buffer. Range 1 to 63.

  Send:   RECEIVE_BUFFER   = This chip receives this buffer.
          TRANSMIT_BUFFER  = This chip own and sends this buffer.
          TRAN_INCR_BUFFER = This chip own and sends this buffer, 
                             and the last word inthe buffer is 
                             incremented every time the buffer is 
                             transmitted.
}}
    if BDCount == MAX_BUFFER_COUNT
        return 1

    T := Adrs | (Count << 16) | (Number << 24)
    if Send <> RECEIVE_BUFFER
        T := T | $8000_0000
    if Send == TRAN_INCR_BUFFER
        T := T | $0080_0000
    BDBuffer[BDCount] := T
    BDCount++
    return 0

PUB SendCommand(C)
{{
  Send an asyncronous command. 
  When the bus is idle the command will get to the RT within 50uSec.
  If the bus is busy, the command will wait for the buffer to complete.
  If a buffer number is sent, this will cause that beffer to be
  transferred. Values greater than 255 are user defined.
}}
    Command := C

    repeat while Command <> 0

DAT
                        org     0
'PROPC
'//--------------------------------------------------------------
'
'int  cycle_time = 0;    // Message cycle time in clocks
'uint message_count = 0; // Number of messages for BC
'
'//--------------------------------------------------------------
'// Bus Controller loop
'//--------------------------------------------------------------
'void bc_loop()
bc_loop

'{
'    uint i, c;
'    int cntr;
'
'    // Setup bit timing
'    half_bit_time = bit_time >> 1;
                        MOV     half_bit_time, bit_time  
                        SHR     half_bit_time, #1  

'    rcvr_bit_time = (half_bit_time >> 2) + half_bit_time;
                        MOV     rcvr_bit_time, half_bit_time  
                        SHR     rcvr_bit_time, #2  
                        ADD     rcvr_bit_time, half_bit_time  

'
'    // Delay for two cycle time to let RTs initialize
'    cntr = cnt + cycle_time;
                        MOV     bc_loop_cntr, cnt  
                        ADDS    bc_loop_cntr, cycle_time  

'    waitcnt(cntr, cycle_time);
                        WAITCNT bc_loop_cntr, cycle_time  

'    waitcnt(cntr, cycle_time);
                        WAITCNT bc_loop_cntr, cycle_time  

'
'    // Loop forever
'    while (true)
:L1

'    {
'        // If cycle delay has not expired
'        while (cntr - cnt > 0)
:L4
                        MOV     bc_loop__0, bc_loop_cntr  
                        SUBS    bc_loop__0, cnt  
                        CMPS    bc_loop__0, #0  WZ, WC
   IF_C_OR_Z            JMP     #:L6

'            check_async_cmnd();
                        CALL    #check_async_cmnd 
                        JMP     #:L4 
:L6

'
'        // for each message
'        for (i = 1; i <= message_count; ++i)
                        MOV     bc_loop_i, #1  
:L7
                        CMP     bc_loop_i, message_count  WZ, WC
   IF_NC_AND_NZ         JMP     #:L10

'        {
'            // Transmit the message number
'            pb_data = i;
                        MOV     pb_data, bc_loop_i  

'
'            // Transmit the command
'            send_command();
                        CALL    #send_command 

'
'            check_async_cmnd();
                        CALL    #check_async_cmnd 
                        ADD     bc_loop_i, #1  

'        }
                        JMP     #:L7 
:L10

'
'        // Reset the cycle time counter
'        cntr += cycle_time;
                        ADDS    bc_loop_cntr, cycle_time  

'    }
                        JMP     #:L1 

'}
bc_loop_RET             RET
'---------------------------------------------------------

'
'//--------------------------------------------------------------
'// 
'//--------------------------------------------------------------
'void check_async_cmnd()
check_async_cmnd

'{
'    // Check for an asyncronous command
'    pb_data = GWORD[command_ptr];
                        RDWORD  pb_data, command_ptr  

'
'    // If value is not zero
'    if (pb_data)
                        CMP     pb_data, #0  WZ
   IF_Z                 JMP     #:L12

'    {
'        // Transmit the command
'        send_command();
                        CALL    #send_command 

'
'        // Reset the command
'        GWORD[command_ptr] = 0;
                        WRWORD  CONST_0, command_ptr  

'    }
:L12

'}
check_async_cmnd_RET    RET
'---------------------------------------------------------

'
'
'//--------------------------------------------------------------
'// 
'//--------------------------------------------------------------
'void send_command()
send_command

'{
'    // Transmit the command
'    transmit();
                        CALL    #transmit 

'
'    // Check for message commands
'    if (pb_data < 256)
                        CMP     pb_data, #256  WZ, WC
   IF_NC                JMP     #:L15

'        process();
                        CALL    #process 
:L15

'
'    // Insert a one word gap between messages
'    // Wait for bus to be idle for 32 bit times
'    wait_for_idle(bit_time << 5);
                        MOV     wait_for_idle_clocks, bit_time  
                        SHL     wait_for_idle_clocks, #5  
                        CALL    #wait_for_idle 

'}
send_command_RET        RET
'---------------------------------------------------------

'
'//--------------------------------------------------------------
'
'uint buffer_ptr = 0;        // Buffer Table Pointer
'uint count_ptr = 0;         // Buffer Table size
'uint bit_time = 0;          // Bit Time in Clocks
'uint tx_pin = 0;            // TX IO Pin Number
'uint rx_pin = 0;            // RX IO Pin Number
'uint oe_pin = 0;            // OE IO Pin Number
'uint command_ptr = 0;       // Pointer to async command word
'uint bit_rate = 1_000_000;  // Bit rate, bits per second
'
'uint wait_cntr;
'uint pb_data;
'uint half_bit_time;
'uint rcvr_bit_time;
'uint receive_status;
'uint bit_counter;
'uint t0, t1;
'
'//--------------------------------------------------------------
'// Process a command
'// 
'//  Command Format
'//  Bit  7-00  8  Buffer Number
'//  Bit 15-08  8  User Defined Commands
'//
'//  Buffer Descriptor Format
'//  Bit 15-00 16  Buffer Address
'//  Bit 21-16  5  Word Count
'//  Bit 22     1  Unused
'//  Bit 23     1  Send Flag
'//  Bit 31-24  8  Buffer Number
'//
'//--------------------------------------------------------------
'void process()
process

'{
'    uint i, j, p;
'    uint address;
'    uint word_count;
'    uint buffer_entry;
'
'    pb_data <<= 24;    
                        SHL     pb_data, #24  

'    p = buffer_ptr;
                        MOV     process_p, buffer_ptr  

'
'    // For each buffer defined by this device
'    for (i = GBYTE[count_ptr])
                        RDBYTE  process_i, count_ptr  
:L17

'    {
'        // Read a buffer entry
'        buffer_entry = GLONG[p];
                        RDLONG  process_buffer_entry, process_p  

'        p += 4;
                        ADD     process_p, #4  

'
'        // If buffer number matches the command
'        if ((buffer_entry ^ pb_data) & buffer_no_mask == 0)
                        MOV     process__0, process_buffer_entry  
                        XOR     process__0, pb_data  
                        AND     process__0, buffer_no_mask  WZ
   IF_NZ                JMP     #:L20

'        {
'            // Parse out address and word count
'            address = buffer_entry & address_mask;
                        MOV     process_address, process_buffer_entry  
                        AND     process_address, address_mask  

'            word_count = buffer_entry & word_count_mask;
                        MOV     process_word_count, process_buffer_entry  
                        AND     process_word_count, word_count_mask  

'            word_count >>= 16;
                        SHR     process_word_count, #16  

'
'            // If this is a send buffer
'            if (buffer_entry & send_flag_mask)
                        TEST    process_buffer_entry, send_flag_mask  WZ
   IF_Z                 JMP     #:L23

'            {
'                // For each word in buffer
'                for (j = word_count)
                        MOV     process_j, process_word_count  
:L25

'                {
'                    // Insert 8 bit time delay between words
'                    wait_cntr = (bit_time << 3) + cnt;
                        MOV     wait_cntr, bit_time  
                        SHL     wait_cntr, #3  
                        ADD     wait_cntr, cnt  

'                    waitcnt(wait_cntr, 0);
                        WAITCNT wait_cntr, #0  

'
'                    // Get data word and check for tag
'                    pb_data = GWORD[address];
                        RDWORD  pb_data, process_address  

'                    if (buffer_entry & tag_word_mask && j == 1)
                        TEST    process_buffer_entry, tag_word_mask  WZ
   IF_Z                 JMP     #:L28
                        CMP     process_j, #1  WZ
   IF_NZ                JMP     #:L28

'                        GWORD[address] = ++pb_data;
                        ADD     pb_data, #1  
                        WRWORD  pb_data, process_address  
:L28

'                    address += 2;
                        ADD     process_address, #2  

'
'                    // Transmit the data word
'                    transmit();
                        CALL    #transmit 

'                }
                        DJNZ    process_j, #:L25  

'            }
'            // If this is a receive buffer
'            else
                        JMP     #:L18 
:L23

'            {
'                // For each word in buffer
'                for (j = word_count)
                        MOV     process_j, process_word_count  
:L30

'                {
'                    // receive and store the data word
'                    receive(bit_time << 4);
                        MOV     receive_timeout, bit_time  
                        SHL     receive_timeout, #4  
                        CALL    #receive 

'                    if (receive_status != 0) break;
                        CMP     receive_status, #0  WZ
   IF_NZ                JMP     #:L18

'                    GWORD[address] = pb_data;
                        WRWORD  pb_data, process_address  

'                    address += 2;
                        ADD     process_address, #2  

'                }
                        DJNZ    process_j, #:L30  

'            }

'            break;
                        JMP     #:L18 

'        }
:L20

'    }
                        DJNZ    process_i, #:L17  
:L18

'}
process_RET             RET
'---------------------------------------------------------

'
'//--------------------------------------------------------------
'//--------------------------------------------------------------
'void wait_for_idle(uint clocks)
wait_for_idle

'{
'    t0 = cnt;
                        MOV     t0, cnt  

'    do
:L35

'    {
'        if (rx_pin & ina == 0) t0 = cnt;
                        TEST    rx_pin, ina  WZ
   IF_NZ                JMP     #:L38
                        MOV     t0, cnt  
:L38

'        t1 = cnt - t0;
                        MOV     t1, cnt  
                        SUB     t1, t0  

'    }
'    while (t1 < clocks);
                        CMP     t1, wait_for_idle_clocks  WZ, WC
   IF_C                 JMP     #:L35

'}
wait_for_idle_RET       RET
'---------------------------------------------------------

'
'//--------------------------------------------------------------
'uint send_flag_mask  = 0x8000_0000;
'uint tag_word_mask   = 0x0080_0000;
'uint address_mask    = 0x0000_7FFE;
'uint word_count_mask = 0x007F_0000;
'uint buffer_no_mask  = 0x7F00_0000;
'//--------------------------------------------------------------
'
'//--------------------------------------------------------------
'// Transmit a 16 bit word
'//
'//     |     Start     | 15:0  | 14:1  |...|Parity |
'//  ___         _______     ___ ___         ___     ___
'//     #_______#       #___/   #   \___#...#   \___#
'//--------------------------------------------------------------
'void transmit()
transmit

'{
                        SHL     pb_data, #1
                        TESTN   pb_data, #0  WC
    IF_NC               OR      pb_data, #1
                        SHL     pb_data, #15

                        OR      outa, tx_pin
                        OR      dira, tx_pin
                        OR      dira, oe_pin
                        OR      outa, oe_pin

                        MOV     wait_cntr, cnt
                        ANDN    outa, tx_pin
                        ADD     wait_cntr, bit_time
                        WAITCNT wait_cntr, bit_time
                        OR      outa, tx_pin

                        MOV     bit_counter, #17

:TX01                   ROL     pb_data, #1  WC
    IF_C                JMP     #:TX02

                        WAITCNT wait_cntr, half_bit_time
                        ANDN    outa, tx_pin
                        WAITCNT wait_cntr, half_bit_time
                        OR      outa, tx_pin
                        JMP     #:TX03

:TX02                   WAITCNT wait_cntr, half_bit_time
                        OR      outa, tx_pin
                        WAITCNT wait_cntr, half_bit_time
                        ANDN    outa, tx_pin

:TX03                   DJNZ    bit_counter, #:TX01

                        WAITCNT wait_cntr, half_bit_time

                        SHR     pb_data, #1
                        OR      outa, tx_pin
                        ANDN    dira, tx_pin
                        ANDN    outa, oe_pin
'}
transmit_RET            RET
'---------------------------------------------------------

'//--------------------------------------------------------------
'// receive a 16 bit word
'//
'// pb_data:        Contains the data word 
'// receive_status: 0 = Success
'//                 1 = Timeout Error
'//--------------------------------------------------------------
'void receive(uint timeout)
receive

'{
                        MOV     receive_status, #1
                        MOV     pb_data, #0
                        MOV     bit_counter, #17

:RX01                   TEST    rx_pin, ina  WC
   IF_C                 DJNZ    receive_timeout, #:RX01
   IF_C                 JMP     #receive_RET

                        WAITPEQ rx_pin, rx_pin
                        MOV     wait_cntr, cnt
                        ADD     wait_cntr, rcvr_bit_time
                        ADD     wait_cntr, half_bit_time

:RX02                   SHL     pb_data, #1

                        WAITCNT wait_cntr, #0
                        TEST    rx_pin, ina  WZ
    IF_Z                JMP     #:RX04

                        OR      pb_data, #1
:RX03                   TEST    rx_pin, ina  WC
    IF_C                DJNZ    receive_timeout, #:RX03
                        MOV     wait_cntr, cnt
    IF_C                JMP     #receive_RET

                        ADD     wait_cntr, rcvr_bit_time
                        JMP     #:RX05

:RX04                   WAITPEQ rx_pin, rx_pin
                        MOV     wait_cntr, cnt
                        ADD     wait_cntr, rcvr_bit_time

:RX05                   DJNZ    bit_counter, #:RX02
                        WAITCNT wait_cntr, #0

                        TESTN   pb_data, #0  WC
    IF_C                MOV     receive_status, #0
                        SHR     pb_data, #1

'}
receive_RET             RET
'---------------------------------------------------------
tru                     LONG    1
fls                     LONG    0
math_ones               LONG    -1
math_real_mask          LONG    65535
math_half               LONG    32768
math_90                 LONG    8388608
math_180                LONG    16777216
zero                    LONG    0
cycle_time              LONG    0
message_count           LONG    0
buffer_ptr              LONG    0
count_ptr               LONG    0
bit_time                LONG    0
tx_pin                  LONG    0
rx_pin                  LONG    0
oe_pin                  LONG    0
command_ptr             LONG    0
bit_rate                LONG    1000000
send_flag_mask          LONG    -2147483648
tag_word_mask           LONG    8388608
address_mask            LONG    32766
word_count_mask         LONG    8323072
buffer_no_mask          LONG    2130706432
CONST_1                 LONG    1
CONST_2                 LONG    2
CONST_0                 LONG    0
CONST_256               LONG    256
CONST_5                 LONG    5
CONST_24                LONG    24
CONST_4                 LONG    4
CONST_16                LONG    16
CONST_3                 LONG    3
math_p1                 RES     1
math_p2                 RES     1
math_r1                 RES     1
math_r2                 RES     1
math_t                  RES     1
math_s                  RES     1
wait_cntr               RES     1
pb_data                 RES     1
half_bit_time           RES     1
rcvr_bit_time           RES     1
receive_status          RES     1
bit_counter             RES     1
t0                      RES     1
t1                      RES     1
wait_for_idle_clocks    RES     1
receive_timeout         RES     1
bc_loop_i               RES     1
bc_loop_c               RES     1
bc_loop_cntr            RES     1
bc_loop__0              RES     1
check_async_cmnd__0     RES     1
send_command__0         RES     1
process_i               RES     1
process_j               RES     1
process_p               RES     1
process_address         RES     1
process_word_count      RES     1
process_buffer_entry    RES     1
process__0              RES     1
process__1              RES     1
wait_for_idle__0        RES     1
'---------------------------------------------------------
                        fit      
{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
