--Aaron Smith
--COMP 4300
--Lab 3 32-bit Single-value Register

use work.dlx_types.all; 
use work.bv_arithmetic.all;

entity dlx_register is 
	generic(prop_delay: Time := 10ns);
	port(in_val: in dlx_word; clock: in bit; out_val: out dlx_word);  
end entity dlx_register; 

architecture behavior of dlx_register is
begin
	dlx_register_process: process(in_val, clock) is
	begin
		if(clock = '1') then
			out_val <= in_val after prop_delay;
		end if;
	end process dlx_register_process;
end architecture behavior;