module controller(input  logic  [5:0] op, funct,
                 input  logic    zero,
                  output logic    memtoreg, memwrite,
                 output logic    pcsrc, alusrc,
                  output logic    regdst, regwrite,
                  output logic    jump,
                  output logic  [2:0] alucontrol);

 logic [1:0] aluop;
 logic     branch;

logic RegWriteD, MemtoRegD, MemWriteD, BranchD, ALUCSrcD, RegDstD, JumpD;
logic [2:0] ALUControlD;
logic [9:0] DE;

logic RegWriteE, MemtoRegE, MemWriteE, BranchE, ALUCSrcE, RegDstE, JumpE;
logic [2:0] ALUControlE;
logic [4:0] EM;

logic RegWriteM, MemtoRegM, MemWriteM, BranchM, JumpM;
logic [1:0] MW;

logic PCSrcM;
logic ZeroM;

logic RegWriteW, MemtoRegW;

 maindec md(op, MemtoRegD, MemWriteD, branch, ALUSrcD, RegDstD, RegWriteD, JumpD, aluop);
 aludec ad(funct, aluop, ALUControlD);

assign BranchD = branch;
flopr #(10) DecodeExecute(clk, reset, {RegWriteD,MemtoRegD,MemWriteD, BranchD, ALUControlD, ALUCSrcD,RegDstD,JumpD}, DE);
assign RegWriteE = DE[9];
assign MemtoRegE = DE[8];
assign MemWriteE = DE[7];
assign BranchE = DE[6];
assign ALUControlE = DE[5:3];
assign ALUCSrcE = DE[2];
assign RegDstE = DE[1];
assign JumpE = DE[0];
assign regdst = RegDstE;
assign alucsrc = ALUCSrcE;
assign alucontrol = ALUControlE;
flopr #(5) ExecuteMemory(clk, reset, {RegWriteE, MemtoRegE, MemWriteE, BranchE,JumpE}, EM);
assign RegWriteM = EM[4];
assign MemtoRegM = EM[3];
assign MemWriteM = EM[2];
assign BranchM = EM[1];
assign JumpM = EM[0];
assign jump = JumpM;
assign ZeroM = zero;
assign PCSrcM = BranchM & ZeroM;
assign pcsrc = PCSrcM;
assign memwrite = MemWriteM;
flopr #(2) MemoryWriteback(clk, reset, {RegWriteM, MemtoRegM}, MW);
assign RegWriteW = MW[1];
assign MemtoRegW = MW[0];
assign regwrite = RegWriteW;
assign memtoreg = MemtoRegW;


endmodule


