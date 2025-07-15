module DSP48A1 (A, B, C, D, clk, CARRYIN, OPMODE, BCIN, PCIN,
 RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPCODE,
 CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPCODE,
 BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF);

    parameter ADDER_SIZE = 18;
    parameter CONCATENATED_SIZE = 48;
    parameter MULTIPLIER_SIZE = 36;
    parameter OPMODE_SIZE = 8;
    parameter A0REG = 0;
    parameter A1REG = 0;
    parameter B0REG = 0;
    parameter B1REG = 0;
    parameter CREG = 1;
    parameter DREG = 1;
    parameter MREG = 1;
    parameter PREG = 1;
    parameter CARRYINREG = 1; 
    parameter CARRYOUTREG = 1; 
    parameter OPMODEREG = 1; //pipeline register on or off paramters
    parameter CARRYINSEL = "OPMODE5"; //available values OPMODE5 or CARRYIN
    parameter B_INPUT = "DIRECT"; //available values DIRECT or CASCADE
    parameter RSTTYPE = "SYNC"; // all resets type available values SYNC or ASYNC

    input [ADDER_SIZE-1 : 0] A, B, D, BCIN;
    input [CONCATENATED_SIZE-1 : 0] C, PCIN;
    input [OPMODE_SIZE-1 : 0] OPMODE;
    input clk, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPCODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPCODE;

    output [ADDER_SIZE-1 : 0] BCOUT;
    output [MULTIPLIER_SIZE-1 : 0] M;
    output [CONCATENATED_SIZE-1 : 0] P, PCOUT;
    output CARRYOUT, CARRYOUTF;

    wire [ADDER_SIZE-1 : 0] A0_out, A1_out, B0_in, B0_out, B1_in, B1_out, D_out, pre_adder_out;
    wire [MULTIPLIER_SIZE-1 : 0] M_in, M_out;
    wire [CONCATENATED_SIZE-1 : 0] C_out, p_out, concatenated_in, X_out, Z_out, post_adder_out;
    wire CARRYIN_in, CARRYIN_out, CARRYOUT_in, CARRYOUT_out;
    wire [OPMODE_SIZE-1 : 0] OPMODE_out;

    // Opmode input
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(OPMODEREG),
        .SIZE(OPMODE_SIZE)) OPMODE_reg ( 
            .clk(clk),
            .clk_en(CEOPCODE), 
            .rst(RSTOPCODE), 
            .data_in(OPMODE), 
            .data_out(OPMODE_out)); 

    // A input
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(A0REG),
        .SIZE(ADDER_SIZE)) A0_reg (
            .clk(clk),
            .clk_en(CEA), 
            .rst(RSTA), 
            .data_in(A), 
            .data_out(A0_out));
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(A1REG),
        .SIZE(ADDER_SIZE)) A1_reg (
            .clk(clk),
            .clk_en(CEA), 
            .rst(RSTA), 
            .data_in(A0_out), 
            .data_out(A1_out));
    
    // D input
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(DREG),
        .SIZE(ADDER_SIZE)) D_reg (
            .clk(clk),
            .clk_en(CED), 
            .rst(RSTD), 
            .data_in(D), 
            .data_out(D_out));
    
    // B input 
    assign B0_in = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0;

    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(B0REG),
        .SIZE(ADDER_SIZE)) B0_reg (
            .clk(clk),
            .clk_en(CEB), 
            .rst(RSTB), 
            .data_in(B0_in), 
            .data_out(B0_out));

    // Pre-adder
    assign pre_adder_out = (OPMODE_out[6]) ? D_out - B0_out : D_out + B0_out;

    assign B1_in = (OPMODE_out[4]) ? pre_adder_out : B0_out;

    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(B1REG),
        .SIZE(ADDER_SIZE)) B1_reg (
            .clk(clk),
            .clk_en(CEB), 
            .rst(RSTB), 
            .data_in(B1_in), 
            .data_out(B1_out));
    assign BCOUT = B1_out;

    // Multiplying 
    assign M_in = A1_out * B1_out;

    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(MREG),
        .SIZE(MULTIPLIER_SIZE)) M_reg ( 
            .clk(clk),
            .clk_en(CEM), 
            .rst(RSTM), 
            .data_in(M_in),
            .data_out(M_out)); 

    assign M = M_out;

    // Carry in
    assign CARRYIN_in = (CARRYINSEL == "CARRYIN") ? CARRYIN : (CARRYINSEL == "OPMODE5") ? OPMODE_out[5] : 0;
       ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(CARRYINREG),
        .SIZE(1)) CARRYIN_reg ( 
            .clk(clk),
            .clk_en(CECARRYIN), 
            .rst(RSTCARRYIN), 
            .data_in(CARRYIN_in), 
            .data_out(CARRYIN_out));

    // C input    
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(CREG),
        .SIZE(CONCATENATED_SIZE)) C_reg (
            .clk(clk),
            .clk_en(CEC), 
            .rst(RSTC), 
            .data_in(C), 
            .data_out(C_out));

    // X multiplexer 
    assign X_out = (OPMODE_out[1:0] == 2'b00) ? 0 : (OPMODE_out[1:0] == 2'b01) ? M_out : (OPMODE_out[1:0] == 2'b10) ? p_out : {D[11:0], A[17:0], B[17:0]};
    
    // Z multiplexer
    assign Z_out = (OPMODE_out[3:2] == 2'b00) ? 0 : (OPMODE_out[3:2] == 2'b01) ? PCIN : (OPMODE_out[3:2] == 2'b10) ? p_out : C_out;

    // Post-adder
    assign {CARRYOUT_in, post_adder_out} = (OPMODE_out[7]) ? Z_out - (X_out + CARRYIN_out) : Z_out + X_out + CARRYIN_out;

    // Output
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(PREG),
        .SIZE(CONCATENATED_SIZE)) P_reg ( 
            .clk(clk),
            .clk_en(CEP), 
            .rst(RSTP), 
            .data_in(post_adder_out), 
            .data_out(p_out)); 
    assign P = p_out;
    assign PCOUT = p_out;

    // Carry out
    ff_mux #(
        .RSTTYPE(RSTTYPE),
        .REG(CARRYOUTREG),
        .SIZE(1)) CARRYOUT_reg ( 
            .clk(clk),
            .clk_en(CECARRYIN), 
            .rst(RSTCARRYIN), 
            .data_in(CARRYOUT_in), 
            .data_out(CARRYOUT_out)); 

    assign CARRYOUT = CARRYOUT_out;
    assign CARRYOUTF = CARRYOUT_out;

    
endmodule