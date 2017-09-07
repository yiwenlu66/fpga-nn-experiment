module netController(
    clk,
    reset,
    finish,
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,
    HEX6,
    HEX7,
    CE_N,
    OE_N,
    WE_N,
    LB_N,
    UB_N,
    sram_address,
    sram_data 
);
input clk;
input reset;
output finish;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;
output [6:0] HEX4;
output [6:0] HEX5;
output [6:0] HEX6;
output [6:0] HEX7;
output CE_N;
output OE_N;
output WE_N;
output LB_N;
output UB_N;
output [19:0] address;
inout [15:0] sram_data;

reg start;
reg alreadyStart;
reg finished;
wire [31:0] readData;
wire readEn;
wire [31:0] writeData;
wire writeEn;
wire [9:0] rate;
wire done;
wire [15:0] address;
reg [15:0] addressRW;
reg [2:0] batch_num = 0;
assign address = addressRW;
assign finish = finished;
always@(posedge clk)
begin
    if(!reset)
    begin
        start <= 0;
        batch_num <= 0;
        alreadyStart <= 0;
        finished <= 0;
    end
    else
    begin
        if(start == 0 && !finished)
        begin
            if(alreadyStart == 0)
                start <= 1; //start to train a batch
            else
                start <= 0;
        end
        if(done)
        begin
            if(batch_num < 4)
            begin 
                batch_num <= batch_num+1;
                alreadyStart <= 0;
            end
            else 
                finished <= 1;
        end 
    end
end
reg [3:0] addressCnt;
reg [9:0] addressAdd;
// calculate address
reg writeNext;
always@(posedge clk)
begin
    if(!reset)
        addressRW <= 0;
        addressCnt <= 0;
        iostart <= 0;
        addressAdd <= 1;
        startWrite <= 0;
        writeNext <= 0;
    else
    begin
        if(readEn)
        begin
            if(addressCnt == 8)
            begin
                addressCnt <= 0;
                addressAdd <= addressAdd + 1;
                addressRW <= 306*batch_num + addressAdd;
            end 
            addressCnt <= addressCnt + 1;
        end
        else if(writeEn)
        begin
            startWrite <= 1;
            if(addressCnt == 1)
            begin
                addressCnt <= 0;
            end 
           addressCnt <= addressCnt + 1;
           if(addressCnt == 0)
             write_data_half <= writeData[31:16];
           else
           begin 
               write_data_half <= writeData[15:0];
               writeNext <= 1;
           end 
            if(writeDone)
            begin 
                addressRW <= addressRW + 1;
                startWrite <= 0;
            end 

       end
        else
        begin 
            addressCnt <= 0;
            addressAdd <= 0;
            addressRW <= 0;
        end 
end 
assign readData = readDataWide[(addressCnt-1)*32+31:(addressCnt-1)*32];
assign writeData = writeDataWide[(addressCnt-1)*32+31:(addressCnt-1)*32];
logistic u1(
    .clk(clk),
    .rst(start),
    .readClk(clk),
    .readData(readData),
    .readEn(readEn),
    .writeData(writeData),
    .writeEn(writeEn),
    .writeClk(clk),
    .rate(rate),
    .done(done)
);
wire [255:0] readDataWide;
wire [255:0] writeDataWide;
RAM1 u2(
    .clk(clk),
    .data(writeDataWide),
    .rdaddress(address),
    .wraddress(addressW),
    .wren(writeEn),
    .q(readDataWide)
);
SEG7_LUT_8 u3(
    .oSEG0(HEX0),
    .oSEG1(HEX1),
    .oSEG2(HEX2),
    .oSEG3(HEX3),
    .oSEG4(HEX4),
    .oSEG5(HEX5),
    .oSEG6(HEX6),
    .oSEG7(HEX7),
    .iDIG({6'h0,rate,8'h0,8'h64}),
    .ON_OFF(8'b01110111)
);
reg [15:0] addressRam;
reg startWrite;
wire writeDone;
wire [15:0] addressRamW;
reg [15:0] write_data_half;
wire [15:0] read_data_unuse;
assign addressRamW = addressRam;
sram u4(
    .clk(clk),
    .rst_n(rst),
    .command(1'b0),
    .address(addressRamW),
    .byte_control(2'b00),
    .write_data(write_data_half),
    .read_data(read_data_unuse),
    .start(startWrite),
    .finish(writeDone),
    .CE_N(CE_N),
    .OE_N(OE_N),
    .WE_N(WE_N),
    .LB_N(LB_N),
    .sram_address(sram_address),
    .sram_data(sram_data)
);
endmodule 

