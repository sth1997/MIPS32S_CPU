module clk_master (
    input wire clk_50m_i,
    input wire clk_11m_i,
    output reg clk_o
);

    reg clk_25m;
    reg clk_12_5m;
    reg clk_6m;
    reg clk_3m;

    reg[2:0] inner_clk_counter;

    always @ ( posedge clk_50m_i ) begin
        clk_25m <= ~clk_25m;
        inner_clk_counter <= inner_clk_counter + 1;
        if (inner_clk_counter[0] == 0) clk_12_5m <= ~clk_12_5m;
        if (inner_clk_counter[1:0] == 0) clk_6m <= ~clk_6m;
        if (inner_clk_counter[2:0] == 0) clk_3m <= ~clk_3m;
    end

    always @ ( * ) begin
        clk_o = clk_12_5m;
    end


endmodule // clk_master
