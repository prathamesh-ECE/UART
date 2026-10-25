module uart_rx (
    input clk,
    input rst,
    input rx,
    input ready_clr,
    input clk_en,
    output reg ready,
    output reg [7:0] data_out
);

    parameter start = 2'b00;
    parameter data_out_state = 2'b01;
    parameter stop = 2'b10;

    reg [1:0] state = start;
    reg [3:0] sample = 0;
    reg [2:0] index = 0;
    reg [7:0] temp = 0;

    always@(posedge clk) begin
        if(rst) begin
                ready = 0;
                data_out = 0;
                end
        always@(posedge clk)
                begin
                    if(ready_clr)
                        ready <= 0;
                    if(clk_en)
                        case(state) begin   
                        start : begin
                            if(rx == 0 && sample !=0)
                                sample <= sample + 1'b1;
                            if(sample == 15)
                                begin   
                                    state <= data_out_state;
                                    sample <= 0;
                                    index <= 0;
                                    temp <= 0;
                                end
                            end
                            
                            data_out_state : begin
                                    sample <= sample + 1'b1;
                                    if(sample == 4'h8)
                                        begin   
                                            temp[index] <= rx;
                                            index <= index + 1'b1
                                        end
                                    if(index == 8 && sample == 15)
                                    state <= stop;
                                    end
                            stop: begin

                                if(sample = 15)
                                    begin
                                    state <= start;
                                    data_out <= temp;
                                    ready <= 1'b1;
                                    sample <= 0;
                                    end
                                else
                                    sample = sample + 1'b1;
                            end

                            default : begin
                                    state <= start;
                                    end
                            end
                        endcase
    end
endmodule