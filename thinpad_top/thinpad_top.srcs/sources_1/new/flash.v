module flash(
    input              wb_clk_i,
    input              wb_rst_i,
    input      [31: 0] wb_adr_i,
    input      [ 3: 0] wb_sel_i,
    input              wb_we_i,
    input      [31: 0] wb_dat_i,
    input              wb_stb_i,
    input              wb_cyc_i,
    output reg         wb_ack_o,
    output reg [31: 0] wb_dat_o,
    output reg [22:0] flash_adr_o, 
    inout   [15:0] flash_dat_io, 
    output wire flash_byte,
    output wire flash_ce,
    output reg flash_oe,
    output wire flash_rp,
    output wire flash_vpen,
    output wire flash_we
);
    // Wishbone read/write accesses
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_rd  = wb_acc & ~wb_we_i;      // WISHBONE read access

    assign flash_byte = 1;
    assign flash_vpen = 1;
    assign flash_we = 1;
    assign flash_ce = ~wb_acc;
    assign flash_oe = !wb_rd;
    assign flash_rp = !wb_rst_i;
    
    assign flash_dat_io = {16{1'bz}};

    reg [3:0] waitstate;            

    
    always @(posedge wb_clk_i) begin
        if( wb_rst_i == 1'b1 ) begin
            waitstate <= 4'h0;
            wb_ack_o <= 1'b0;
        end else if(wb_acc == 1'b0) begin
            waitstate <= 4'h0;
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'h00000000;
        end else if(waitstate == 4'h0) begin
            wb_ack_o <= 1'b0;
            if (wb_acc) begin
                waitstate <= waitstate + 4'h1;
            end
            flash_adr_o <= {wb_adr_i[21:1],1'b0};
        end else begin
            waitstate <= waitstate + 4'h1;
            if (waitstate == 4'he) begin
                wb_ack_o <= 1'b1;
                wb_dat_o <= {{16{1'b0}}, flash_dat_io};
            end else if(waitstate == 4'hf) begin
                waitstate <= 4'h0;
                wb_ack_o <= 1'b0;
            end
        end
    end
endmodule
