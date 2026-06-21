module tb_sync_fifo ();
  parameter int WIDTH_DATA = 8;
  parameter int DEPTH_FIFO = 16;
  logic clk, rstn, cmd_push, cmd_pop, flag_empty, flag_full;
  logic [WIDTH_DATA-1:0] data_push, data_pop;
  logic [WIDTH_DATA-1:0] expected_queue[$];

  integer fd;
  sync_fifo #(
      .WIDTH_DATA(WIDTH_DATA),
      .DEPTH_FIFO(DEPTH_FIFO)
  ) dut (
      .clk,
      .rstn,
      .cmd_push,
      .cmd_pop,
      .data_push,
      .data_pop,
      .flag_empty,
      .flag_full
  );
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    rstn = 0;
    cmd_push = 0;
    cmd_pop = 0;
    fd = $fopen("rtl_result.txt", "w");
    #10;
    rstn = 1;
    fork
      model_front();
      model_reel();
      scoreboard();
    join_any
    $fclose(fd);
    $finish;
  end

  task automatic model_front();
    int run_time;
    while (run_time <= 100) begin
      @(posedge clk);
      cmd_push  <= $urandom % 2;  // 0~1
      data_push <= $urandom;
      if (cmd_push && !flag_full) begin
        run_time++;
      end
    end
  endtask

  task automatic model_reel();
    forever
      @(posedge clk) begin
        if (!flag_empty) cmd_pop = $urandom % 2;  // 0~1
        else cmd_pop = 0;
      end
  endtask
  task automatic scoreboard();
    logic [WIDTH_DATA-1:0] exp_data;
    forever
      @(negedge clk) begin
        if (cmd_push && !flag_full) begin
          $display("push %d", data_push);
          expected_queue.push_back(data_push);
        end
        if (cmd_pop & !flag_empty) begin
          exp_data = expected_queue.pop_front();
          if (data_pop === exp_data) begin
            $fwrite(fd, "[PASS] data = %d\n", data_pop);
            $display("[PASS]data = %d", data_pop);
          end else begin
            $fwrite(fd, "[FAIL] data = %d, exp_data = %d\n", data_pop, exp_data);
            $display("[FAIL] data = %d, exp_data = %d", data_pop, exp_data);
            $finish;
          end

        end
      end
  endtask

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars();
  end
endmodule
