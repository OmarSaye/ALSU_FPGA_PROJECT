module ALSU (A,
             B,
             opcode,
             cin,
             serial_in,
             direction,
             red_op_A,
             red_op_B,
             bypass_A,
             bypass_B,
             clk,
             rst,
             out,
             leds,
             anode,
             cathode);
    
    input [2:0] A, B, opcode;
    input cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst;
    output reg [5:0] out;
    output reg [15:0] leds;
    output reg [3:0] anode;
    output reg [6:0] cathode;
    reg [1:0] segement_counter;

    //this counter will start counting when invalid input entered to blink leds
    parameter MAX_COUNT = 15;
    reg [15:0]invalid_counter;
    parameter INPUT_PRIORITY = "A";
    parameter FULL_ADDER     = "ON";
    
    parameter AND            = 3'b000;
    parameter XOR            = 3'b001;
    parameter ADDITION       = 3'b010;
    parameter MULTIPLICATION = 3'b011;
    parameter SHIFT_OUTPUT   = 3'b100;
    parameter ROTATE_OUTPUT  = 3'b101;
    parameter INVALID_1      = 3'b110;
    parameter INVALID_2      = 3'b111;
    parameter SHIFT_LIFT     = 1;
    parameter SHIFT_RIGTH    = 0;
    
    reg [2:0]A_reg,B_reg,opcode_reg;
    reg  cin_reg, serial_in_reg, direction_reg, red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg;
    always @(posedge clk,posedge rst) begin
        if (rst) begin
            out  <= 0;
            leds <= 0;
            invalid_counter<=~0;
            end 
        else if (invalid_counter != MAX_COUNT)begin
            if (invalid_counter[15])
                leds <= ~0;
            else begin
                leds          <= 0;
            end
            invalid_counter <= invalid_counter+1;

        end
        else begin
            leds<=0;

            if (opcode_reg == INVALID_1 || opcode_reg == INVALID_2 || ((red_op_A_reg || red_op_B_reg) && !(opcode_reg == AND || opcode_reg == XOR)))begin
                invalid_counter <= 0;
            end

            else begin
                
                if (bypass_A_reg || bypass_B_reg) begin
                    if ((INPUT_PRIORITY == "A"&&bypass_A_reg) || (!bypass_B_reg&&bypass_A_reg)) begin
                        out <= A_reg;
                        end
                    else if ((INPUT_PRIORITY == "B"&&bypass_B_reg) || (bypass_B_reg&&!bypass_A_reg)) begin
                        out <= B_reg;
                        end
                        end
                    else begin
                        case (opcode_reg)
                            AND:begin
                                if ((INPUT_PRIORITY == "A"&&red_op_A_reg) || (!red_op_B_reg&&red_op_A_reg)) begin
                                    out <= &A_reg;
                                end
                                else if ((INPUT_PRIORITY == "B"&&red_op_B_reg) || (red_op_B_reg&&!red_op_A_reg))  begin
                                    out <= &B_reg;
                                end
                                else begin
                                    out <= A_reg&B_reg;
                                end
                            end
                            XOR:begin
                                if ((INPUT_PRIORITY == "A"&&red_op_A_reg) || (!red_op_B_reg&&red_op_A_reg)) begin
                                    out <= ^A_reg;
                                end
                                else if ((INPUT_PRIORITY == "B"&&red_op_B_reg) || (red_op_B_reg&&!red_op_A_reg))  begin
                                    out <= ^B_reg;
                                end
                                else begin
                                    out <= A_reg^B_reg;
                                end
                            end
                            ADDITION:begin
                                if (FULL_ADDER == "ON") begin
                                    out <= cin_reg+A_reg+B_reg;
                                end
                                else begin
                                    out <= A_reg+B_reg;
                                end
                            end
                            MULTIPLICATION:begin
                                out <= A_reg*B_reg;
                            end
                            SHIFT_OUTPUT:begin
                                if (INPUT_PRIORITY == "A") begin
                                    if (direction == SHIFT_LIFT) begin
                                        out <= {A_reg[1:0],serial_in_reg};
                                    end
                                    else begin
                                        out <= {serial_in_reg,A_reg[2:1]};
                                    end
                                end
                                else if (INPUT_PRIORITY == "B") begin
                                    if (direction == SHIFT_LIFT) begin
                                        out <= {B_reg[1:0],serial_in_reg};
                                    end
                                    else begin
                                        out <= {serial_in_reg,B_reg[2:1]};
                                    end
                                end
                            end
                            ROTATE_OUTPUT:begin
                                if (INPUT_PRIORITY == "A") begin
                                    if (direction == SHIFT_LIFT) begin
                                        out <= {A_reg[1:0],A_reg[2]};
                                    end
                                    else begin
                                        out <= {A_reg[0],A_reg[2:1]};
                                    end
                                end
                                else if (INPUT_PRIORITY == "B") begin
                                    if (direction == SHIFT_LIFT) begin
                                        out <= {B_reg[1:0],B_reg[2]};
                                    end
                                    else begin
                                        out <= {B_reg[0],B_reg[2:1]};
                                    end
                                end
                            end
                        endcase
                    end
                end
            end
            A_reg         <= A;
            B_reg         <= B;
            opcode_reg    <= opcode;
            cin_reg       <= cin;
            serial_in_reg <= serial_in;
            red_op_A_reg  <= red_op_A;
            red_op_B_reg  <= red_op_B;
            bypass_A_reg  <= bypass_A;
            bypass_B_reg  <= bypass_B;
        end

        always @(posedge clk or posedge rst) begin
            if (rst) begin
                if(segement_counter==0)begin
                    anode<=4'b0001;
                    cathode[6:0]<=~7'b1;
                end
                else if (segement_counter==1) begin
                    anode<=4'b0010;
                    cathode[6:0]<=~7'b1;
                end
                else if (segement_counter==2) begin
                    anode<=4'b0100;
                    cathode[6:0]<=7'b1;
                end
                else if (segement_counter==3) begin
                    anode<=4'b1000;
                    cathode[6:0]<=7'b1;
                end
                

            end
            else if(invalid_counter != MAX_COUNT)begin
                if(segement_counter==0)begin
                    anode<=4'b0001;
                    cathode<=7'b0110011;
                end
                else if (segement_counter==1) begin
                    anode<=4'b0010;
                    cathode[6:0]<=~7'b1;
                end
                else if (segement_counter==2) begin
                    anode<=4'b0100;
                    cathode<=7'b0110011;
                end
                else if (segement_counter==3) begin
                    anode<=4'b1000;
                    cathode[6:0]<=7'b1001111;
                end
            end
            else begin
                if(segement_counter==0)begin
                    anode<=4'b0001;
                case (out[3:0])
                    0: cathode[6:0]<=~7'b1;
                    1: cathode<=7'b0110000;
                    2: cathode<=7'b1101101;
                    3: cathode<=7'b1111001;
                    4: cathode<=7'b0110011;
                    5: cathode<=7'b1011011;
                    6: cathode<=7'b1011111;
                    7: cathode<=7'b1110000;
                    8: cathode<=7'b1111111;
                    9: cathode<=7'b1111011;
                    10: cathode<=7'b1110111;
                    11: cathode<=7'b0011111;
                    12: cathode<=7'b1001110;
                    13: cathode<=7'b0111101;
                    14: cathode<=7'b1001111;
                    15: cathode<=7'b1000111;
                endcase
                end
                else if(segement_counter==1)begin
                    anode<=4'b0010;
                case (out[5:4])
                    0: cathode[6:0]<=~7'b1;
                    1: cathode<=7'b0110000;
                    2: cathode<=7'b1101101;
                    3: cathode<=7'b1111001;
                endcase
                end
            end
            segement_counter<=segement_counter+1;
        end
        endmodule
