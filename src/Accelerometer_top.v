`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:  RUAS
// Engineer: Dileep Nethrapalli
// 
// Create Date: 09/09/2020 11:47:50 AM
// Design Name: 
// Module Name: Mouse_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Accelerometer_top(
         output AN7, AN6, AN5, AN4, AN3, AN2, AN1, AN0,
         output CA, CB, CC, CD, CE, CF, CG, DP,       
         output INT1_out, INT2_out,
         output MOSI, CS, SCLK,
         input  MISO, INT1, INT2,        
         input z_axis_data, Clock_100MHz, Reset_n);
  
   wire clock_1Hz; 
   wire [31:0] sensor_out;   
   
   assign INT1_out = INT1; 
   assign INT2_out = INT2;    
              
Accelerometer acc_DUT(   
   .MOSI(MOSI), .CS(CS), .SCLK(SCLK), .MISO(MISO),
   .Clock_100MHz(Clock_100MHz), 
   .Clock_1Hz(clock_1Hz), .Reset_n(Reset_n), 
   .accelerometer_out(sensor_out), .z_axis_data(z_axis_data));     
  
   
BCH_to_7_segment_LED_Decoder bch_to_7_seg_LED_DUT(
   .DP(DP),
   .Cathodes({CA,CB,CC,CD,CE,CF,CG}), 
   .Anodes({AN7,AN6,AN5,AN4,AN3,AN2,AN1,AN0}),                  
   .Clock_100MHz(Clock_100MHz), .Enable(1'b1),
   .Clear_n(Reset_n), .In(sensor_out));

  
clock_divider_100MHz_to_1Hz clk_div_100MHz_to_1Hz_DUT (
     .Clock_1Hz(clock_1Hz), .Enable(1'b1), 
     .Clock_100MHz(Clock_100MHz), .Clear_n(Reset_n));
                                               
endmodule
