-- SPI Master entity+architecture
-- (C) Stefan Mayrhofer
-- 27.12.2018
-- VHDL-Version: 2008

-- This is a very simple implementation of a SPI Master.
-- You can set the length of a word in the pack_SPIMaster.vhdl file
-- You can also slow it down or speed it up by modifying cMaxCnt in pack_SPIMaster.vhdl
-- Why did I do this?
-- I "needed" it for a project and was too lazy to use a prebuilt one
-- If I ever have time to spare I will possibly make this one more beautiful.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pack_SPIMaster.all;

entity SPIMaster is
	port(
		iClk : in std_ulogic;
		inRstAsync : in std_ulogic;
		
		iDataToSend : in std_ulogic_vector(cWordLen-1 downto 0);
		iGo : in std_ulogic;
		
		oDone : out std_ulogic;
		
		oMOSI : out std_ulogic;
		oSPIClk : out std_ulogic;
		onCS : out std_ulogic
	);
end entity SPIMaster;

architecture RTL of SPIMaster is
	signal state, stateNext : aState_type;
	signal data, dataNext : aInternalData;
begin

	/*
	 * This process clocks our registers
	 */
	process(iClk, inRstAsync) is
	begin
		if inRstAsync = '0' then
			state <= sIdle;
			data <= cResData;
		elsif rising_edge(iClk) then
			state <= stateNext;
			data <= dataNext;
		end if;
	end process;
	
	/*
	 * This process runs the FSMD that takes care about sending the data
	 */
	FSMD: process (all) is
	begin
		stateNext <= state;
		dataNext <= data;
		
		dataNext.Done <= '0';
		
		case state is
			--In the idle state we accept data
			when sIdle =>
				dataNext.data <= iDataToSend; --data to send
				dataNext.Done <= '1'; --signal that we are ready for new data

				/*when we receive the GO-Signal, we are ready to start the transmit*/
				if (iGo) then
					stateNext <= sSetnCS;
				end if;
			--In the SetnCS state we set the CS (negative logic)
			when sSetnCS =>
				dataNext.nCS <= '0';
				
				--We need the counter to delay the next step
				--otherwise we would run too fast
				dataNext.Counter <= data.Counter + 1;
				
				if(data.Counter >= cMaxCnt) then
					dataNext.Counter <= 0;
					stateNext <= sSendBit;
				end if;
			
			--In this state we prepare the bit to send
			when sSendBit =>
				dataNext.MOSI <= data.data(data.index); --bit to send
				dataNext.index <= data.index - 1; --shift index by 1
				stateNext <= sClkHigh;
			--In this state we set the SPI Clk to HIGH
			when sClkHigh =>
				dataNext.SPIClk <= '1';
				
				--We need the counter to delay the next step
				--otherwise we would run too fast
				dataNext.Counter <= data.Counter + 1;
				
				if(data.Counter >= cMaxCnt) then
					dataNext.Counter <= 0;
					stateNext <= sClkLow;
				end if;
			--In this state we set the SPI Clk to LOW and check if the transaction is complete
			when sClkLow =>
				dataNext.SPIClk <= '0';
				
				--We need the counter to delay the next step
				--otherwise we would run too fast
				dataNext.Counter <= data.Counter + 1;
				
				if(data.Counter >= cMaxCnt) then
					dataNext.Counter <= 0;
					if(data.index=-1) then
						--end of word reached. wait for new word
						dataNext.MOSI <= '0';
						stateNext <= sResnCS;			
					else
						stateNext <= sSendBit;
					end if;
				end if;
			--In this state we reset the CS (negative logic)
			when sResnCS =>
				dataNext.nCS <= '1';
				stateNext <= sWaitForGoLow;
			--In this state we wait until the GO-Bit was reset
			when sWaitForGoLow =>
				-- signal that we are done
				-- the user can now reset low
				-- as well as send new data
				dataNext.Done <= '1';
				if(NOT iGo) then
					stateNext <= sIdle;
				end if;
		end case;
	end process;

	oDone <= data.Done;

	oMOSI <= data.MOSI;
	oSPIClk <= data.SPIClk;
	onCS <= data.nCS;

end architecture RTL;
