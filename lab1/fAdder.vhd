entity fAdder is 
	generic(prop_delay: Time := 10 ns);
	port(a_in,b_in,carry_in: in bit;
             result,carry_out: out bit);
end entity fAdder; 


architecture behaviour1 of fAdder is
begin
	addProcess : process(a_in,b_in,carry_in) is 
	
	begin
		result <= a_in xor b_in xor carry_in;-- after prop_delay;

		carry_out <= (a_in and b_in) or ((a_in xor b_in) and carry_in);-- after prop_delay;

	end process addProcess; 
end architecture behaviour1; 