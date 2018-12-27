-- SPI Master testbench
-- (C) Stefan Mayrhofer
-- 27.12.2018
-- VHDL-Version: 2008

-- a very primitive testbed. I just wanted a quick confirmation if stuff works
-- don't use this as an example for how you should do it...
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.all;

entity tbSPIMaster is
end entity tbSPIMaster;

architecture Bhv of tbSPIMaster is
	constant cClkCycleTime : time := 10 ns;
	signal iClk, inRstAsync : std_ulogic := '0';
	
	signal iDataToSend : std_ulogic_vector(7 downto 0);
	signal iGo, oDone, oMOSI, oSPIClk, onCS : std_ulogic;
begin
	UUT: entity work.SPIMaster
		port map(
			iClk        => iClk,
			inRstAsync  => inRstAsync,
			iDataToSend => iDataToSend,
			iGo         => iGo,
			oDone       => oDone,
			oMOSI       => oMOSI,
			oSPIClk     => oSPIClk,
			onCS        => onCS
		);

	Stimul: process is
	begin
		iGO <= '0';
		iDataToSend <= (others=>'0');
		wait for 0 ns;

		wait until iClk;
		--Assert starting conditions
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '1' report "oCS has a wrong value" severity failure;
		wait for 13 ns;
		
		--Remove reset
		inRstAsync <= '1';
		wait until iClk;
		wait for 1 ps;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '1' report "oDone has a wrong value" severity failure;
		assert onCS = '1' report "oCS has a wrong value" severity failure;
		
		iDataToSend <= "10101010";
		iGO <= '1';
		
		--Check 'HIGH (7)
		wait until oSPIClk;
		assert oMOSI = '1' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (6)
		wait until oSPIClk;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (5)
		wait until oSPIClk;
		assert oMOSI = '1' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (4)
		wait until oSPIClk;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (3)
		wait until oSPIClk;
		assert oMOSI = '1' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (2)
		wait until oSPIClk;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (1)
		wait until oSPIClk;
		assert oMOSI = '1' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		--Check (0)
		wait until oSPIClk;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '0' report "oDone has a wrong value" severity failure;
		assert onCS = '0' report "oCS has a wrong value" severity failure;
		
		iGo <= '0';
		
		--Check end
		wait until oDONE'EVENT;
		assert oMOSI = '0' report "oMOSI has a wrong value: " severity failure;
		assert oDone = '1' report "oDone has a wrong value" severity failure;
		assert onCS = '1' report "oCS has a wrong value" severity failure;
		stop;
	end process;

	ClkGen: process is
	begin
		iClk <= NOT iClk;
		wait for cClkCycleTime/2;
	end process;
end architecture Bhv;
