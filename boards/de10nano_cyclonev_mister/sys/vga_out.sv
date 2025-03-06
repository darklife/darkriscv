
module vga_out
(
	input         clk,
	input         ypbpr_en,

	input         hsync,
	input         vsync,
	input         csync,

	input  [23:0] din,
	output [23:0] dout,

	output reg    hsync_o,
	output reg    vsync_o,
	output reg    csync_o
);

wire [5:0] red   = din[23:18];
wire [5:0] green = din[15:10];
wire [5:0] blue  = din[7:2];

// http://marsee101.blog19.fc2.com/blog-entry-2311.html
// Y  =  16 + 0.257*R + 0.504*G + 0.098*B (Y  =  0.299*R + 0.587*G + 0.114*B)
// Pb = 128 - 0.148*R - 0.291*G + 0.439*B (Pb = -0.169*R - 0.331*G + 0.500*B)
// Pr = 128 + 0.439*R - 0.368*G - 0.071*B (Pr =  0.500*R - 0.419*G - 0.081*B)

reg  [7:0] y, pb, pr;
reg [23:0] rgb;
always @(posedge clk) begin
	reg [18:0] y_1r, pb_1r, pr_1r;
	reg [18:0] y_1g, pb_1g, pr_1g;
	reg [18:0] y_1b, pb_1b, pr_1b;
	reg [18:0] y_2, pb_2, pr_2;
	reg [23:0] din1, din2;
	reg hsync2, vsync2, csync2;
	reg hsync1, vsync1, csync1;

	y_1r  <= 19'd04096 + ({red, 8'd0} + {red, 3'd0});
	pb_1r <= 19'd32768 - ({red, 7'd0} + {red, 4'd0} + {red, 3'd0});
	pr_1r <= 19'd32768 + ({red, 8'd0} + {red, 7'd0} + {red, 6'd0});

	y_1g  <= {green, 9'd0} + {green, 2'd0};
	pb_1g <= {green, 8'd0} + {green, 5'd0} + {green, 3'd0};
	pr_1g <= {green, 8'd0} + {green, 6'd0} + {green, 5'd0} + {green, 4'd0} + {green, 3'd0};

	y_1b  <= {blue, 6'd0} + {blue, 5'd0} + {blue, 2'd0};
	pb_1b <= {blue, 8'd0} + {blue, 7'd0} + {blue, 6'd0};
	pr_1b <= {blue, 6'd0} + {blue, 3'd0};

	y_2  <= y_1r  + y_1g  + y_1b;
	pb_2 <= pb_1r - pb_1g + pb_1b;
	pr_2 <= pr_1r - pr_1g - pr_1b;

	y  <= ( y_2[18] ||  !y_2[17:12]) ? 8'd16 : (y_2[17:8] > 235) ? 8'd235 :  y_2[15:8];
	pb <= (pb_2[18] || !pb_2[17:12]) ? 8'd16 : (&pb_2[17:12])    ? 8'd240 : pb_2[15:8];
	pr <= (pr_2[18] || !pr_2[17:12]) ? 8'd16 : (&pr_2[17:12])    ? 8'd240 : pr_2[15:8];

	hsync_o <= hsync2; hsync2 <= hsync1; hsync1 <= hsync;
	vsync_o <= vsync2; vsync2 <= vsync1; vsync1 <= vsync;
	csync_o <= csync2; csync2 <= csync1; csync1 <= csync;

	rgb <= din2; din2 <= din1; din1 <= din;
end

assign dout = ypbpr_en ? {pr, y, pb} : rgb;

endmodule
