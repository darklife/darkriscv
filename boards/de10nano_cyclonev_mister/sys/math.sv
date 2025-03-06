
// result = num/div
module sys_udiv
#(
	parameter NB_NUM, 
	parameter NB_DIV
)
(
	input  clk,
	input  start,
	output busy,

	input      [NB_NUM-1:0] num,
	input      [NB_DIV-1:0] div,
	output reg [NB_NUM-1:0] result,
	output reg [NB_DIV-1:0] remainder
);

reg run;
assign busy = run;

always @(posedge clk) begin
	reg [5:0] cpt;
	reg [NB_NUM+NB_DIV+1:0] rem;

	if (start) begin
		cpt <= 0;
		run <= 1;
		rem <= num;
	end
	else if (run) begin
		cpt <= cpt + 1'd1;
		run <= (cpt != NB_NUM + 1'd1);
		remainder <= rem[NB_NUM+NB_DIV:NB_NUM+1];
 		if (!rem[NB_DIV + NB_NUM + 1'd1])
 			rem <= {rem[NB_DIV+NB_NUM:0] - (div << NB_NUM),1'b0};
 		else
 			rem <= {rem[NB_DIV+NB_NUM:0] + (div << NB_NUM),1'b0};
 		result <= {result[NB_NUM-2:0], !rem[NB_DIV + NB_NUM + 1'd1]};
	end
end

endmodule

// result = mul1*mul2
module sys_umul
#(
	parameter NB_MUL1, 
	parameter NB_MUL2
)
(
	input  clk,
	input  start,
	output busy,

	input              [NB_MUL1-1:0] mul1,
	input              [NB_MUL2-1:0] mul2,
	output reg [NB_MUL1+NB_MUL2-1:0] result
);

reg run;
assign busy = run;

always @(posedge clk) begin
	reg [NB_MUL1+NB_MUL2-1:0] add;
	reg [NB_MUL2-1:0] map;

	if (start) begin
		run    <= 1;
		result <= 0;
		add    <= mul1;
		map    <= mul2;
	end
	else if (run) begin
		if(!map)   run <= 0;
		if(map[0]) result <= result + add;
		add <= add << 1;
		map <= map >> 1;
	end
end

endmodule

// result = (mul1*mul2)/div
module sys_umuldiv
#(
	parameter NB_MUL1, 
	parameter NB_MUL2,
	parameter NB_DIV
)
(
	input  clk,
	input  start,
	output busy,

	input          [NB_MUL1-1:0] mul1,
	input          [NB_MUL2-1:0] mul2,
	input           [NB_DIV-1:0] div,
	output [NB_MUL1+NB_MUL2-1:0] result,
	output          [NB_DIV-1:0] remainder
);

wire mul_run;
wire [NB_MUL1+NB_MUL2-1:0] mul_res;
sys_umul #(NB_MUL1,NB_MUL2) umul(clk,start,mul_run,mul1,mul2,mul_res);

sys_udiv #(NB_MUL1+NB_MUL2,NB_DIV) udiv(clk,start|mul_run,busy,mul_res,div,result,remainder);

endmodule
