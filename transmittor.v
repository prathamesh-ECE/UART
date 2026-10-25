module transimt(
    input clk, wr_en, rst enb,
    input [7:0] data_in,
    output tx, busy
);
parameter ideal = 2'b00; start = 2'b01; data = 2'b10; stop = 2'b11;
reg [7:0] data;
reg [2:0] index;
reg [1:0] state = ideal_state;

always@(posedge clk)
    begin
      if(rst)
            tx = 1'b1;
    end
always@(posedge clk)
    begin
        case(state)
            ideal : begin 
                    if(wr_en) begin
                      state <= start;
                      data <= data_in;
                      index <= 1'b0;
                    end
                    else   
                        state <= ideal;
                    end
            start : begin 
                    if(enb) begin
                            tx <= 1'b0;
                            state <= data;
                        end
                    else    
                        state <= start;
                    end
            data : begin
                    if(enb) begin
                        if(index == 3'h7)
                            state <= stop;
                        else    
                            index <= index + 3'h1;
                            tx<= data[index];
                            end
                    end
            stop : begin
                    if(enb)
                            begin   
                            tx<= 1'b1;
                            state<= ideal;
                            end
                    end
            default : begin
                        tx <= 1'b1;
                        state <= stop;
                    end
            endcase
        end
assign busy = (state != ideal) ? 1'b0:1'b1;
endmodule