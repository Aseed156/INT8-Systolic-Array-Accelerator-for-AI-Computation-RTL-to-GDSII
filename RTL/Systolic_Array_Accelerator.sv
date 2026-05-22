module Systolic_Array_Accelerator #(
    parameter bit_width = 8,
    parameter acc_width = 32,
    parameter SIZE      = 8
)(
    input                               clk,
    input                               reset,

    input  [bit_width-1:0]              data_in,
    input                               data_valid,

    input  [bit_width-1:0]              weight_in,
    input                               weight_valid,

    output reg                          array_ready,
    output reg                          valid_out,

    output reg [(SIZE*acc_width)-1:0]   acc_out
);



reg [bit_width-1:0] A_mem [0:SIZE-1][0:SIZE-1];
reg [bit_width-1:0] B_mem [0:SIZE-1][0:SIZE-1];

// INTERCONNECTS
wire [bit_width-1:0] data_w [0:SIZE-1][0:SIZE];
wire [bit_width-1:0] wt_w   [0:SIZE][0:SIZE-1];
wire [acc_width-1:0] acc_w  [0:SIZE-1][0:SIZE];



reg [5:0] a_load_cnt;
reg [5:0] b_load_cnt;

reg A_loaded;
reg B_loaded;



always @(posedge clk) begin

    if(reset) begin
        integer i,j;
        a_load_cnt <= 0;
        b_load_cnt <= 0;

        A_loaded <= 0;
        B_loaded <= 0;

        for(i=0;i<SIZE;i=i+1)
            for(j=0;j<SIZE;j=j+1) begin
                A_mem[i][j] <= 0;
                B_mem[i][j] <= 0;
            end
    end

    else begin

        // Load A
        if(data_valid && !A_loaded) begin

            A_mem[a_load_cnt/SIZE][a_load_cnt%SIZE] <= data_in;

            if(a_load_cnt == SIZE*SIZE-1)
                A_loaded <= 1'b1;

            a_load_cnt <= a_load_cnt + 1;
        end

        // Load B
        if(weight_valid && !B_loaded) begin

            B_mem[b_load_cnt/SIZE][b_load_cnt%SIZE] <= weight_in;

            if(b_load_cnt == SIZE*SIZE-1)
                B_loaded <= 1'b1;

            b_load_cnt <= b_load_cnt + 1;
        end
    end
end



localparam IDLE    = 0;
localparam COMPUTE = 1;
localparam DONE    = 2;

reg [1:0] state;

reg [5:0] cycle_count;

always @(posedge clk) begin
    integer i;
    if(reset) begin
        state       <= IDLE;
        cycle_count <= 0;
        array_ready <= 0;
        valid_out   <= 0;
    end

    else begin

        case(state)

        IDLE: begin

            valid_out <= 0;

            if(A_loaded && B_loaded) begin
                state       <= COMPUTE;
                array_ready <= 1;
                cycle_count <= 0;
            end
        end

        COMPUTE: begin

            cycle_count <= cycle_count + 1;

            // Total systolic latency
            if(cycle_count == (3*SIZE - 2)) begin
                state <= DONE;
            end
        end

        DONE: begin

            valid_out <= 1'b1;

            for(i=0;i<SIZE;i=i+1)
                acc_out[i*acc_width +: acc_width]
                    <= acc_w[i][SIZE];

            state <= DONE;
        end

        endcase
    end
end




// WAVEFRONT SCHEDULER

genvar r,c;

generate

for(r=0;r<SIZE;r=r+1) begin : DATA_BOUNDARY

    assign data_w[r][0] =
        (state == COMPUTE &&
         cycle_count >= r &&
         (cycle_count-r) < SIZE)
        ?
        A_mem[r][cycle_count-r]
        :
        0;

end

for(c=0;c<SIZE;c=c+1) begin : WT_BOUNDARY

    assign wt_w[0][c] =
        (state == COMPUTE &&
         cycle_count >= c &&
         (cycle_count-c) < SIZE)
        ?
        B_mem[cycle_count-c][c]
        :
        0;

end

for(r=0;r<SIZE;r=r+1) begin : ACC_BOUNDARY
    assign acc_w[r][0] = 0;
end

endgenerate


// PE ARRAY
genvar x,y;

generate

for(x=0;x<SIZE;x=x+1) begin : ROWS

    for(y=0;y<SIZE;y=y+1) begin : COLS

        MAC_Unit #(
            .bit_width(bit_width),
            .acc_width(acc_width)
        )
        PE
        (
            .clk(clk),
            .reset(reset),

            .data_in(data_w[x][y]),
            .wt_in(wt_w[x][y]),
            .acc_in(acc_w[x][y]),

            .data_out(data_w[x][y+1]),
            .wt_out(wt_w[x+1][y]),
            .acc_out(acc_w[x][y+1])
        );

    end
end

endgenerate

endmodule
