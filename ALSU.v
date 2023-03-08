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
             leds);
    
    input [2:0] A, B, opcode;
    input cin, serial_in, direction, red_op_A, red_op_B, bypass_A, bypass_B, clk, rst;
    output reg [5:0] out;
    output reg [15:0] leds;
    //this counter will start counting when invalid input entered to blink leds
    parameter COUNTER_SIZE = 4;
    reg [COUNTER_SIZE-1:0]blink_counter;
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
            blink_counter<=~0;
            end 
        else if (blink_counter != 'hf)begin
            if (blink_counter[COUNTER_SIZE-1])
                leds <= ~0;
            else begin
                leds          <= 0;
            end
            blink_counter <= blink_counter+1;
        end
        else begin
            leds<=0;

            A_reg         <= A;
            B_reg         <= B;
            opcode_reg    <= opcode;
            cin_reg       <= cin;
            serial_in_reg <= serial_in;
            red_op_A_reg  <= red_op_A;
            red_op_B_reg  <= red_op_B;
            bypass_A_reg  <= bypass_A;
            bypass_B_reg  <= bypass_B;
            if (opcode_reg == INVALID_1 || opcode_reg == INVALID_2 || ((red_op_A_reg || red_op_B_reg) && !(opcode_reg == AND || opcode_reg == XOR)))begin
                blink_counter <= 0;
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
        end
        endmodule
