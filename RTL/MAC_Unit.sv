module MAC_Unit #(
    parameter bit_width = 8,
    parameter acc_width = 32
)(
    input                               clk,
    input                               reset,
    input      [bit_width-1:0]          data_in,
    input      [bit_width-1:0]          wt_in,
    input      [acc_width-1:0]          acc_in, 
    output reg [bit_width-1:0]          data_out,
    output reg [bit_width-1:0]          wt_out,
    output reg [acc_width-1:0]          acc_out
);
always @(posedge clk) begin
    if(reset) begin
        data_out <= 0;
        wt_out   <= 0;
        acc_out  <= 0;
    end
    else begin
        // Forward operands
        data_out <= data_in;
        wt_out   <= wt_in;
        acc_out  <= acc_out + (data_in * wt_in);
    end
end

endmodule
