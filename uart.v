module uart (clk, rst, write, rx, data_in, tx, data_out, done);
input clk, rst, write, rx;
input [7:0] data_in;
output [7:0] data_out;
output done, tx;

wire tx_busy;

transmitter TX (.clk(clk), 
                .rst(rst), 
                .write(write), 
                .data_in(data_in), 
                .data_out(tx), 
                .tx_active(tx_busy) );

receiver RX (.clk(clk),
             .rst(rst),
             .data_in(rx),
             .data_out(data_out),
             .rx_done(done));

endmodule
