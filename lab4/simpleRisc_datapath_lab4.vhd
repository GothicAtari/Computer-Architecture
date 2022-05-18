--Aaron Smith
--COMP 4300
--Lab 4 RISC Datapath

-- simpleRisc_datapath_lab4.vhd

-- entity reg_file (correct for simple Risc) 
use work.dlx_types.all; 
use work.bv_arithmetic.all;  

entity reg_file is
     port (data_in: in dlx_word; readnotwrite,clock : in bit; 
	   data_out: out dlx_word; reg_number: in register_index );
end entity reg_file; 

architecture behavior of reg_file is
	type reg_type is array (0 to 31) of dlx_word;
begin
	reg_file_process: process(readnotwrite, clock, reg_number, data_in) is
		variable registers: reg_type;
	begin
		if (clock ='1') then
			
			if (readnotwrite = '1') then
				data_out <= registers(bv_to_integer(reg_number));
			else
				registers(bv_to_integer(reg_number)) := data_in;
			end if;
		end if;
	end process reg_file_process;
end architecture behavior;
-- end entity regfile

-- entity simple_alu (correct for simple risc, different from Aubie) 
use work.dlx_types.all; 
use work.bv_arithmetic.all; 

entity simple_alu is 
     generic(prop_delay : Time := 5 ns);
     port(operand1, operand2: in dlx_word; operation: in alu_operation_code; 
          result: out dlx_word; error: out error_code); 
end entity simple_alu; 

-- alu_operation_code values (simpleRisc)
-- 0000 unsigned add
-- 0001 unsigned sub
-- 0010 2's compl add
-- 0011 2's compl sub
-- 0100 2's compl mul
-- 0101 2's compl divide
-- 0110 logical and
-- 0111 bitwise and
-- 1001 bitwise or 
-- 1011 bitwise not (op1)
-- 1100 copy op1 to output
-- 1101 copy op2 to output
-- 1110 output all zero's
-- 1111 output all one's

-- error code values
-- 0000 = no error
-- 0001 = overflow (too big or too small) 
-- 0011 = divide by zero 

architecture behavior of simple_alu is
begin
	simple_alu_process: process(operand1, operand2, operation) is
		--conditions for errors
		variable overflow: boolean;
		variable div_by_zero: boolean;
		variable op1: dlx_word;
		variable op2: dlx_word;
		variable op1bool, op2bool: boolean;
		variable bv_result: dlx_word;
		variable i: integer;
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

			-- logical AND
			when "0110" =>
				op1bool := false;
				for i in 31 downto 0 loop
					if (op1(i) = '1') then
						op1bool := true;
					end if;
				end loop;

				op2bool := false;
				for i in 31 downto 0 loop
					if (op2(i) = '1') then
						op2bool := true;
					end if;
				end loop;

				if (op1bool and op2bool) then
					result <= x"00000001";
				else
					result <= x"00000000";
				end if;

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
	end process simple_alu_process;
end architecture behavior;
-- end entity simple_alu

-- entity dlx_register 
use work.dlx_types.all; 

entity dlx_register is
     generic(prop_delay : Time := 5 ns);
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
-- end entity dlx_register

-- entity pcplusone (correct for simpleRisc)
use work.dlx_types.all;
use work.bv_arithmetic.all; 

entity pcplusone is
	generic(prop_delay: Time := 5 ns); 
	port (input: in dlx_word; clock: in bit;  output: out dlx_word); 
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
-- end entity pcplusone

-- entity mux 
use work.dlx_types.all; 

entity mux is
     generic(prop_delay : Time := 5 ns);
     port (input_1,input_0 : in dlx_word; which: in bit; output: out dlx_word);
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
-- end entity mux

-- entity memory 
use work.dlx_types.all;
use work.bv_arithmetic.all;

entity memory is
  
  port (
    address : in dlx_word;
    readnotwrite: in bit; 
    data_out : out dlx_word;
    data_in: in dlx_word; 
    clock: in bit); 
end memory;

architecture behavior of memory is

begin  -- behavior

  mem_behav: process(address,clock) is
    -- note that there is storage only for the first 1k of the memory, to speed
    -- up the simulation
    type memtype is array (0 to 1024) of dlx_word;
    variable data_memory : memtype;
  begin
    -- fill this in by hand to put some values in there
    -- some instructions
   data_memory(0) :=  "00000000000000000000100000000000";   -- LD R1,R0(100)
   data_memory(1) :=  "00000000000000000000000100000000";
   data_memory(2) :=  "00000000000000000001000000000000";   -- LD R2,R0(101)
   data_memory(3) :=  "00000000000000000000000100000001";
   data_memory(4) :=  "00001000001000100001100100000000";   -- ADD R3,R1,R2
   data_memory(5) :=  "00000100011000000000000000000000";   -- STO R3,R0(102)
   data_memory(6) :=  "00000000000000000000000100000010";
   -- if the 3 instructions above run correctly for you, you get full credit for the assignment


   -- data for the first two loads to use 
    data_memory(256) := X"55550000"; 
    data_memory(257) := X"00005555";
    data_memory(258) := X"ffffffff";

    -- testing for extra credit 
    -- code to test JZ , should be taken unless value of R1 changed
    data_memory(7) := "00001100100000000000000000000000";         -- JMP R4(00000010)
    data_memory(8) := X"00000010";

    data_memory(16):=  "00010000100001010000000000000000";        -- JZ R5,R4(00000000)
    data_memory(17) := X"00000000";

   
    if clock = '1' then
      if readnotwrite = '1' then
        -- do a read
        data_out <= data_memory(bv_to_natural(address)) after 5 ns;
      else
        -- do a write
        data_memory(bv_to_natural(address)) := data_in; 
      end if;
    end if;


  end process mem_behav; 

end behavior;
-- end entity memory