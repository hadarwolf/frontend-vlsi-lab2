
`timescale 1ns/1ns
module alu_tb() ;

logic [7:0] a;
logic [7:0] b;
logic [3:0] op;
logic [7:0] result;

//DUT
alu DUT(
	.a(a),
	.b(b),
	.op(op),
	.result(result)
);

//Driver
function automatic void randomize_inputs();
	a = $urandom();
	b = $urandom();
	op = $urandom();
endfunction

task automatic drive_inputs();
	randomize_inputs();
	#1ns;
endtask

// Initial block to run the simulation
initial begin
        // Initialize inputs
        {a, b, op} = 0;
        #10ns;
        
        // Run 50 test cases
        repeat(50) begin
            drive_inputs();
        end
        
        $finish; // End simulation
end


//Golden
function automatic logic[7:0] golden_model ( logic [7:0] a, logic [7:0] b, logic [3:0] op );
	case (op)
            4'b0001: golden_model = (a & b);    // Case 0
            4'b0010: golden_model = (a | b);    // Case 1
            4'b0011: golden_model = (a || b);    // Case 2
            4'b1001: golden_model = ~a +1;    // Case 3
	    4'b1011: golden_model = a >> 1; // check if fill with 0 or 1 and check if << or >> shift from right or from left
	    4'b1100: golden_model = {1'b0, a[7:1]};
	    4'b1101: golden_model = {b[6:0], b[7]};
            default: golden_model = 8'o0; // Default case (optional)
        endcase
endfunction

// Checker - Compares actual result with expected result [cite: 15]
    function automatic void check_alu(
        input logic [7:0] a_val, 
        input logic [7:0] b_val, 
        input logic [3:0] op_val, 
        input logic [7:0] dut_result
    );
        logic [7:0] exp_result;
        
        // Calculate expected result using the golden model
        exp_result = golden_model(a_val, b_val, op_val);
        
        // Check for mismatch
        if (dut_result !== exp_result) begin
            $error("Checker Failed: A: %d, B: %d, OP: %b (Actual: %d, Expected: %d)", 
                   $signed(a_val), $signed(b_val), op_val, $signed(dut_result), $signed(exp_result));// Use $error for alert 
        end else begin
            $display("Checker Passed: A: %d, B: %d, OP: %b (Result: %d)", 
                     $signed(a_val), $signed(b_val), op_val, $signed(dut_result));
        end
    endfunction

//Monitor
initial begin
        forever begin
            // Wait for a change on any of the interface signals
            @(a or b or op or result);
            
            // Wait a small amount of time (zero-time) to ensure the DUT output 'result' has settled
            #0; 
            
            // Call the checker with the settled values
            check_alu(a, b, op, result);
        end
    end

endmodule

