module alu (
input logic [7:0] a,
input logic [7:0] b,
input logic [3:0] op,
output logic [7:0] result
) ;


// Combinational logic using always_comb
    always_comb begin
        case (op)
            4'b0001: result = (a & b);    // Case 0
            4'b0010: result = (a | b);    // Case 1
            4'b0011: result = (a || b);    // Case 2
            4'b1001: result = -a;    // Case 3
	    4'b1011: result = a >> 1; // check if fill with 0 or 1 and check if << or >> shift from right or from left
	    4'b1100: result = {1'b0, a[7:1]};
	    4'b1101: result = {b[6:0], b[7]};
            default: result = 8'o0; // Default case (optional)
        endcase
    end

endmodule 
