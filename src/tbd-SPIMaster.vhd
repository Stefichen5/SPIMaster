-- SPI Master testbed
-- (C) Stefan Mayrhofer
-- 27.12.2018
-- VHDL-Version: 2008

-- This is a testbed that is aimed to make the SPI Master usable on the
-- DE1 SoC Board 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tbdSPIMaster is
	port(
		iClk         : in  std_ulogic;
    	inRstAsync   : in  std_ulogic;
    	
	    LEDR		 : out std_ulogic_vector(9 downto 0);
	    
	    SW : in std_ulogic;
	    
	  	oSPIClk : out  std_ulogic;
	  	oSPIMOSI: out std_ulogic;
	  	onSS	: out std_ulogic
	);
end entity tbdSPIMaster;

architecture RTL of tbdSPIMaster is
	signal data : std_ulogic_vector(7 downto 0);
	signal toSync, synced : std_ulogic_vector(0 downto 0);
begin
	DUT : entity work.SPIMaster
		port map(
			iClk        => iClk,
			inRstAsync  => inRstAsync,
			iDataToSend => data,
-- we don't use the switch for now
--			iGo         => synced(0),
			iGo         => '1',
			oCanAcceptData => LEDR(8),
			oMOSI       => oSPIMOSI,
			oSPIClk     => oSPIClk,
			onCS        => onSS
		);
		
	Sync1 : entity work.Synchronizer
		generic map(
			gRange      => 1,
			gResetValue => '0'
		)
		port map(
			iClk       => iClk,
			inRstAsync => inRstAsync,
			iD         => toSync,
			oQ         => synced
		);
	
	toSync(0) <= SW;
	
	data <= "10101010"; --test data
	LEDR(7 downto 0) <= data;
	LEDR(9) <= synced(0); --Go signal (unsused)
	
end architecture RTL;
