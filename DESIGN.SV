`timescale 1ns/1ps

// ============================================================
// 4-LINE DIRECT-MAPPED CACHE MEMORY
// My Fifth VLSI RTL Design Project
// Designed by: SHAIK ZAIBA FARAAZ
// ============================================================

module cache_memory (
    input  logic       clk,
    input  logic       reset,

    input  logic       read_en,
    input  logic       write_en,

    input  logic [3:0] address,
    input  logic [7:0] write_data,

    output logic [7:0] read_data,
    output logic       ready,
    output logic       hit,
    output logic       miss,

    output logic [31:0] total_accesses,
    output logic [31:0] hit_count,
    output logic [31:0] miss_count
);

    // --------------------------------------------------------
    // Cache organization
    // --------------------------------------------------------
    // Address = [TAG][INDEX]
    //
    // 4-bit address:
    // [3:2] = TAG
    // [1:0] = INDEX
    //
    // 4 cache lines
    // 8-bit data per line
    // --------------------------------------------------------

    logic [7:0] cache_data [0:3];
    logic [1:0] cache_tag  [0:3];
    logic       valid_bit  [0:3];

    // Main memory: 16 locations x 8 bits
    logic [7:0] main_memory [0:15];

    logic [1:0] index;
    logic [1:0] tag;

    assign index = address[1:0];
    assign tag   = address[3:2];

    integer i;

    // --------------------------------------------------------
    // Cache Controller
    // --------------------------------------------------------

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            read_data     <= 8'h00;
            ready         <= 1'b0;
            hit           <= 1'b0;
            miss          <= 1'b0;

            total_accesses <= 32'd0;
            hit_count      <= 32'd0;
            miss_count     <= 32'd0;

            for (i = 0; i < 4; i = i + 1) begin
                cache_data[i] <= 8'h00;
                cache_tag[i]  <= 2'b00;
                valid_bit[i]  <= 1'b0;
            end

            // Initialize main memory
            main_memory[0]  <= 8'h10;
            main_memory[1]  <= 8'h20;
            main_memory[2]  <= 8'h30;
            main_memory[3]  <= 8'h40;
            main_memory[4]  <= 8'h50;
            main_memory[5]  <= 8'h60;
            main_memory[6]  <= 8'h70;
            main_memory[7]  <= 8'h80;
            main_memory[8]  <= 8'h90;
            main_memory[9]  <= 8'hA0;
            main_memory[10] <= 8'hB0;
            main_memory[11] <= 8'hC0;
            main_memory[12] <= 8'hD0;
            main_memory[13] <= 8'hE0;
            main_memory[14] <= 8'hF0;
            main_memory[15] <= 8'hFF;

        end

        else begin

            // Default output values every clock
            ready <= 1'b0;
            hit   <= 1'b0;
            miss  <= 1'b0;

            // ------------------------------------------------
            // READ OPERATION
            // ------------------------------------------------

            if (read_en) begin

                total_accesses <= total_accesses + 1;

                // Cache HIT
                if (valid_bit[index] &&
                    cache_tag[index] == tag) begin

                    read_data <= cache_data[index];

                    hit       <= 1'b1;
                    miss      <= 1'b0;
                    ready     <= 1'b1;

                    hit_count <= hit_count + 1;

                end

                // Cache MISS
                else begin

                    read_data <= main_memory[address];

                    cache_data[index] <= main_memory[address];
                    cache_tag[index]  <= tag;
                    valid_bit[index]  <= 1'b1;

                    hit   <= 1'b0;
                    miss  <= 1'b1;
                    ready <= 1'b1;

                    miss_count <= miss_count + 1;
                end

            end

            // ------------------------------------------------
            // WRITE OPERATION
            // ------------------------------------------------

            else if (write_en) begin

                total_accesses <= total_accesses + 1;

                // Write-through:
                // Always update main memory
                main_memory[address] <= write_data;

                // If cache contains the address,
                // update cache also.
                if (valid_bit[index] &&
                    cache_tag[index] == tag) begin

                    cache_data[index] <= write_data;

                    hit       <= 1'b1;
                    miss      <= 1'b0;
                    ready     <= 1'b1;

                    hit_count <= hit_count + 1;

                end

                else begin

                    hit   <= 1'b0;
                    miss  <= 1'b1;
                    ready <= 1'b1;

                    miss_count <= miss_count + 1;
                end

            end
        end
    end

endmodule
