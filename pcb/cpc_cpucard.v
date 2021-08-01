//
// cpc_cpucard netlist
//
// netlister.py format
//
// (c) Revaldinho, 2021
//
//
module cpc_cpucard ();

  // wire declarations
  supply0 GND;
  supply1 VDD;
  supply1 VDD5V;

  wire Sound;
  wire A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0 ;
  wire D7,D6,D5,D4,D3,D2,D1,D0 ;
  wire MREQ_B;
  wire M1_B;
  wire RFSH_B;
  wire IOREQ_B;
  wire RD_B;
  wire WR_B;
  wire HALT_B;
  wire INT_B ;
  wire NMI_B ;
  wire BUSRQ_B;
  wire BUSACK_B;
  wire READY;
  wire BUSRESET_B;
  wire RESET_B;
  wire ROMEN_B;
  wire ROMDIS ;
  wire RAMRD_B;
  wire RAMDIS;
  wire CURSOR;
  wire LPEN;
  wire EXP_B;
  wire CLK;

  wire ZIF_CLK;
  wire ZIF_RD_B;
  wire ZIF_MREQ_B;
  wire ZIF_A14, ZIF_A15;

  wire clk_filt, clk1, clk2_b, clk3, clk_cap, clk_b;

  // Radial electolytic, one per board on the main 5V supply
  cap22uf         CAP22UF(.minus(GND),.plus(VDD5V));

  // Amstrad CPC Edge Connector
  //
  // V1.01 Corrected upper and lower rows
  idc_hdr_50w  CONN1 (
                      .p50(Sound),   .p49(GND),
                      .p48(A15),     .p47(A14),
                      .p46(A13),     .p45(A12),
                      .p44(A11),     .p43(A10),
                      .p42(A9),      .p41(A8)
                      .p40(A7),      .p39(A6),
                      .p38(A5),      .p37(A4),
                      .p36(A3),      .p35(A2),
                      .p34(A1),      .p33(A0),
                      .p32(D7),      .p31(D6)
                      .p30(D5),      .p29(D4),
                      .p28(D3),      .p27(D2),
                      .p26(D1),      .p25(D0),
                      .p24(VDD),     .p23(MREQ_B),
                      .p22(M1_B),    .p21(RFSH_B),
                      .p20(IOREQ_B), .p19(RD_B),
                      .p18(WR_B),    .p17(HALT_B),
                      .p16(INT_B),   .p15(NMI_B),
                      .p14(BUSRQ_B), .p13(BUSACK_B),
                      .p12(READY),   .p11(BUSRESET_B),
                      .p10(RESET_B), .p9 (ROMEN_B),
                      .p8 (ROMDIS),  .p7 (RAMRD_B),
                      .p6 (RAMDIS),  .p5 (CURSOR),
                      .p4 (LPEN),    .p3 (EXP_B),
                      .p2 (GND),     .p1 (CLK),
                      ) ;

  // Current limiting resistors on all signals which would be overdriven on CPC464
  // with DIP switches to bypass (short circuit) where necessary
  DIP4        dip_0(
                     .sw0_a(ZIF_A15),    .sw0_b(A15),
                     .sw1_a(ZIF_A14),    .sw1_b(A14),
                     .sw2_a(ZIF_MREQ_B), .sw2_b(MREQ_B),
                     .sw3_a(ZIF_RD_B),   .sw3_b(RD_B),
                     );

  resistor r330_0 ( .p0(ZIF_A15),    .p1(A15) );
  resistor r330_1 ( .p0(ZIF_A14),    .p1(A14) );
  resistor r330_2 ( .p0(ZIF_MREQ_B), .p1(MREQ_B) );
  resistor r330_3 ( .p0(ZIF_RD_B),   .p1(RD_B) );

  // weak local pullups on active low inputs (could be a single SIL)
  vresistor r100k_0 ( .p0(VDD5V), .p1(RESET_B) );
  vresistor r100k_1 ( .p0(VDD5V), .p1(BUSRQ_B) );
  vresistor r100k_2 ( .p0(VDD5V), .p1(READY) );
  vresistor r100k_3 ( .p0(VDD5V), .p1(HALT_B) );
  vresistor r100k_4 ( .p0(VDD5V), .p1(INT_B) );
  vresistor r100k_5 ( .p0(VDD5V), .p1(NMI_B) );

  // Pull up and switch for BUSRESET_B
  vresistor r47k_0 ( .p0(VDD5V), .p1(BUSRESET_B) );
  TSWITCH  rstsw ( .a_0(GND),
                   .a_1(),
                   .b_0(),
                   .b_1(BUSRESET_B)
                   );

  // Clock filter with DIP selection
  vresistor r100_0 ( .p0(clk_filt),  .p1(CLK) );
  SN74132   ic_0   (
                    .i0_0(clk_filt), .vdd(VDD5V),
                    .i0_1(clk_filt), .i3_0(clk1),
                    .o0(clk_b),      .i3_1(clk_filt),
                    .i1_0(clk_b),    .o3(clk2_b),
                    .i1_1(clk_b),    .i2_0(clk2_b),
                    .o1(clk1),       .i2_1(clk2_b),
                    .vss(GND),       .o2(clk3),
                    );

  DIP4      dip_1 (  .sw0_a(clk3),       .sw0_b(ZIF_CLK),
                     .sw1_a(clk1),       .sw1_b(ZIF_CLK),
                     .sw2_a(clk_filt),   .sw2_b(ZIF_CLK),
                     .sw3_a(clk_filt),   .sw3_b(clk_cap) );
  smallcap  c47pf  ( .p1(clk_cap),  .p0(GND) );

  // Link for ammeter to be inserted in power supply
  hdr1x02   vlnk ( .p1(VDD), .p2(VDD5V));

  // Ground pins for probes
  hdr1x03   gndpt ( .p1(GND),.p2(GND),.p3(GND) );

  // Decoupling caps
  cap100nf CAP100N_1 (.p1( VDD5V ), .p0( GND ));
  cap100nf CAP100N_2 (.p1( VDD5V ), .p0( GND ));
  cap100nf CAP100N_3 (.p1( VDD5V ), .p0( GND ));

  // 40 pin ZIF for CPU
  ZIF40     skt_0 (
                   .p1(A11),         .p40(A10),
                   .p2(A12),         .p39(A9),
                   .p3(A13),         .p38(A8),
                   .p4(ZIF_A14),     .p37(A7),
                   .p5(ZIF_A15),     .p36(A6),
                   .p6(ZIF_CLK),     .p35(A5),
                   .p7(D4),          .p34(A4),
                   .p8(D3),          .p33(A3),
                   .p9(D5),          .p32(A2),
                   .p10(D6),         .p31(A1),
                   .p11(VDD5V),      .p30(A0),
                   .p12(D2),         .p29(GND),
                   .p13(D7),         .p28(RFSH_B),
                   .p14(D0),         .p27(M1_B),
                   .p15(D1),         .p26(RESET_B),
                   .p16(INT_B),      .p25(BUSRQ_B),
                   .p17(NMI_B),      .p24(READY),
                   .p18(HALT_B),     .p23(BUSACK_B),
                   .p19(ZIF_MREQ_B), .p22(WR_B),
                   .p20(IOREQ_B),    .p21(ZIF_RD_B)
                   );

  // 40 way header for probes to be labelled and replicate the Z80 pinout
  hdr2x20 CONN2 (
                 .p1(A11),       .p2(A10),
                 .p3(A12),       .p4(A9),
                 .p5(A13),       .p6(A8),
                 .p7(ZIF_A14),   .p8(A7),
                 .p9(ZIF_A15),   .p10(A6),
                 .p11(ZIF_CLK),   .p12(A5),
                 .p13(D4),        .p14(A4),
                 .p15(D3),        .p16(A3),
                 .p17(D5),        .p18(A2),
                 .p19(D6),        .p20(A1),
                 .p21(VDD5V),     .p22(A0),
                 .p23(D2),        .p24(GND),
                 .p25(D7),        .p26(RFSH_B),
                 .p27(D0),        .p28(M1_B),
                 .p29(D1),        .p30(RESET_B),
                 .p31(INT_B),     .p32(BUSRQ_B),
                 .p33(NMI_B),     .p34(READY),
                 .p35(HALT_B),    .p36(BUSACK_B),
                 .p37(ZIF_MREQ_B),.p38(WR_B),
                 .p39(IOREQ_B),   .p40(ZIF_RD_B)
                 );

endmodule
