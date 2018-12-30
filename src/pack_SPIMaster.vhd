-- SPI Master Package file
-- (C) Stefan Mayrhofer
-- 27.12.2018
-- VHDL-Version: 2008

-- this file contains constants and types I use in my entity+architecture
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pack_SPIMaster is
	constant cWordLen : natural := 8;
--	constant cMaxCnt : natural := 100;
	constant cMaxCnt : natural := 1;

	type astate_type is (sIdle, sSetnCS, sClkHigh, sSendBit, sClkLow, sResnCS, sWaitForGoLow);
	
	subtype aIndexVal is integer range cWordLen-1 downto -1;
	
	type aInternalData is record
		data : std_ulogic_vector(cWordLen-1 downto 0);
		index : aIndexVal;

		CanAcceptData : std_ulogic;

		Counter : natural;

		MOSI : std_ulogic;
		SPIClk : std_ulogic;
		nCS : std_ulogic;
	end record;
	
	constant cResData : aInternalData := (
		data => (others=>'0'),
		index => cWordLen-1, --MSB
		
		CanAcceptData => '0',
		
		Counter => 0,
		
		MOSI => '0',
		SPIClk => '0',
		nCS => '1'
	);
end package pack_SPIMaster;

package body pack_SPIMaster is
end package body pack_SPIMaster;
