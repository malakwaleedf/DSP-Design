module ff_mux (clk, clk_en, rst, data_in, data_out);
    parameter RSTTYPE = "SYNC";
    parameter REG = 0;
    parameter SIZE = 18;
    input clk, clk_en, rst; 
    input [SIZE-1 : 0] data_in;
    output [SIZE-1 : 0] data_out;

    reg [SIZE-1 : 0] sync_rst_reg_out;
    reg [SIZE-1 : 0] async_rst_reg_out;
    reg [SIZE-1 : 0] no_reg_out;

    always @(posedge clk) begin
        if(clk_en) begin
            if(rst == 1)
                sync_rst_reg_out <= 0;
            else
                sync_rst_reg_out <= data_in;
        end
    end

     always @(posedge clk or posedge rst) begin
        if(clk_en) begin
            if(rst == 1)
                async_rst_reg_out <= 0;
            else
                async_rst_reg_out <= data_in;
        end
    end

    assign data_out = (!REG) ? data_in : (RSTTYPE == "SYNC") ? sync_rst_reg_out : async_rst_reg_out;

endmodule