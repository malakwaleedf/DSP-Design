module DSP48A1_tb();

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

    reg [ADDER_SIZE-1 : 0] A, B, D, BCIN;
    reg [CONCATENATED_SIZE-1 : 0] C, PCIN;
    reg [OPMODE_SIZE-1 : 0] OPMODE;
    reg clk, CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPCODE, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPCODE;

    wire [ADDER_SIZE-1 : 0] BCOUT;
    wire [MULTIPLIER_SIZE-1 : 0] M;
    wire [CONCATENATED_SIZE-1 : 0] P, PCOUT;
    wire CARRYOUT, CARRYOUTF;

    reg [ADDER_SIZE-1 : 0] BCOUT_temp;
    reg [MULTIPLIER_SIZE-1 : 0]M_temp;
    reg [CONCATENATED_SIZE-1 : 0] P_temp;
    reg CARRYOUT_temp;

    // DUT instantiation
    DSP48A1 dut (
        A, B, C, D, clk, CARRYIN, OPMODE, BCIN, PCIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPCODE,
         CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPCODE, BCOUT, PCOUT, P, M, CARRYOUT, CARRYOUTF);

     // clock generation
    initial begin
        clk = 1;
        forever begin
            #2 clk = ~clk;
        end
    end

    initial begin
        BCOUT_temp = 0;
        M_temp = 0;
        P_temp = 0;
        CARRYOUT_temp = 0;
        RSTA = 1;
        RSTB = 1;
        RSTM = 1;
        RSTP = 1;
        RSTC = 1;
        RSTD = 1;
        RSTCARRYIN = 1;
        RSTOPCODE = 1;
        A = 18'h3_FFFF;
        B = 18'h3_FFFF;
        C = 48'hFFFF_FFFF_FFFF;
        D = 18'h3_FFFF;
        CARRYIN = 1;
        OPMODE = 0;
        BCIN = 0;
        PCIN = 48'hFFFF_FFFF_FFFF;
        CEA = 1;
        CEB = 1;
        CEM = 1;
        CEP = 1;
        CEC = 1;
        CED = 1;
        CECARRYIN = 1;
        CEOPCODE = 1;
        @(negedge clk);
        if(P !== 0) begin
            $display("Error");
            $stop;
        end
        if(PCOUT !== 0) begin
            $display("Error");
            $stop;
        end
        // if(BCOUT !== 0) begin
        //     $display("Error");
        //     $stop;
        // end // B1REG = 0
        if(M !== 0) begin
            $display("Error");
            $stop;
        end
        if(CARRYOUT !== 0) begin
            $display("Error");
            $stop;
        end
        if(CARRYOUTF !== 0) begin
            $display("Error");
            $stop;
        end
        RSTA = 0;
        RSTB = 0;
        RSTM = 0;
        RSTP = 0;
        RSTC = 0;
        RSTD = 0;
        RSTCARRYIN = 0;
        RSTOPCODE = 0;

        // OPCODE bits 
        OPMODE[1:0] = 0;
        OPMODE[3:2] = 0;
        OPMODE [4] = 0;
        OPMODE [5] = 0;
        OPMODE [6] = 0;
        OPMODE [7] = 0; // mathimatical operations: BOUT = B, M = B*A, P = POUT = 0, CARRYOUT = CARRYOUTF = 0
        repeat(10) begin
            // Randomize inputs
            A = $random;
            B = $random;
            C = $random;
            D = $random;
            CARRYIN = $random;
            BCIN = $random;
            PCIN = $random;
            @(negedge clk);
            if(BCOUT !== B) begin
                $display("Error");
                $stop;
            end
            @(negedge clk); 
            if(M !== B*A) begin
                $display("Error");
                $stop;
            end
            @(negedge clk); 
            if(P !== 0) begin
                $display("Error");
                $stop;
            end
            if(PCOUT !== 0) begin
                $display("Error");
                $stop;
            end
            if(CARRYOUT !== 0) begin
                $display("Error");
                $stop;
            end
            if(CARRYOUTF !== 0) begin
                $display("Error");
                $stop;
            end
        end
        // OPCODE bits 
        OPMODE[1:0] = 1;
        OPMODE[3:2] = 3;
        OPMODE [4] = 1;
        OPMODE [5] = 1;
        OPMODE [6] = 0;
        OPMODE [7] = 0; // mathimatical operations: BOUT = D+B, M = (D+B)*A, {CARRYOUT = CARRYOUTF, P = POUT} = (D+B)*A+C+CARRYIN
        repeat(10) begin
            // Randomize inputs
            A = $random;
            B = $random;
            C = $random;
            D = $random;
            CARRYIN = $random;
            BCIN = $random;
            PCIN = $random;
            BCOUT_temp = D + B;
            M_temp = BCOUT_temp * A;
            {CARRYOUT_temp, P_temp} = M_temp + C + OPMODE [5];
            @(negedge clk);
            if(BCOUT !== BCOUT_temp) begin
                $display("Error, BCOUT_temp = %h", BCOUT_temp);
                $stop;
            end
            @(negedge clk); 
            if(M !== M_temp) begin
                $display("Error, M_temp = %h", M_temp);
                $stop;
            end
            @(negedge clk); 
            if({CARRYOUT, P} !== {CARRYOUT_temp, P_temp}) begin
                $display("Error, {CARRYOUT_temp, P_temp} = %h", {CARRYOUT_temp, P_temp});
                $stop;
            end
            if({CARRYOUTF, PCOUT} !== {CARRYOUT_temp, P_temp}) begin
                $display("Error");
                $stop;
            end
        end

        $stop;
    end

    initial begin
        $monitor("A= %h, B= %h, C= %h, D= %h, CARRYIN= %h, BCIN= %h, PCIN = %h, OPMODE= %b 
        BCOUT= %h, M= %h, P= %h, PCOUT= %h, CARRYOUT= %h, CARRYOUF= h", 
        A, B, C, D, CARRYIN, BCIN, PCIN, OPMODE, BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
    end

endmodule    