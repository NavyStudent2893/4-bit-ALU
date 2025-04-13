`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 17:39:54
// Design Name: 
// Module Name: ALSU
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


module FA(
  input a,
  input b,
  input cin,
  output sum,
  output cout
);

    wire w1,w2,w3;
    
    xor(w1,a,b);
    and(w2,a,b);
    xor(sum,cin,w1);
    and(w3,w1,cin);
    or(cout,w3,w2);
    
    
    
endmodule

module ripple_carry_adder_4bit (
  input [3:0] A, B,
  input Cin,
  output [3:0] Sum,
  output Cout
);
  wire c1, c2, c3;

   FA FA0 (A[0], B[0], Cin,  Sum[0], c1);
   FA FA1 (A[1], B[1], c1,   Sum[1], c2);
   FA FA2 (A[2], B[2], c2,   Sum[2], c3);
   FA FA3 (A[3], B[3], c3,   Sum[3], Cout);

endmodule

module subtractor_4bit (
  input  [3:0] A,
  input  [3:0] B,
  output [3:0] Diff,
  output Cout
);
  wire [3:0] B_inverted;

 
  not (B_inverted[0], B[0]);
  not (B_inverted[1], B[1]);
  not (B_inverted[2], B[2]);
  not (B_inverted[3], B[3]);

  
  ripple_carry_adder_4bit adder_inst (
    .A(A),
    .B(B_inverted),
    .Cin(1'b1),         
    .Sum(Diff),
    .Cout(Cout)
  );
endmodule

module subtractor_with_borrow (
  input [3:0] A,
  input [3:0] B,
  output [3:0] Diff,
  output Borrow
);

  wire [3:0] B_inverted;

  not (B_inverted[0], B[0]);
  not (B_inverted[1], B[1]);
  not (B_inverted[2], B[2]);
  not (B_inverted[3], B[3]);
 
  ripple_carry_adder_4bit swb (
    .A(A),
    .B(B_inverted),
    .Cin(1'b0),         
    .Sum(Diff),
    .Cout(Borrow)
  );

endmodule

module adder_with_carry (
  input [3:0] A,
  input [3:0] B,
  output [3:0] Sum,
  output Carry
);

  ripple_carry_adder_4bit adc (
    .A(A),
    .B(B),
    .Cin(1'b1),         
    .Sum(Sum),
    .Cout(Carry)
  );

endmodule


module and_4bit (
  input [3:0] A,
  input [3:0] B,
  output [3:0] Y
);

  and (Y[0], A[0], B[0]);
  and (Y[1], A[1], B[1]);
  and (Y[2], A[2], B[2]);
  and (Y[3], A[3], B[3]);

endmodule

module or_4bit (
  input [3:0] A,
  input [3:0] B,
  output [3:0] Y
);

  or (Y[0], A[0], B[0]);
  or (Y[1], A[1], B[1]);
  or (Y[2], A[2], B[2]);
  or (Y[3], A[3], B[3]);

endmodule

module xor_4bit (
  input [3:0] A,
  input [3:0] B,
  output [3:0] Y
);

  xor (Y[0], A[0], B[0]);
  xor (Y[1], A[1], B[1]);
  xor (Y[2], A[2], B[2]);
  xor (Y[3], A[3], B[3]);

endmodule
 
 module Not_4bit (
  input [3:0] A,
  output [3:0] Y
);

  not (Y[0], A[0]);
  not (Y[1], A[1]);
  not (Y[2], A[2]);
  not (Y[3], A[3]);

endmodule

module increment_4bit (
  input [3:0] A,
  output [3:0] Result,
  output CarryOut
);

  wire [3:0] one = 4'b0001;

  ripple_carry_adder_4bit incr (
    .A(A),
    .B(one),
    .Cin(1'b0),        
    .Sum(Result),
    .Cout(CarryOut)
  );

endmodule

module decrement_4bit (
  input [3:0] A,
  output [3:0] Result,
  output BorrowOut
);

  wire [3:0] one_inverted;

  
  not (one_inverted[0], 1'b1);  
  not (one_inverted[1], 1'b0);  
  not (one_inverted[2], 1'b0);  
  not (one_inverted[3], 1'b0);  

  ripple_carry_adder_4bit decr (
    .A(A),
    .B(one_inverted),
    .Cin(1'b1),          
    .Sum(Result),
    .Cout(BorrowOut)
  );

endmodule

module transfer_A_4bit (
  input [3:0] A,
  output [3:0] Y
);

  buf (Y[0], A[0]);
  buf (Y[1], A[1]);
  buf (Y[2], A[2]);
  buf (Y[3], A[3]);

endmodule

module alu_4bit (
  input [3:0] A,
  input [3:0] B,
  input [3:0] Op,
  output reg [3:0] Result,
  output reg Flag
);

  wire [3:0] sum, sum_carry, diff, diff_borrow, and_out, or_out, xor_out, not_out;
  wire [3:0] inc_out, dec_out, transf_A;
  wire c1, c2, b1, b2, c_inc, c_dec;

  // Instantiate all operation modules
  ripple_carry_adder_4bit adder     (.A(A), .B(B), .Cin(1'b0), .Sum(sum),        .Cout(c1));
  adder_with_carry        adc       (.A(A), .B(B),            .Sum(sum_carry),   .Carry(c2));
  subtractor_4bit         sub       (.A(A), .B(B),            .Diff(diff),       .Cout(b1));
  subtractor_with_borrow  sub_b     (.A(A), .B(B),            .Diff(diff_borrow),.Borrow(b2));
  and_4bit                and_gate  (.A(A), .B(B),            .Y(and_out));
  or_4bit                 or_gate   (.A(A), .B(B),            .Y(or_out));
  xor_4bit                xor_gate  (.A(A), .B(B),            .Y(xor_out));
  Not_4bit                not_gate  (.A(A),                   .Y(not_out));
  increment_4bit          inc       (.A(A),                   .Result(inc_out),  .CarryOut(c_inc));
  decrement_4bit          dec       (.A(A),                   .Result(dec_out),  .BorrowOut(c_dec));
  transfer_A_4bit         trans     (.A(A),                   .Y(transf_A));

  always @(*) begin
    case (Op)
      4'b0000: begin Result = sum;          Flag = c1;     end // ADD
      4'b0001: begin Result = sum_carry;    Flag = c2;     end // ADD with carry
      4'b0010: begin Result = diff;         Flag = b1;     end // SUB
      4'b0011: begin Result = diff_borrow;  Flag = b2;     end // SUB with borrow
      4'b0100: begin Result = and_out;      Flag = 0;      end // AND
      4'b0101: begin Result = or_out;       Flag = 0;      end // OR
      4'b0110: begin Result = xor_out;      Flag = 0;      end // XOR
      4'b0111: begin Result = not_out;      Flag = 0;      end // NOT
      4'b1000: begin Result = inc_out;      Flag = c_inc;  end // Increment
      4'b1001: begin Result = dec_out;      Flag = c_dec;  end // Decrement
      4'b1010: begin Result = transf_A;     Flag = 0;      end // Transfer A
      default: begin Result = 4'b0000;      Flag = 0;      end
    endcase
  end

endmodule


 

