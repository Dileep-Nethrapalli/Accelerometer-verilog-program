`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////
// Company:  RUAS
// Engineer: Dileep Nethrapalli
// 
// Create Date: 26.09.2021 15:00:05
// Design Name: 
// Module Name: clock_divider_100MHz_to_1Hz
// Project Name: 
// Target Devices: Device Independent 
// Tool Versions: 
// Description: 
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module clock_divider_100MHz_to_1Hz(
          output reg Clock_1Hz,    
          input  Enable, Clock_100MHz, Clear_n);
     
// Generate a clock of period one second
  // 1s clock = 0.5s on + 0.5s off
  // 10 ns(100 MHz) = 1; 0.5s = x; x = 5,00,00,000
  //4,99,99,999 = 10_1111_1010_1111_0000_0111_1111b  

    reg [25:0] count_50000000;   
            
    always@(posedge Clock_100MHz, negedge Clear_n)
      if(!Clear_n)
        begin
          count_50000000 <= 0;
          Clock_1Hz <= 0;
        end         
      else if(count_50000000 == 49999999)
         begin
          count_50000000 <= 0;
          Clock_1Hz <= ~Clock_1Hz;                                
         end           
      else if(Enable)
         count_50000000 <= count_50000000 + 1; 
      else
         count_50000000 <= 0; 
              
endmodule

