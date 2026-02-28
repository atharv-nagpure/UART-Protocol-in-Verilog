module receiver (clk, rst, data_in, data_out, rx_done);
input clk, rst, data_in;
output reg [7:0] data_out;
output reg rx_done;
wire rx_on;

//----- baud rate generator -----//

reg [8:0] cycle;
reg enable;

always @(posedge clk)
begin

    if (rst)
    begin
        cycle <= 0;
        enable <= 1'b0;
    end

    else if (cycle == 325)
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

assign rx_on = enable;

//----- receiver -----//

reg [2:0] count;
reg [7:0] data;
reg [3:0] sample;

reg [1:0] state;
parameter idle_state = 2'b00,
          start_state = 2'b01,
          data_state = 2'b10,
          stop_state = 2'b11;

always @(posedge clk)
begin
    rx_done <= 1'b0;
    if (rst)
    begin
        count <= 3'd0;
        sample <= 4'd0;
        data_out <= 8'd0;
        data <= 8'd0;
        state <= idle_state;
    end

    else
    begin
        case (state)
        idle_state : begin
                     sample <= 4'd0;
                     count <= 3'd0;
                     
                     if (data_in == 1'b0)
                     state <= start_state;
                     end

        start_state : begin
                      if (rx_on)
                      begin
                        sample <= sample + 1'b1;

                        if (sample == 4'd7)
                        begin
                            if (data_in == 1'b0)
                            begin
                                state <= data_state;
                                sample <= 4'd0;
                            end

                            else
                            begin
                                state <= idle_state;
                                sample <= 4'd0;
                            end
                        end
                      end
                      end

        data_state : begin
                     if (rx_on)
                     begin
                        sample <= sample + 1'b1;

                        if (sample == 4'd15)
                        begin
                            sample <= 4'd0;
                            data[count] <= data_in;

                            if (count == 3'd7)
                            begin
                                count <= 0;
                                state <= stop_state;
                            end
                            else
                            count <= count + 1'b1;
                        end

                     end
                     end
                        

        stop_state :begin
                     if (rx_on)
                     begin
                        sample <= sample + 1'b1;

                        if (sample == 4'd15)
                        begin
                            sample <= 4'd0;
                            if (data_in == 1'b1)
                            begin
                                data_out <= data;
                                rx_done <= 1'b1;
                            end
                            state <= idle_state;
                        end

                     end
                     end
        
        default : begin
                  state <= idle_state;
                  count <= 3'd0;
                  sample <= 4'd0;
                  data_out <= 8'd0;
                  end

        endcase

    end
end

endmodule