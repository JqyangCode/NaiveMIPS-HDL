`default_nettype none
//`define EXT_UART_CLOCK
//`define STEP_CPU_CLOCK
//`define HS_DIFF_OUT
module soc_toplevel(/*autoport*/
//inout
            base_ram_data,
            ext_ram_data,
            flash_data,
            usb_data,
            gpio1,
            mdio,
            cfg_flash_mosi,
            cfg_flash_miso,
            cfg_flash_ss,
//output
`ifdef HS_DIFF_OUT
            clkout1_p,
            clkout1_n,
            dataout1_p,
            dataout1_n,
`endif
            base_ram_addr,
            base_ram_be,
            base_ram_ce_n,
            base_ram_oe_n,
            base_ram_we_n,
            ext_ram_addr,
            ext_ram_be,
            ext_ram_ce_n,
            ext_ram_oe_n,
            ext_ram_we_n,
            txd,
            flash_address,
            flash_rp_n,
            flash_vpen,
            flash_oe_n,
            flash_ce,
            flash_byte_n,
            flash_we_n,
            uart_rdn,
            uart_wrn,
            usb_a0,
            usb_a1,
            usb_we_n,
            usb_rd_n,
            usb_cs_n,
            usb_rst_n,
            usb_dack,
            leds,
            dpy_com,
            dpy_seg,
            vga_pixel,
            vga_hsync,
            vga_vsync,
            vga_clk,
            vga_de,
            vga_sync_n,
            vga_psave_n,
            mdc,
            MII_rst_n,
            MII_tx_en,
            MII_txd,
//input
            clk_in,
            clk_uart_in,
            rxd,
            touch_btn,
            usb_int,
            usb_drq,
            MII_col,
            MII_crs,
            MII_rx_clk,
            MII_rx_dv,
            MII_rx_er,
            MII_rxd,
            MII_tx_clk);

input wire clk_in;

wire locked,rst_n;
wire clk, clk_pll;
wire clk_ram, clk_ram_pll;
wire clk_uart, clk_uart_pll;
wire clk_tick;

input wire clk_uart_in;
`ifdef EXT_UART_CLOCK
assign clk_uart = clk_uart_in;
`else
assign clk_uart = clk_uart_pll;
`endif
`ifdef STEP_CPU_CLOCK
assign clk = touch_btn[4];
assign clk_ram = touch_btn[4];
`else
assign clk = clk_pll;
assign clk_ram = clk_ram_pll;
`endif

sys_pll pll1(
    .areset(~touch_btn[5]),
    .inclk0(clk_in),
    .c0(clk_pll),
    .c1(clk_ram_pll),
    .c2(clk_uart_pll),
    .c3(clk_tick),
    .locked(locked));
clk_ctrl clk_ctrl1(/*autoinst*/
         .rst_out_n(rst_n),
         .clk(clk),
         .rst_in_n(locked));

`ifdef HS_DIFF_OUT
output  wire       clkout1_p,  clkout1_n;          // lvds channel 1 clock output
output  wire[3:0]   dataout1_p, dataout1_n;         // lvds channel 1 data outputs
`endif

inout wire[31:0] base_ram_data;
output wire[19:0] base_ram_addr;
output wire[3:0] base_ram_be;
output wire base_ram_ce_n;
output wire base_ram_oe_n;
output wire base_ram_we_n;

inout wire[31:0] ext_ram_data;
output wire[19:0] ext_ram_addr;
output wire[3:0] ext_ram_be;
output wire ext_ram_ce_n;
output wire ext_ram_oe_n;
output wire ext_ram_we_n;

wire[29:0] ram_address;
wire ram_ext_ce_n;
wire ram_wr_n;
(* MAX_FANOUT = 16 *) wire ram_io_t;
wire ram_rd_n;
wire[3:0] ram_dataenable_n;
wire[31:0] ram_data_i, ram_data_o;

output wire txd;
input wire rxd;

output wire [21:0]flash_address;
output wire flash_rp_n;
output wire flash_vpen;
output wire flash_oe_n;
inout wire [15:0]flash_data;
output wire [2:0]flash_ce;
output wire flash_byte_n;
output wire flash_we_n;

output wire usb_a0;
output wire usb_a1;
inout  wire [15:0] usb_data;
output wire usb_we_n;
output wire usb_rd_n;
output wire usb_cs_n;
output wire usb_rst_n;
output wire usb_dack;
input  wire usb_int;
input  wire usb_drq;

wire[31:0] gpio0;
inout wire[31:0] gpio1;
output wire[15:0] leds;
output wire[7:0] dpy_com;
output wire[7:0] dpy_seg;

input wire[5:0] touch_btn;

output wire[7:0] vga_pixel;
output wire vga_hsync;
output wire vga_vsync;
output wire vga_clk;
output wire vga_de;
output wire vga_sync_n;
output wire vga_psave_n;

output wire mdc;
inout wire mdio;
input wire MII_col;
input wire MII_crs;
output wire MII_rst_n;
input wire MII_rx_clk;
input wire MII_rx_dv;
input wire MII_rx_er;
input wire [3:0]MII_rxd;
input wire MII_tx_clk;
output wire MII_tx_en;
output wire [3:0]MII_txd;

wire mdio_o;
wire mdio_t;
wire mdio_i;

inout wire cfg_flash_mosi;
inout wire cfg_flash_miso;
inout wire cfg_flash_ss;

wire mosi_i;
wire mosi_o;
wire mosi_t;
wire miso_i;
wire miso_o;
wire miso_t;
wire ss_i;
wire ss_o;
wire ss_t;

output uart_wrn;
output uart_rdn;

wire uart_wrn = 1'b1;
wire uart_rdn = 1'b1;

wire[4:0] irq_line;
wire uart_irq;

wire dbus_write;
wire [31:0]dbus_rddata;
wire ibus_read;
wire [3:0]ibus_byteenable;
wire [3:0]dbus_byteenable;
wire [31:0]dbus_wrdata;
wire [31:0]ibus_wrdata;
wire ibus_write;
wire dbus_read;
wire [31:0]ibus_rddata;
wire [31:0]dbus_address;
wire [31:0]ibus_address;
wire dbus_stall;
wire ibus_stall;

wire [31:0]rom_data;
wire [12:0]rom_address;

wire [23:0]ibus_ram_address;
wire [31:0]ibus_ram_rddata;
wire [31:0]ibus_ram_wrdata;
wire [3:0]ibus_ram_byteenable;
wire ibus_ram_read;
wire ibus_ram_write;
wire ibus_ram_stall;

wire [23:0]dbus_ram_address;
wire [31:0]dbus_ram_rddata;
wire [31:0]dbus_ram_wrdata;
wire [3:0]dbus_ram_byteenable;
wire dbus_ram_read;
wire dbus_ram_write;
wire dbus_ram_stall;

wire [31:0]uart_data_o;
wire [31:0]uart_data_i;
wire [3:0]uart_address;
wire uart_read;
wire uart_write;

wire [31:0]flash_dbus_data_o;
wire [31:0]flash_dbus_data_i;
wire [23:0]flash_dbus_address;
wire [3:0]flash_dbus_data_enable;
wire flash_dbus_read;
wire flash_dbus_write;
wire flash_dbus_stall;

wire [31:0]usb_dbus_data_o;
wire [31:0]usb_dbus_data_i;
wire [2:0]usb_dbus_address;
wire usb_dbus_read;
wire usb_dbus_write;
wire usb_dbus_stall;
wire usb_irq;

wire [31:0]gpio_dbus_data_o;
wire [31:0]gpio_dbus_data_i;
wire [7:0]gpio_dbus_address;
wire gpio_dbus_read;
wire gpio_dbus_write;

wire [31:0]gpu_dbus_data_o;
wire [31:0]gpu_dbus_data_i;
wire [23:0]gpu_dbus_address;
wire gpu_dbus_read;
wire gpu_dbus_write;

wire [31:0]net_dbus_data_o;
wire [31:0]net_dbus_data_i;
wire [15:0]net_dbus_address;
wire net_dbus_read;
wire net_dbus_write;
wire net_dbus_stall;
wire net_irq;

wire [31:0]cfg_flash_dbus_data_o;
wire [31:0]cfg_flash_dbus_data_i;
wire [23:0]cfg_flash_dbus_address;
wire cfg_flash_dbus_read;
wire cfg_flash_dbus_write;
wire cfg_flash_dbus_stall;

wire [31:0]ticker_dbus_data_o;
wire [31:0]ticker_dbus_data_i;
wire [7:0]ticker_dbus_address;
wire ticker_dbus_read;
wire ticker_dbus_write;

assign base_ram_ce_n = ram_address[22];
assign base_ram_oe_n = ram_rd_n;
assign base_ram_we_n = ram_wr_n;
assign base_ram_addr = ram_address[21:2];
assign base_ram_data = ram_io_t ? {32{1'hz}} : ram_data_o;
assign base_ram_be = ram_dataenable_n;

assign ext_ram_ce_n = ram_ext_ce_n;
assign ext_ram_oe_n = ram_rd_n;
assign ext_ram_we_n = ram_wr_n;
assign ext_ram_addr = ram_address[21:2];
assign ext_ram_data  = ram_io_t ? {32{1'hz}} : ram_data_o;
assign ext_ram_be = ram_dataenable_n;

//assign vga_clk = clk_in;
assign vga_sync_n = 1'b0;
assign vga_psave_n = 1'b1;

//assign leds = gpio0[15:0];

clk_vga clk_vga_0(.clk_in1(clk_in), .clk_out1(vga_clk));

seg_disp seg7(
    .clk(clk),
    .din(gpio0),
    .seg(dpy_seg),
    .com(dpy_com)
);

ibus ibus0(/*autoinst*/
         .master_rddata(ibus_rddata),
         .bootrom_address(rom_address),
         .ram_address(ibus_ram_address),
         .ram_data_i(ibus_ram_wrdata),
         .ram_data_enable(ibus_ram_byteenable),
         .ram_rd(ibus_ram_read),
         .ram_wr(ibus_ram_write),
         .ram_stall(ibus_ram_stall),
         .master_address(ibus_address),
         .master_byteenable(ibus_byteenable),
         .master_read(ibus_read),
         .master_write(ibus_write),
         .master_wrdata(ibus_wrdata),
         .master_stall(ibus_stall),
         .bootrom_data_o(rom_data),
         .ram_data_o(ibus_ram_rddata));

bootrom rom(
        .address(rom_address[12:2]),
        .clock(~clk),
        .q(rom_data));

naive_mips #(.WITH_TLB(1)) cpu(/*autoinst*/
         .ibus_address(ibus_address[31:0]),
         .ibus_byteenable(ibus_byteenable[3:0]),
         .ibus_read(ibus_read),
         .ibus_write(ibus_write),
         .ibus_wrdata(ibus_wrdata[31:0]),
         .dbus_address(dbus_address[31:0]),
         .dbus_byteenable(dbus_byteenable[3:0]),
         .dbus_read(dbus_read),
         .dbus_write(dbus_write),
         .dbus_wrdata(dbus_wrdata[31:0]),
         .rst_n(rst_n),
         .clk(clk),
         .ibus_rddata(ibus_rddata[31:0]),
         .ibus_stall(ibus_stall),
         .dbus_rddata(dbus_rddata[31:0]),
         .dbus_stall(dbus_stall),
         .hardware_int_in(irq_line));

two_port_stall mainram(/*autoinst*/
           .ram_data_i_base(base_ram_data),
           .ram_data_i_ext(ext_ram_data),
           .ram_data_o(ram_data_o),
           .rddata1(ibus_ram_rddata),
           .rddata2(dbus_ram_rddata),
           .ram_address(ram_address),
           .ram_ext_ce_n(ram_ext_ce_n),
           .ram_io_t(ram_io_t),
           .ram_wr_n(ram_wr_n),
           .ram_rd_n(ram_rd_n),
           .dataenable_n(ram_dataenable_n),
           .rst_n(rst_n),
           .clk_n(clk_ram),
           .address1(ibus_ram_address),
           .wrdata1(ibus_ram_wrdata),
           .rd1(ibus_ram_read),
           .wr1(ibus_ram_write),
           .stall1(ibus_ram_stall),
           .dataenable1(ibus_ram_byteenable),
           .address2(dbus_ram_address),
           .wrdata2(dbus_ram_wrdata),
           .rd2(dbus_ram_read),
           .wr2(dbus_ram_write),
           .stall2(dbus_ram_stall),
           .dataenable2(dbus_ram_byteenable));

dbus dbus0(/*autoinst*/
         .master_rddata(dbus_rddata[31:0]),
         .uart_address(uart_address),
         .uart_data_i(uart_data_i[31:0]),
         .uart_rd(uart_read),
         .uart_wr(uart_write),
         .gpio_address(gpio_dbus_address),
         .gpio_data_i(gpio_dbus_data_i),
         .gpio_rd(gpio_dbus_read),
         .gpio_wr(gpio_dbus_write),
         .ticker_address(ticker_dbus_address),
         .ticker_data_i(ticker_dbus_data_i),
         .ticker_rd(ticker_dbus_read),
         .ticker_wr(ticker_dbus_write),
         .gpu_address(gpu_dbus_address),
         .gpu_data_i(gpu_dbus_data_i),
         .gpu_rd(gpu_dbus_read),
         .gpu_wr(gpu_dbus_write),
         .ram_address(dbus_ram_address[23:0]),
         .ram_data_i(dbus_ram_wrdata[31:0]),
         .ram_data_enable(dbus_ram_byteenable[3:0]),
         .ram_rd(dbus_ram_read),
         .ram_wr(dbus_ram_write),
         .flash_address(flash_dbus_address[23:0]),
         .flash_data_i(flash_dbus_data_i[31:0]),
         .flash_data_enable(flash_dbus_data_enable[3:0]),
         .flash_rd(flash_dbus_read),
         .flash_wr(flash_dbus_write),
         .cfg_flash_data_o (cfg_flash_dbus_data_o),
         .cfg_flash_data_i (cfg_flash_dbus_data_i),
         .cfg_flash_address(cfg_flash_dbus_address),
         .cfg_flash_read   (cfg_flash_dbus_read),
         .cfg_flash_write  (cfg_flash_dbus_write),
         .cfg_flash_stall  (cfg_flash_dbus_stall),
         .usb_address      (usb_dbus_address),
         .usb_data_o       (usb_dbus_data_o),
         .usb_data_i       (usb_dbus_data_i),
         .usb_read         (usb_dbus_read),
         .usb_write        (usb_dbus_write),
         .usb_stall        (usb_dbus_stall),
         .net_address      (net_dbus_address),
         .net_data_o       (net_dbus_data_o),
         .net_data_i       (net_dbus_data_i),
         .net_read         (net_dbus_read),
         .net_write        (net_dbus_write),
         .net_stall        (net_dbus_stall),
         .master_address(dbus_address[31:0]),
         .master_byteenable(dbus_byteenable[3:0]),
         .master_read(dbus_read),
         .master_write(dbus_write),
         .master_wrdata(dbus_wrdata[31:0]),
         .master_stall(dbus_stall),
         .uart_data_o(uart_data_o[31:0]),
         .gpio_data_o(gpio_dbus_data_o),
         .ticker_data_o(ticker_dbus_data_o),
         .gpu_data_o(gpu_dbus_data_o),
         .ram_data_o(dbus_ram_rddata[31:0]),
         .ram_stall(dbus_ram_stall),
         .flash_stall (flash_dbus_stall),
         .flash_data_o(flash_dbus_data_o[31:0]));

uart_top uart0(/*autoinst*/
         .bus_data_o(uart_data_o[31:0]),
         .txd(txd),
         .clk_bus(clk),
         .clk_uart(clk_uart),
         .rst_n(rst_n),
         .bus_address(uart_address),
         .bus_data_i(uart_data_i[31:0]),
         .bus_read(uart_read),
         .bus_write(uart_write),
         .uart_irq(uart_irq),
         .rxd(rxd));

flash_top flash0(/*autoinst*/
         .flash_data(flash_data[15:0]),
         .flash_address(flash_address),
         .flash_we_n(flash_we_n),
         .flash_byte_n(flash_byte_n),
         .flash_oe_n(flash_oe_n),
         .flash_rp_n(flash_rp_n),
         .flash_ce(flash_ce),
         .flash_vpen(flash_vpen),
         .bus_data_o(flash_dbus_data_o[31:0]),
         .clk_bus(clk),
         .rst_n(rst_n),
         .bus_stall(flash_dbus_stall),
         .bus_address(flash_dbus_address[23:0]),
         .bus_data_i(flash_dbus_data_i[31:0]),
         .bus_be(flash_dbus_data_enable),
         .bus_read(flash_dbus_read),
         .bus_write(flash_dbus_write));

usb_isp1362 usbhcd0(/*autoinst*/
          .usb_data(usb_data),
          .bus_data_o(usb_dbus_data_o[31:0]),
          .bus_stall(usb_dbus_stall),
          .usb_a0(usb_a0),
          .usb_a1(usb_a1),
          .usb_we_n(usb_we_n),
          .usb_rd_n(usb_rd_n),
          .usb_cs_n(usb_cs_n),
          .usb_rst_n(usb_rst_n),
          .usb_drq(usb_drq),
          .clk_bus(clk),
          .rst_n(rst_n),
          .bus_address(usb_dbus_address[2:0]),
          .bus_data_i(usb_dbus_data_i[31:0]),
          .bus_read(usb_dbus_read),
          .bus_write(usb_dbus_write),
          .bus_irq(usb_irq),
          .usb_dack(usb_dack),
          .usb_int(usb_int));

ethlite eth0(
        .clk        (clk),
        .sysclk100M (clk_in),
        .address1   (net_dbus_address),
        .wrdata1    (net_dbus_data_i),
        .rddata1    (net_dbus_data_o),
        .dataenable1(4'b1111),
        .rd1        (net_dbus_read),
        .wr1        (net_dbus_write),
        .stall1     (net_dbus_stall),
        .irq        (net_irq),
        .rst_n      (rst_n),
        .mdc(mdc),
        .mdio_i(mdio_i),
        .mdio_o(mdio_o),
        .mdio_t(mdio_t),
        .MII_col(MII_col),
        .MII_crs(MII_crs),
        .MII_rst_n(MII_rst_n),
        .MII_rx_clk(MII_rx_clk),
        .MII_rx_dv(MII_rx_dv),
        .MII_rx_er(MII_rx_er),
        .MII_rxd(MII_rxd),
        .MII_tx_clk(MII_tx_clk),
        .MII_tx_en(MII_tx_en),
        .MII_txd(MII_txd)
    );

IOBUF mdio_buf(
    .IO(mdio),
    .I(mdio_o),
    .O(mdio_i),
    .T(mdio_t)
);

spi_flash spi_flash_cfg(
        .clk        (clk),
        .spiclk     (vga_clk),
        .axiclk     (clk_in),
        .address1   (cfg_flash_dbus_address),
        .wrdata1    (cfg_flash_dbus_data_i),
        .rddata1    (cfg_flash_dbus_data_o),
        .dataenable1(4'b1111),
        .rd1        (cfg_flash_dbus_read),
        .wr1        (cfg_flash_dbus_write),
        .stall1     (cfg_flash_dbus_stall),
        .rst_n      (rst_n),
        .miso_i     (miso_i),
        .miso_o     (miso_o),
        .miso_t     (miso_t),
        .ss_i       (ss_i),
        .ss_o       (ss_o),
        .ss_t       (ss_t),
        .mosi_t     (mosi_t),
        .mosi_i     (mosi_i),
        .mosi_o     (mosi_o)
    );

IOBUF ss_buf(
    .IO(cfg_flash_ss),
    .I(ss_o),
    .O(ss_i),
    .T(ss_t)
);

IOBUF miso_buf(
    .IO(cfg_flash_miso),
    .I(miso_o),
    .O(miso_i),
    .T(miso_t)
);

IOBUF mosi_buf(
    .IO(cfg_flash_mosi),
    .I(mosi_o),
    .O(mosi_i),
    .T(mosi_t)
);

gpio_top gpio_inst(/*autoinst*/
         .gpio0(gpio0[31:0]),
         .gpio1(gpio1[31:0]),
         .bus_data_o(gpio_dbus_data_o[31:0]),
         .clk_bus(clk),
         .rst_n(rst_n),
         .bus_address(gpio_dbus_address[7:0]),
         .bus_data_i(gpio_dbus_data_i[31:0]),
         .bus_read(gpio_dbus_read),
         .bus_write(gpio_dbus_write));

ticker ticker_inst(
        .clk_bus(clk),
        .rst_n(rst_n),
        .clk_tick(clk_tick),
        .rst_tick_n(rst_n),
        .bus_data_o(ticker_dbus_data_o[31:0]),
        .bus_address(ticker_dbus_address[7:0]),
        .bus_data_i(ticker_dbus_data_i[31:0]),
        .bus_read(ticker_dbus_read),
        .bus_write(ticker_dbus_write));

gpu gpu_inst(
        .clk_bus  (clk),
        .clk_pixel(vga_clk), //50 MHz
        .rst_n    (rst_n),
        .bus_read (gpu_dbus_read),
        .bus_write(gpu_dbus_write),
        .bus_data_o(gpu_dbus_data_o),
        .bus_address(gpu_dbus_address),
        .bus_data_i(gpu_dbus_data_i),
        .de       (vga_de),
        .vsync    (vga_vsync),
        .hsync    (vga_hsync),
        .pxlData  (vga_pixel)
);

assign irq_line = {1'b0,usb_irq,uart_irq,1'b0,net_irq};

`ifdef HS_DIFF_OUT
wire [255:0] testdata_in;
assign testdata_in = {
    cpu.main_regs.registers[12],
    cpu.main_regs.registers[11],
    cpu.main_regs.registers[10],
    cpu.main_regs.registers[9],
    cpu.main_regs.registers[8],
    cpu.ibus_address,
    cpu.ibus_rddata,
    cpu.pc_instance.pc_reg
};
reg start_sample;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start_sample <= 1'b0;
    else
        start_sample <= 1'b1;
end
sampler_0 la(
    .sample_clk    (clk_tick), // vio-like usage, cross clock-domain
    .ref_50M_clk   (clk_in),
    .clkout1_p (clkout1_p),
    .clkout1_n (clkout1_n),
    .dataout1_p(dataout1_p),
    .dataout1_n(dataout1_n),
    .start_sample  (start_sample),
    .stop_sample   (~start_sample),
    .data_in       (testdata_in)
);
`endif

endmodule
