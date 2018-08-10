<?xml version="1.0" encoding="UTF-8"?>
<Project>
    <Project_Created_Time>2018-08-09 23:51:29</Project_Created_Time>
    <TD_Version>4.1.670</TD_Version>
    <Name>naivemips</Name>
    <HardWare>
        <Family>EG4</Family>
        <Device>EG4S20BG256</Device>
    </HardWare>
    <Source_Files>
        <Verilog>
            <File>../../src/cpu/cp0.v</File>
            <File>../../src/cpu/mmu/mem_map.v</File>
            <File>../../src/cpu/mmu/mmu_top.v</File>
            <File>../../src/cpu/mmu/tlb.v</File>
            <File>../../src/cpu/mmu/tlbConverter.v</File>
            <File>../../src/cpu/stage_ex/count_bit_byte.v</File>
            <File>../../src/cpu/stage_ex/count_bit_word.v</File>
            <File>../../src/cpu/stage_ex/ex.v</File>
            <File>../../src/cpu/stage_ex/multi_cycle.v</File>
            <File>../../src/cpu/stage_ex/simple_div.v</File>
            <File>../../src/cpu/stage_id/branch.v</File>
            <File>../../src/cpu/stage_id/id_i.v</File>
            <File>../../src/cpu/stage_id/id_j.v</File>
            <File>../../src/cpu/stage_id/id_r.v</File>
            <File>../../src/cpu/stage_id/id.v</File>
            <File>../../src/cpu/stage_id/reg_val_mux.v</File>
            <File>../../src/cpu/stage_if/pc.v</File>
            <File>../../src/cpu/stage_mm/exception.v</File>
            <File>../../src/cpu/stage_mm/mm.v</File>
            <File>../../src/cpu/stage_wb/wb.v</File>
            <File>../../src/cpu/defs.v</File>
            <File>../../src/cpu/hilo_reg.v</File>
            <File>../../src/cpu/naive_mips.v</File>
            <File>../../src/cpu/regs.v</File>
            <File>../../src/bus/dbus.v</File>
            <File>../../src/bus/ibus.v</File>
            <File>../../src/gpio/gpio_top.v</File>
            <File>../../src/ticker/ticker.v</File>
            <File>../../src/uart/uart_rx.v</File>
            <File>../../src/uart/uart_top.v</File>
            <File>../../src/uart/uart_tx.v</File>
            <File>../../src/clk_ctrl.v</File>
            <File>../../src/flag_sync.v</File>
            <File>../../src/soc_toplevel.v</File>
            <File>al_ip/sys_pll.v</File>
            <File>al_ip/bootrom.v</File>
        </Verilog>
        <ADC_FILE/>
        <SDC_FILE/>
        <CWC_FILE/>
    </Source_Files>
    <TOP_MODULE>
        <LABEL/>
        <MODULE>soc_toplevel</MODULE>
        <CREATEINDEX>user</CREATEINDEX>
    </TOP_MODULE>
    <Project_Settings>
        <Step_Last_Change>2018-08-10 00:14:46</Step_Last_Change>
    </Project_Settings>
</Project>
