`timescale 1ns/1ps

module tb_Systolic_Array_Accelerator;

parameter BIT_WIDTH = 8;
parameter ACC_WIDTH = 32;
parameter SIZE      = 8;

reg clk;
reg reset;

reg [BIT_WIDTH-1:0] data_in;
reg data_valid;

reg [BIT_WIDTH-1:0] weight_in;
reg weight_valid;

wire array_ready;
wire valid_out;

wire [(SIZE*ACC_WIDTH)-1:0] acc_out;


// DUT


Systolic_Array_Accelerator #(
    .bit_width(BIT_WIDTH),
    .acc_width(ACC_WIDTH),
    .SIZE(SIZE)
)
dut
(
    .clk(clk),
    .reset(reset),

    .data_in(data_in),
    .data_valid(data_valid),

    .weight_in(weight_in),
    .weight_valid(weight_valid),

    .array_ready(array_ready),
    .valid_out(valid_out),

    .acc_out(acc_out)
);



always #5 clk = ~clk;



reg [BIT_WIDTH-1:0] A [0:SIZE-1][0:SIZE-1];
reg [BIT_WIDTH-1:0] B [0:SIZE-1][0:SIZE-1];

reg [ACC_WIDTH-1:0] GOLDEN [0:SIZE-1];

integer i,j,k;



initial begin

    clk = 0;
    reset = 1;

    data_valid = 0;
    weight_valid = 0;

    #50;
    reset = 0;



    for(i=0;i<SIZE;i=i+1)
        for(j=0;j<SIZE;j=j+1) begin

            A[i][j] = i+j+1;
            B[i][j] = j+1;
        end



    for(i=0;i<SIZE;i=i+1) begin

        GOLDEN[i] = 0;

        for(k=0;k<SIZE;k=k+1)
            GOLDEN[i] =
                GOLDEN[i] + (A[i][k] * B[k][SIZE-1]);
    end



    @(posedge clk);

    data_valid = 1;

    for(i=0;i<SIZE;i=i+1)
        for(j=0;j<SIZE;j=j+1) begin

            data_in = A[i][j];
            @(posedge clk);
        end

    data_valid = 0;


    @(posedge clk);

    weight_valid = 1;

    for(i=0;i<SIZE;i=i+1)
        for(j=0;j<SIZE;j=j+1) begin

            weight_in = B[i][j];
            @(posedge clk);
        end

    weight_valid = 0;



    @(posedge valid_out);

    $display("\n=== RESULTS ===");

    for(i=0;i<SIZE;i=i+1) begin

        $display(
            "Row %0d : got=%0d expected=%0d",
            i,
            acc_out[i*ACC_WIDTH +: ACC_WIDTH],
            GOLDEN[i]
        );
    end

end

endmodule
