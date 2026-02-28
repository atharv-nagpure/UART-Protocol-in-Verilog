module transmitter (data_out, tx_active, clk, rst, write, data_in);
input clk, rst, write;
input [7:0] data_in;
output reg data_out;
output tx_active;
wire tx_on;

//----- baud rate of transmitter -----//

reg [12:0] cycle;
reg enable;

always @(posedge clk)
begin

    if (rst)
    begin
        cycle <= 0;
        enable <= 1'b0;
    end

    else if (cycle == 5207)
    begin
        cycle <= 0;
        enable <= 1'b1;
    end

    else
    begin
        cycle <= cycle + 1'b1;
        enable <= 1'b0;
    end

end

assign tx_on = enable;

//----- transmitter -----//

reg [2:0] count;
reg [7:0] data;

reg [1:0] state;
parameter idle_state = 2'b00,
          start_state = 2'b01,
          data_state = 2'b10,
          stop_state = 2'b11;

always @(posedge clk)
begin
    if (rst)
    begin
        data_out <= 1'b1;
        state <= idle_state;
        count <= 3'd0;

    end

    else
    begin
        case (state)
        idle_state : begin
                     data_out <= 1'b1;
                     count <= 3'd0;
                     if (write)
                     begin
                     state <= start_state;
                     data <= data_in;
                     end
                     end

        start_state : begin
                      if (tx_on)
                      begin
                      state <= data_state;
                      data_out <= 1'b0;
                      end
                      end

        data_state : begin
                     if (tx_on)
                     begin
                        data_out <= data[count];

                        if (count == 3'd7)
                        begin
                            count <= 3'd0;
                            state <= stop_state;
                        end

                        else
                            count <= count + 1'b1;
                     end
                     end

        stop_state : begin
                     data_out <= 1'b1;

                     if (tx_on)
                     state <= idle_state;

                     end
        
        default : begin
                  data_out <= 1'b1;
                  state <= idle_state;
                  end

        endcase
    end
end


assign tx_active = (state != idle_state) ? 1'b1 : 1'b0;
endmodule