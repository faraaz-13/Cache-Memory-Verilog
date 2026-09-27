`timescale 1ns/1ps

// ============================================================
// CACHE MEMORY TESTBENCH
// My Fifth VLSI RTL Design Project
// Designed by: SHAIK ZAIBA FARAAZ
// ============================================================

module testbench;

    logic clk;
    logic reset;

    logic read_en;
    logic write_en;

    logic [3:0] address;
    logic [7:0] write_data;

    logic [7:0] read_data;
    logic ready;
    logic hit;
    logic miss;

    logic [31:0] total_accesses;
    logic [31:0] hit_count;
    logic [31:0] miss_count;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    // --------------------------------------------------------
    // Clock
    // --------------------------------------------------------

    always #5 clk = ~clk;

    // --------------------------------------------------------
    // DUT
    // --------------------------------------------------------

    cache_memory dut (

        .clk(clk),
        .reset(reset),

        .read_en(read_en),
        .write_en(write_en),

        .address(address),
        .write_data(write_data),

        .read_data(read_data),
        .ready(ready),
        .hit(hit),
        .miss(miss),

        .total_accesses(total_accesses),
        .hit_count(hit_count),
        .miss_count(miss_count)
    );

    // --------------------------------------------------------
    // Waveform
    // --------------------------------------------------------

    initial begin
        $dumpfile("cache_waveform.vcd");
        $dumpvars(0, testbench);
    end

    // --------------------------------------------------------
    // READ TEST TASK
    // --------------------------------------------------------

    task read_test;

        input [3:0] test_address;
        input [7:0] expected_data;
        input       expected_hit;

        begin

            total_tests = total_tests + 1;

            @(negedge clk);

            address  = test_address;
            read_en  = 1'b1;
            write_en = 1'b0;

            @(posedge clk);

            #1;

            read_en = 1'b0;

            if ((read_data == expected_data) &&
                (hit == expected_hit)) begin

                passed_tests = passed_tests + 1;

                $display(
                    "TEST %0d : READ ADDR=%0d DATA=%02h HIT=%b MISS=%b : PASS",
                    total_tests,
                    test_address,
                    read_data,
                    hit,
                    miss
                );

            end

            else begin

                failed_tests = failed_tests + 1;

                $display(
                    "TEST %0d : READ ADDR=%0d DATA=%02h HIT=%b MISS=%b : FAIL",
                    total_tests,
                    test_address,
                    read_data,
                    hit,
                    miss
                );

            end

            @(negedge clk);

        end

    endtask

    // --------------------------------------------------------
    // WRITE TEST TASK
    // --------------------------------------------------------

    task write_test;

        input [3:0] test_address;
        input [7:0] test_data;
        input       expected_hit;

        begin

            total_tests = total_tests + 1;

            @(negedge clk);

            address   = test_address;
            write_data = test_data;

            read_en  = 1'b0;
            write_en = 1'b1;

            @(posedge clk);

            #1;

            write_en = 1'b0;

            if ((hit == expected_hit) &&
                (miss == ~expected_hit)) begin

                passed_tests = passed_tests + 1;

                $display(
                    "TEST %0d : WRITE ADDR=%0d DATA=%02h HIT=%b MISS=%b : PASS",
                    total_tests,
                    test_address,
                    test_data,
                    hit,
                    miss
                );

            end

            else begin

                failed_tests = failed_tests + 1;

                $display(
                    "TEST %0d : WRITE ADDR=%0d DATA=%02h HIT=%b MISS=%b : FAIL",
                    total_tests,
                    test_address,
                    test_data,
                    hit,
                    miss
                );

            end

            @(negedge clk);

        end

    endtask

    // --------------------------------------------------------
    // MAIN TEST SEQUENCE
    // --------------------------------------------------------

    initial begin

        clk = 1'b0;

        reset = 1'b1;

        read_en  = 1'b0;
        write_en = 1'b0;

        address   = 4'd0;
        write_data = 8'h00;

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        // Reset
        #20;

        reset = 1'b0;

        #10;

        // ----------------------------------------------------
        // TEST 1
        // Address 0
        // First access -> MISS
        // Main memory[0] = 10
        // ----------------------------------------------------

        read_test(4'd0, 8'h10, 1'b0);

        // ----------------------------------------------------
        // TEST 2
        // Address 0
        // Same address -> HIT
        // ----------------------------------------------------

        read_test(4'd0, 8'h10, 1'b1);

        // ----------------------------------------------------
        // TEST 3
        // Address 4
        // Same cache index as address 0
        // Different tag -> MISS
        // Main memory[4] = 50
        // ----------------------------------------------------

        read_test(4'd4, 8'h50, 1'b0);

        // ----------------------------------------------------
        // TEST 4
        // Address 0
        // Address 0 was replaced by address 4
        // Therefore -> MISS
        // ----------------------------------------------------

        read_test(4'd0, 8'h10, 1'b0);

        // ----------------------------------------------------
        // TEST 5
        // Address 0
        // Same address -> HIT
        // Write AA
        // ----------------------------------------------------

        write_test(4'd0, 8'hAA, 1'b1);

        // ----------------------------------------------------
        // TEST 6
        // Read address 0
        // Should return AA -> HIT
        // ----------------------------------------------------

        read_test(4'd0, 8'hAA, 1'b1);

        // ----------------------------------------------------
        // TEST 7
        // Address 1
        // New cache index -> MISS
        // Main memory[1] = 20
        // ----------------------------------------------------

        read_test(4'd1, 8'h20, 1'b0);

        // ----------------------------------------------------
        // FINAL SUMMARY
        // ----------------------------------------------------

        #20;

        $display("");
        $display("==============================================");
        $display("        CACHE VERIFICATION SUMMARY");
        $display("==============================================");

        $display("TOTAL TESTS     : %0d", total_tests);
        $display("PASSED TESTS    : %0d", passed_tests);
        $display("FAILED TESTS    : %0d", failed_tests);

        $display("");

        $display("TOTAL ACCESSES  : %0d", total_accesses);
        $display("CACHE HITS      : %0d", hit_count);
        $display("CACHE MISSES    : %0d", miss_count);

        $display("");

        if (total_accesses != 0)
            $display(
                "HIT RATE        : %0.2f%%",
                (hit_count * 100.0) / total_accesses
            );
        else
            $display("HIT RATE        : 0.00%%");

        $display("");

        if (failed_tests == 0)
            $display("RESULT          : ALL TESTS PASSED");
        else
            $display("RESULT          : SOME TESTS FAILED");

        $display("==============================================");

        $finish;

    end

endmodule
