module sync_fifo #(
    parameter int WIDTH_DATA = 8,
    parameter int DEPTH_FIFO = 16,
    parameter int WIDTH_ADDR = $clog2(DEPTH_FIFO)
) (
    input                   clk,
    input                   rstn,
    input                   cmd_push,
    input                   cmd_pop,
    input  [WIDTH_DATA-1:0] data_push,
    output [WIDTH_DATA-1:0] data_pop,
    output                  flag_empty,
    output                  flag_full
);
  wire [WIDTH_ADDR-1:0] addr_write, addr_read;
  wire enable_write;

  sync_fifo_controller #(
      .WIDTH_DATA(WIDTH_DATA),
      .DEPTH_FIFO(DEPTH_FIFO)
  ) u_controller (
      .*
  );
  sync_fifo_buffer #(
      .WIDTH_DATA(WIDTH_DATA),
      .DEPTH_FIFO(DEPTH_FIFO)
  ) u_buffer (
      .*
  );
endmodule

module sync_fifo_controller #(
    parameter int WIDTH_DATA = 8,
    parameter int DEPTH_FIFO = 16,
    parameter int WIDTH_ADDR = $clog2(DEPTH_FIFO)
) (
    input                   clk,
    input                   rstn,
    input                   cmd_push,
    input                   cmd_pop,
    output [WIDTH_ADDR-1:0] addr_write,
    output [WIDTH_ADDR-1:0] addr_read,
    output                  flag_empty,
    output                  flag_full,
    output                  enable_write
);
  logic [WIDTH_ADDR-1:0] c_ptr_write, n_ptr_write;
  logic [WIDTH_ADDR-1:0] c_ptr_read, n_ptr_read;
  logic c_phase_write, n_phase_write;
  logic c_phase_read, n_phase_read;

  assign addr_write = c_ptr_write;
  assign addr_read  = c_ptr_read;

  always_ff @(negedge rstn or posedge clk) begin
    if (!rstn) begin
      c_ptr_read    <= 0;
      c_ptr_write   <= 0;
      c_phase_read  <= 0;
      c_phase_write <= 0;
    end else begin
      c_ptr_read    <= n_ptr_read;
      c_ptr_write   <= n_ptr_write;
      c_phase_read  <= n_phase_read;
      c_phase_write <= n_phase_write;
    end
  end

  always_comb begin : ptr_write_logic
    n_ptr_write   = c_ptr_write;
    n_phase_write = c_phase_write;
    if (cmd_push && !flag_full) begin
      if (c_ptr_write == DEPTH_FIFO - 1) begin
        n_ptr_write   = 0;
        n_phase_write = ~c_phase_write;
      end else begin
        n_ptr_write   = c_ptr_write + 1;
        n_phase_write = c_phase_write;
      end
    end
  end

  always_comb begin : ptr_read_logic
    n_ptr_read   = c_ptr_read;
    n_phase_read = c_phase_read;
    if (cmd_pop && !flag_empty) begin
      if (c_ptr_read == DEPTH_FIFO - 1) begin
        n_ptr_read   = 0;
        n_phase_read = ~c_phase_read;
      end else begin
        n_ptr_read   = c_ptr_read + 1;
        n_phase_read = c_phase_read;
      end
    end
  end

  assign flag_full = (c_phase_read != c_phase_write) && (c_ptr_read == c_ptr_write);
  assign flag_empty = (c_phase_read == c_phase_write) && (c_ptr_read == c_ptr_write);
  assign enable_write = cmd_push & (~flag_full);
endmodule

module sync_fifo_buffer #(
    parameter int WIDTH_DATA = 8,
    parameter int DEPTH_FIFO = 16,
    parameter int WIDTH_ADDR = $clog2(DEPTH_FIFO)
) (
    input                   clk,
    input                   enable_write,
    input  [WIDTH_ADDR-1:0] addr_write,
    input  [WIDTH_ADDR-1:0] addr_read,
    input  [WIDTH_DATA-1:0] data_push,
    output [WIDTH_DATA-1:0] data_pop
);

  logic [WIDTH_DATA-1:0] buffer[DEPTH_FIFO];

  always_ff @(posedge clk) begin
    if (enable_write) begin
      buffer[addr_write] <= data_push;
    end
  end
  assign data_pop = buffer[addr_read];
endmodule
