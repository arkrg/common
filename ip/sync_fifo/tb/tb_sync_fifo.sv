module tb_sync_fifo ();
  parameter int WIDTH_DATA = 8;
  parameter int DEPTH_FIFO = 16;
  logic clk, rstn, cmd_push, cmd_pop, flag_empty, flag_full;

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
    rstn = 1;
    fd   = $fopen("rtl_result.txt", "w");
    #10;
    rstn = 0;
    fork
      model_front();
      model_reel();
    join_any
    $fclose(fd);
    $finish;
  end

  task automatic model_front();
    int run_time;
    while (run_time < 100)
      @(posedge clk) begin
        data_push = run_time;
        cmd_push  = $urandom % 2;  // 0~1
        run_time++;
      end
  endtask
  task automatic model_reel();
    forever
      @(posedge clk) begin
        cmd_pop = $urandom % 2;  // 0~1
      end
  endtask
  task automatic logger();
    forever
      @(posedge cmd_pop) begin
        $fwrite(fd, "data = %d/n", data_pop);
      end
  endtask

  initial begin
    $dump_file("waves.vcd");
    $dump_vars();
  end
endmodule
