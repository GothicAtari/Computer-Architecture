--Aaron Smith
--COMP 4300
--Lab 3 Multiplexer

use work.dlx_types.all; 
use work.bv_arithmetic.all;

entity mux is
	generic(prop_delay : Time := 5ns);
	port (input_1, input_0 : in dlx_word; which: in bit; output: out dlx_word);
end entity mux;

architecture behavior of mux is
begin
	mux_process: process(input_1, input_0, which) is
	begin
		if (which = '0') then
			output <= input_0 after prop_delay;
		end if;

		if (which = '1') then
			output <= input_1 after prop_delay;
		end if;
	end process mux_process;
end architecture behavior;