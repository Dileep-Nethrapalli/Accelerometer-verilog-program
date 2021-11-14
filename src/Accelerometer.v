`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:  RUAS
// Engineer: Dileep Nethrapalli
// 
// Create Date: 11/23/2020 03:04:58 PM
// Design Name: 
// Module Name: Accelerometer
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


module Accelerometer(
         output reg [31:0] accelerometer_out,
         output reg MOSI, CS, SCLK,       
         input MISO, z_axis_data,  
         input Clock_100MHz, Clock_1Hz, Reset_n);     

  // Generate a clock of 1MHz
    // 10ns = 1; 1MHz = 1us;
    // 1us clock = 0.5us ON + 0.5us OFF
    // 10ns = 1; 0.5us = x; x = 50;
    // 49 = 11_0001b
    reg clock_1MHz;
    reg [5:0] count_50;
                                  
    always@(posedge Clock_100MHz, negedge Reset_n) 
      if(!Reset_n) 
        begin
          clock_1MHz <= 0;
          count_50 <= 0;
        end 
      else if(count_50 == 49) 
        begin
          clock_1MHz <= ~clock_1MHz;
          count_50 <= 0;
        end 
      else
         count_50 <= count_50 + 1; 
                 
           
  // Generate Instruction for FIFO
     // reg [7:0] Instruction = 8'h0D;    
     // reg [7:0] Address = 8'h00; 
     
 // Generate Address for XDATA, YDATA, ZDATA
    reg [7:0] Address; 
    always@(posedge clock_1MHz, negedge Reset_n)   
      if(!Reset_n) 
         Address <= 8'h20; // THRESH_ACT_L 
      else if((present_state == ADDR_CHANGE) && 
              (Address == 8'h2E))    
         Address <= 8'h0E; // XDATA_L
      else if((present_state == ADDR_CHANGE) && 
              (Address == 8'h14))    
         Address <= 8'h0E; 
      else if(present_state == ADDR_INCR) 
         Address <= Address + 1; 


// Generate Instruction and Data for XDATA, YDATA, ZDATA
   reg [7:0] Instruction, Data;

  always@(posedge clock_1MHz, negedge Reset_n)   
    if(!Reset_n) 
       begin 
         Instruction <= 8'h00; Data <= 8'h00; 
       end   
   // 0A = write register, 0B = read register, 0D = read FIFO;         
    else if(present_state == CS_LOW)  
      case(Address)
                 // 250mg, Activity Threshold Low Register
        8'h20: begin Instruction <= 8'h0A; Data <= 8'hFA; end 
                 // 250mg, Activity Threshold High Register
        8'h21: begin Instruction <= 8'h0A; Data <= 8'h00; end  
                 // 5sec, Activity Time Register
        8'h22: begin Instruction <= 8'h0A; Data <= 8'h1E; end  
                 // 150mg, Inactivity Threshold Low Register 
        8'h23: begin Instruction <= 8'h0A; Data <= 8'h96; end 
                 // 250mg, Inactivity Threshold High Register  
        8'h24: begin Instruction <= 8'h0A; Data <= 8'h00; end 
                 // 5sec, Inactivity Time Register Low
        8'h25: begin Instruction <= 8'h0A; Data <= 8'h1E; end 
                 // 5sec, Inactivity Time Register High
        8'h26: begin Instruction <= 8'h0A; Data <= 8'h00; end  
                // Loop mode, Activity and Inactivity Register 
        8'h27: begin Instruction <= 8'h0A; Data <= 8'h3F; end  
                 // Stream mode, FIFO Control Register 
        8'h28: begin Instruction <= 8'h0A; Data <= 8'h0A; end 
                 // 128 Samples, FIFO Samples Register  
        8'h29: begin Instruction <= 8'h0A; Data <= 8'h80; end  
        8'h2A: begin Instruction <= 8'h0A; Data <= 8'h00; end     
        8'h2B: begin Instruction <= 8'h0A; Data <= 8'h00; end  
                 // 8g and 100Hz ODR
        8'h2C: begin Instruction <= 8'h0A; Data <= 8'h83; end  
                 // 8g and 100Hz ODR
        8'h2D: begin Instruction <= 8'h0A; Data <= 8'h02; end             
        8'h0E: begin Instruction <= 8'h0B; Data <= 8'hFF; end
        8'h0F: begin Instruction <= 8'h0B; Data <= 8'hFF; end
        8'h10: begin Instruction <= 8'h0B; Data <= 8'hFF; end
        8'h11: begin Instruction <= 8'h0B; Data <= 8'hFF; end
        8'h12: begin Instruction <= 8'h0B; Data <= 8'hFF; end
        8'h13: begin Instruction <= 8'h0B; Data <= 8'hFF; end
      endcase   
                        
  
// FSM for Accelerometer              
   reg [5:0] present_state, next_state;
                
   parameter [7:0] 
     RESET = 8'd0,   CS_LOW = 8'd1,  
     INSTR_7 = 8'd2, INSTR_6 = 8'd3, INSTR_5 = 8'd4, 
     INSTR_4 = 8'd5, INSTR_3 = 8'd6, INSTR_2 = 8'd7, 
     INSTR_1 = 8'd8, INSTR_0 = 8'd9,
     ADDR_7 = 8'd10, ADDR_6 = 8'd11, ADDR_5 = 8'd12, 
     ADDR_4 = 8'd13, ADDR_3 = 8'd14, ADDR_2 = 8'd15, 
     ADDR_1 = 8'd16, ADDR_0 = 8'd17, 
                     
     DATA_7 = 8'd18,  DATA_6 = 8'd19,  DATA_5 = 8'd20,  
     DATA_4 = 8'd21,  DATA_3 = 8'd22,  DATA_2 = 8'd23,  
     DATA_1 = 8'd24,  DATA_0 = 8'd25,
     DATA_15 = 8'd26, DATA_14 = 8'd27, DATA_13 = 8'd28, 
     DATA_12 = 8'd29, DATA_11 = 8'd30, DATA_10 = 8'd31, 
     DATA_9 = 8'd32,  DATA_8 = 8'd33,                      
                     
     CS_HIGH = 8'd34, ADDR_INCR = 8'd35, 
     OUTPUT = 8'd36,  ADDR_CHANGE = 8'd37; 
            
// FSM registers
     always@(negedge clock_1MHz, negedge Reset_n)   
       if(!Reset_n) 
          present_state <= RESET;
       else
          present_state <= next_state;
                               
// FSM Combinational block 
always@(present_state, clock_1MHz, Instruction, Address, Data)
 case(present_state)                    
  RESET: begin CS = 1; SCLK = 0; MOSI = 1; 
               next_state = CS_LOW; end   
  CS_LOW: begin CS = 0; SCLK = 0; MOSI = 1; 
                next_state = INSTR_7; end
  INSTR_7: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[7]; 
             next_state = INSTR_6; end 
  INSTR_6: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[6];
             next_state = INSTR_5; end
  INSTR_5: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[5];
             next_state = INSTR_4; end
  INSTR_4: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[4];
             next_state = INSTR_3; end
  INSTR_3: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[3];
             next_state = INSTR_2; end
  INSTR_2: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[2];
             next_state = INSTR_1; end
  INSTR_1: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[1];
             next_state = INSTR_0; end
  INSTR_0: begin 
             CS = 0; SCLK = clock_1MHz; MOSI = Instruction[0];
             next_state = ADDR_7; end
         
  ADDR_7: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[7];
                next_state = ADDR_6; end
  ADDR_6: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[6];
                next_state = ADDR_5; end 
  ADDR_5: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[5];
                next_state = ADDR_4; end
  ADDR_4: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[4];
                next_state = ADDR_3; end 
  ADDR_3: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[3];
                next_state = ADDR_2; end
  ADDR_2: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[2];
                next_state = ADDR_1; end 
  ADDR_1: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[1];
                next_state = ADDR_0; end
  ADDR_0: begin CS = 0; SCLK = clock_1MHz; MOSI = Address[0];
                next_state = DATA_7; end 
         
  DATA_7: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[7];
                next_state = DATA_6; end
  DATA_6: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[6];
                next_state = DATA_5; end 
  DATA_5: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[5];
                next_state = DATA_4; end
  DATA_4: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[4];
                next_state = DATA_3; end 
  DATA_3: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[3];
                next_state = DATA_2; end
  DATA_2: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[2]; 
                next_state = DATA_1; end 
  DATA_1: begin CS = 0; SCLK = clock_1MHz; MOSI = Data[1]; 
                next_state = DATA_0; end
  DATA_0: begin 
            CS = 0; SCLK = clock_1MHz; MOSI = Data[0]; 
            if((Address == 8'h0E) || (Address == 8'h0F) ||
               (Address == 8'h10) || (Address == 8'h11) || 
               (Address == 8'h12) || (Address == 8'h13))
              next_state = DATA_15; 
            else 
              next_state = CS_HIGH; end                                    
  DATA_15: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_14; end
  DATA_14: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_13; end 
  DATA_13: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_12; end
  DATA_12: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_11; end 
  DATA_11: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_10; end
  DATA_10: begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_9; end 
  DATA_9:  begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = DATA_8; end
  DATA_8:  begin CS = 0; SCLK = clock_1MHz; MOSI = 1;
                 next_state = CS_HIGH; end              
         
  CS_HIGH: begin CS = 1; SCLK = 0; MOSI = 1; 
                 next_state = ADDR_INCR; end 
  ADDR_INCR: begin CS = 1; SCLK = 0; MOSI = 1; 
                   next_state = ADDR_CHANGE; end
  ADDR_CHANGE: begin CS = 1; SCLK = 0; MOSI = 1; 
                     next_state = CS_LOW; end
                    
  default: begin CS = 1; SCLK = 0; MOSI = 1; 
                 next_state = RESET; end  
 endcase
  
       
// Capture Data generated by Accelerometer(i.e MISO)  
   reg [11:0] sensor_data;

   always@(posedge clock_1MHz, negedge Reset_n)  
     if(!Reset_n) 
        sensor_data <= {12{1'b0}};
     else 
       case(present_state) 
         DATA_11: sensor_data[11] <= MISO;
         DATA_10: sensor_data[10] <= MISO;
         DATA_9:  sensor_data[9]  <= MISO;
         DATA_8:  sensor_data[8]  <= MISO;           
         DATA_7:  sensor_data[7]  <= MISO;
         DATA_6:  sensor_data[6]  <= MISO;
         DATA_5:  sensor_data[5]  <= MISO;
         DATA_4:  sensor_data[4]  <= MISO;                                    
         DATA_3:  sensor_data[3]  <= MISO;
         DATA_2:  sensor_data[2]  <= MISO;
         DATA_1:  sensor_data[1]  <= MISO;
         DATA_0:  sensor_data[0]  <= MISO; 
       endcase  
 
 
// Generate X-AXIS, Y-AXIS and Z-AXIS Data
   reg [11:0] X_axis_data, Y_axis_data, Z_axis_data;

   always@(posedge clock_1MHz, negedge Reset_n)  
     if(!Reset_n) 
        begin
          X_axis_data <= {12{1'b0}};
          Y_axis_data <= {12{1'b0}};
          Z_axis_data <= {12{1'b0}};
        end  
     else if(present_state == CS_HIGH)        
          if(Address == 8'h0F)
             X_axis_data <= sensor_data;                
          else if(Address == 8'h11)
             Y_axis_data <= sensor_data;
          else if(Address == 8'h13)
             Z_axis_data <= sensor_data;
 
     
// Assign sensor data to output   
always@(posedge Clock_1Hz, negedge Reset_n) 
 if(!Reset_n) 
   accelerometer_out <= {32{1'b0}};
 else if(z_axis_data)
   accelerometer_out <= {{24{1'b0}}, Z_axis_data};
 else
  accelerometer_out <= {4'h0, Y_axis_data, 4'h0, X_axis_data}; 
                                                               
endmodule
