--Aaron Smith
--COMP 4300
--Lab 3 PC Incrementer

use work.dlx_types.all; 
use work.bv_arithmetic.all;

entity pcplusone is
	generic(prop_delay : Time := 5ns);
	port(input: in dlx_word; clock: in bit; output: out dlx_word);
end entity pcplusone;

architecture behavior of pcplusone is
begin
	pcplusone_process: process(input, clock) is
		variable temp_result: dlx_word;
		variable overflow: boolean;
	begin
		if (clock = '1') then
			bv_add(input, x"00000001", temp_result, overflow);
			output <= temp_result after prop_delay;
		end if;
	end process pcplusone_process;
end architecture behavior;