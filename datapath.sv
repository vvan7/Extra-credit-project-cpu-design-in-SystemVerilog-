module datapath(input  logic clk, reset,
                input  logic memtoreg, pcsrc,
        input  logic alusrc, regdst,
              input  logic regwrite, jump,
            input  logic [2:0] alucontrol,
            output logic zero,
            output logic [31:0] pc,
            input  logic [31:0] instr,
            output logic [31:0] aluout, writedata,
            input  logic [31:0] readdata);

 logic [4:0] writereg;
 logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
 logic [31:0] signimm, signimmsh;
 logic [31:0] srca, srcb;
 logic [31:0] result;

logic [31:0] InstrF, PCPlus4F;
logic [63:0] FD;

logic [31:0] InstrD, PCPlus4D;
logic [31:0] SrcAD, WriteDataD, SignImmD;
logic [4:0] RtD, RdD;
logic [25:0] PCJumpD;
logic [163:0] DE;

logic [31:0] SrcAE, SrcBE, WriteDataE, SignImmE, SignImmEsh, PCPlus4E;
logic [31:0] ALUOutE, PCBranchE;
logic [4:0] RtE, RdE, WriteRegE;
logic [25:0] PCJumpE;
logic [27:0] PCJumpEsh;
logic [129:0] EM;
logic ZeroE;

logic [31:0] ALUOutM, WriteDataM, PCBranchM;
logic [31:0] ReadDataM;
logic [4:0] WriteRegM;
logic [27:0] PCJumpM;
logic [68:0] MW;
logic ZeroM;

logic [31:0] ALUOutW, ReadDataW;
logic [4:0] WriteRegW;


// Fetch
 flopr #(32)  pcreg(clk, reset, pcnext, pc);
 adder        pcadd1(pc, 32'b100, pcplus4);
assign PCPlus4F = pcplus4;
assign InstrF = instr;


// Decode
flopr #(64) FetchDecode(clk, reset, {InstrF,PCPlus4F}, FD);
assign InstrD = FD[63:32];
assign PCPlus4D = FD[31:0];
assign RtD = InstrD[20:16];
assign RdD = InstrD[15:11];
signext se(InstrD[15:0], signimm);
assign SignImmD = signimm;
assign PCJumpD = InstrD;
// Register File
regfile rf(clk, regwrite, InstrD[25:21], InstrD[20:16], WriteRegW, result, srca, srcb);
mux2 #(32)   resmux(ALUOutW, ReadDataW, memtoreg, result);
assign SrcAD = srca;
assign WriteDataD = srcb;


// Execute
flopr #(164) DecodeExecute(clk, reset, {SrcAD,WriteDataD,RtD,RdD,SignImmD,PCPlus4D,PCJumpD}, DE);
assign SrcAE = DE[163:132];
assign WriteDataE = DE[131:100];
assign RtE = DE[99:95];
assign RdE = DE[94:90];
assign SignImmE = DE[89:58];
assign PCPlus4E = DE[57:26];
assign PCJumpE = DE[25:0];
mux2 #(5) wrmux(RtE, RdE, regdst, WriteRegE);
mux2 #(32) srcbmux(WriteDataE, SignImmE, alusrc, SrcBE);
sl2        immsh(SignImmE, SignImmEsh);
adder   pcadd2(PCPlus4E, SignImmEsh , pcbranch);
assign PCBranchE = pcbranch;
assign PCJumpEsh = {PCJumpE, 2'b00};
// ALU
alu32        alu(SrcAE, SrcBE, alucontrol, ALUOutE, zero);
assign ZeroE = zero;


// Memory
flopr #(130) ExecuteMemory(clk, reset, {ZeroE,ALUOutE,WriteDataE,WriteRegE,PCBranchE,PCJumpEsh}, EM);
assign ZeroM = EM[129];
assign ALUOutM = EM[128:97];
assign WriteDataM = EM[96:65];
assign WriteRegM = EM[64:60];
assign PCBranchM = EM[59:28];
assign PCJumpM = EM[27:0];
mux2 #(32)   pcbrmux(PCPlus4F, PCBranchM, pcsrc, pcnextbr);
mux2 #(32)   pcmux(pcnextbr, {pcplus4[31:28], PCJumpM}, jump, pcnext);
// Data Memory
assign aluout = ALUOutM;
assign writedata = WriteDataM;
assign ReadDataM = readdata;


// Writeback
flopr #(69) MemoryWriteback(clk, reset, {ALUOutM, ReadDataM, WriteRegM}, MW);
assign ALUOutW = MW[68:37];
assign ReadDataW = MW[36:5];
assign WriteRegW = MW[4:0];


endmodule



