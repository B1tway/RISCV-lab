module func(input clk_i,
           input rst_i,
           input start_i,
           input [7:0] a_bi,
           input [7:0] b_bi,
           output busy_o,
           output reg[7:0] y_bo);
    
    localparam IDLE = 3'b000;
    localparam SQRT = 3'b001;
    localparam CUBE = 3'b010;
    localparam SUM = 3'b100;    
    reg [2:0] state;
    reg [2:0] state_next;
    reg [7:0] a;
    wire [7:0] sqrt_bo;
    wire [1:0] busy;
    
    wire[7:0] sum_result;
    
    wire cube_start;
    wire cube_busy;
    wire [7:0] cube_bo;
    reg[7:0] sqrt_result;
    cube cub(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .x_bi(sqrt_result),
    .start_i(cube_start),
    .busy_o(cube_busy),
    .y_bo(cube_bo)
    );
    
    wire sqrt_start;
    wire sqrt_busy;
    sqrt sqr(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .x_bi(b_bi),
    .start_i(sqrt_start),
    .busy_o(sqrt_busy),
    .y_bo(sqrt_bo)
    );
    
    reg calc_start = 0;
    assign sqrt_start = state_next[0];
    assign cube_start = state_next[1];
    assign busy_o     = (state != IDLE) | !calc_start;
    assign sum_result = a + sqrt_result;
    always @(posedge clk_i)
        if (rst_i) begin
            state <= IDLE;
            end else begin
            state <= state_next;
        end
    
    always @* begin
        case(state)
            IDLE: state_next = (start_i) ? SQRT: IDLE;
            SQRT: state_next = (sqrt_busy) ? SQRT : SUM;
            SUM:  state_next = CUBE;
            CUBE: state_next = (cube_busy) ? CUBE : IDLE;
        endcase
    end
    
     always @(posedge clk_i)
        if(rst_i) begin 
            a <= 0;
            y_bo <= 0;
            sqrt_result <= 0;
            calc_start <= 0;
        end else begin
            case (state)
                IDLE:
                if (start_i) begin
                    a <= a_bi;
                    calc_start <= 1;
                end
                SQRT: begin
                    if (!sqrt_busy) begin
                        sqrt_result <= sqrt_bo + a; 
                    end
                end
                CUBE: begin
                    if (!cube_busy) begin
                        y_bo <= cube_bo;
                    end
                end
                
            endcase
         end
endmodule

module mul(
    input clk_i,
    input rst_i,
    input [7:0] a_bi,
    input [7:0] b_bi,
    input start_i, 
    
    output busy_o,
    output reg[15:0] y_bo 
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    
    reg [2:0] ctr;
    wire [2:0] end_step;
    wire [7:0] part_sum;
    wire [15:0] shifted_part_sum;
    reg [7:0] a, b;
    reg [15:0] part_res;
    reg state;
    
    assign part_sum = a & {8{b[ctr]}};
    assign shifted_part_sum = part_sum << ctr;
    assign end_step = (ctr == 3'h7);
    assign busy_o = state;
    always @(posedge clk_i)
        if (rst_i) begin
            ctr <= 0;
            part_res <= 0;
            y_bo <= 0;
            state <= IDLE;
        end else begin
        
            case (state)
                IDLE:
                    if (start_i) begin
                        state <= WORK;
                        a <= a_bi;
                        b <= b_bi;
                        ctr <= 0;
                        part_res <= 0;
                    end
                WORK:
                    begin
                        if (end_step) begin 
                            state <= IDLE;
                            y_bo <= part_res;
                        end
                        
                        part_res <= part_res + shifted_part_sum;
                        ctr <= ctr + 1;
                    end
            endcase 
            
        end
        
endmodule

module sqrt(input clk_i,
            input rst_i,
            input [7:0] x_bi,
            input start_i,
            output busy_o,
            output reg [7:0] y_bo);
    
    localparam IDLE  = 1'b0;
    localparam WORK  = 1'b1;
    localparam START = 6'd6;
    localparam END   = 6'd0;
    
    reg [7:0] x;
    reg [7:0] b;
    reg [7:0] m;
    reg [7:0] y;
    reg state;
    reg[7:0] bw, xw, y_temp, yw, mw;
    assign end_step = (m == END);
    assign busy_o   = state;
    
    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
            m     <= 1 << START;
            y     <= 0;
            y_bo  <= 0;
            end else begin
            
            case(state)
                IDLE:
                if (start_i) begin
                    state <= WORK;
                    m     <= 1 << START;
                    x     <= x_bi;
                end
                WORK:
                begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo  <= y;
                    end
//                    b <= bw;
                    x <= xw;
                    y <= yw;
                    m <= mw;
                    
                end
            endcase
        end
    end
    
 
    always @* begin
        bw     = y | m;
        xw     = x;
        y_temp = y >> 1;
        yw     = y_temp;
        if (x >= bw) begin
            xw = x - bw;
            yw = y_temp | m;
        end
        
        mw = m >> 2;
        
        
    end
endmodule

module cube(
    input clk_i,
    input rst_i,
    input [7:0] x_bi,
    input start_i, 
    output busy_o,
    output reg [7:0] y_bo 
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    localparam START = 6'sd6;
    localparam END = -(6'sd3);
    
    reg [7:0] x;
    reg [7:0] b;
    reg [5:0] s;
    reg [7:0] y;
    wire [5:0] end_step;
    reg state = IDLE;
    
    assign end_step = (s == END);
    assign busy_o = state;
        
always @(posedge clk_i)
    if (rst_i) begin
       state <= IDLE;
       s <= START;
       y <= 0;
       y_bo <= 0;
    end else begin
    
        case(state)
            IDLE:
                if (start_i) begin
                    state <= WORK;
                    s <= START;
                    x <= x_bi;
                    y_bo <= 0;
                    b <= 1 << s;
                end
            WORK:
                begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo <= y;
                    end
                    
                    y = y << 1;
                    b = (3*y*(y+1)+1) << s;
                    
                    if (x >= b) begin
                        x = x - b;
                        y = y + 1;
                    end
                    
                    s = s - 3;
                end
        endcase 
    end
endmodule