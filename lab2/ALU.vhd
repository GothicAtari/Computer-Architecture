--Aaron Smith
--COMP 4300
--Lab 2 Arithmetic Logic Unit

use work.dlx_types.all; 
use work.bv_arithmetic.all;

entity alu is
generic(prop_delay : Time := 15 ns);
port(operand1, operand2: in dlx_word; operation: in
	alu_operation_code;
	result: out dlx_word; error: out error_code);
end entity alu; 

architecture behavior of alu is
begin
	alu_process: process(operand1, operand2, operation) is
		--conditions for errors
		variable overflow: boolean;
		variable div_by_zero: boolean;

		variable bv_result: dlx_word;
	begin
		error <= "0000";

		--I believe this is like a java switch
		--Also using hex because I refuse to type 32 1's or 0's... hope that's okay
		case(operation) is

			--unsigned add
			when "0000" =>
				bv_addu(operand1, operand2, bv_result, overflow);
				if overflow then
					error <= "0001";
				end if;
				result <= bv_result;

			--unsigned subtract
			when "0001" =>
				bv_subu(operand1, operand2, bv_result, overflow);
				if overflow then
					error <= "0001";
				end if;
				result <= bv_result;

			--two's complement add
			when "0010" =>
				bv_add(operand1, operand2, bv_result, overflow);
				if overflow then
					if (operand1(31) = '0') AND (operand2(31) = '0') then
						if (bv_result(31) = '1') then
							error <= "0001";
						end if;
					elsif (operand1(31) = '1') AND (operand2(31) = '1') then
						if (bv_result(31) = '0') then
							error <= "0001";
						end if;
					end if;
				end if;
				result <= bv_result;

			--two's complement subtract
			when "0011" =>
				bv_sub(operand1, operand2, bv_result, overflow);
				if overflow then
					if (operand1(31) = '0') AND (operand2(31) = '1') then
						if (bv_result(31) = '1') then
							error <= "0001";
						end if;
					elsif (operand1(31) = '1') AND (operand2(31) = '0') then
						if (bv_result(31) = '0') then
							error <= "0001";
						end if;
					end if;
				end if;
				result <= bv_result;

			--two's complement multiply
			when "0100" =>
				bv_mult(operand1, operand2, bv_result, overflow);
				if overflow then
					if (operand1(31) = '0') AND (operand2(31) = '0') then
						if (bv_result(31) = '1') then
							error <= "0001";
						end if;
					elsif (operand1(31) = '1') AND (operand2(31) = '1') then
						if (bv_result(31) = '1') then
							error <= "0001";
						end if;
					end if;
				end if;
				result <= bv_result;

			--two's complement divide
			when "0101" =>
				bv_div(operand1, operand2, bv_result, div_by_zero, overflow);
				if overflow then
					error <= "0001";
				elsif div_by_zero then
					error <= "0010";
				end if;
				result <= bv_result;

			--bitwise AND
			when "0111" =>
				result <= operand1 and operand2;

			--bitwise OR
			when "1001" =>
				result <= operand1 or operand2;

			--bitwise NOT of operand1 (ignore operand2) 
			when "1011" =>
				result <= not operand1;

			--pass operand1 through to the output
			when "1100" =>
				result <= operand1;

			--pass operand2 through to the output
			when "1101" =>
				result <= operand2;

			--output all zero's
			when "1110" =>
				result <= x"00000000";

			--output all one's
			when "1111" =>
				result <= x"11111111";

			--this is for the other 4-bit op codes we didn't use, just all zeros
			when others =>
				result <= x"00000000";
		end case;
	end process alu_process;
end architecture behavior;