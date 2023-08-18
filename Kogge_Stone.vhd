library IEEE;
use ieee.std_logic_1164.all;
entity Kogge_Stone is
port (
			A    : in  std_logic_vector(15 downto 0);     --A is a 16 bit input
			B    : in  std_logic_vector(15 downto 0);     --B is a 16 bit input
			C_in : in  std_logic;
			Sum  : out std_logic_vector(15 downto 0);     --Sum 
			C_out: out std_logic
		);
end Kogge_Stone;

architecture arch of Kogge_Stone is

	--internal p & g values
	signal p_in: std_logic_vector (15 downto 0);
	signal g_in: std_logic_vector (15 downto 0);
   
	--output values of p & g at each logical level
	
	--level 1
	signal p1: std_logic_vector (15 downto 0);
	signal g1: std_logic_vector (15 downto 0);
		
	--level 2
	signal p2: std_logic_vector (15 downto 0);
	signal g2: std_logic_vector (15 downto 0);
		
	--level 3
	signal p3: std_logic_vector (15 downto 0);
	signal g3: std_logic_vector (15 downto 0);
		
	--level 4
	signal p4: std_logic_vector (15 downto 0);
	signal g4: std_logic_vector (15 downto 0);
	
	-- internal carry
	signal C_int: std_logic_vector (15 downto 0);
	
	component gen is
port (
			A : in std_logic;
			B : in std_logic;
			p : out std_logic;
			g : out std_logic
		);
end component ;

---------------------------------------------- generating carry --------------------------------

component car is
port(
			g_1 : in std_logic;
			p_1 : in std_logic;
			g_2 : in std_logic;
			p_2 : in std_logic;
			g0  : out std_logic;
			p0  : out std_logic
	 );
end component ;

----------------------------------------- COMPONENT GENERATION ---------------------------------

component xor_gate is
port(
		x1,x2 : in std_logic_vector(15 downto 0);
		output : out std_logic_vector (15 downto 0));
end component xor_gate;

component or_and_gate is
port(
		x1,x2 : in std_logic_vector(15 downto 0);
		x3: in std_logic;
		output : out std_logic_vector (15 downto 0));
end component or_and_gate;

component xor_gate2 is
port(
		x1 : in std_logic;
		x2 : in std_logic_vector(15 downto 0);
		output : out std_logic_vector(15 downto 0));
end component xor_gate2;

--------------------------------------------------------------------------------------

begin
 
		--generating stage-0 p,g signals
			stage_0:
					 for i in 0 to 15 generate 
							pm: gen port map (A => A(i) , B => B(i) , g => g_in(i) , p => p_in(i) );
					 end generate;
					 
		--stage-1 carry operations
		
		  g1(0) <= g_in(0);
		  p1(0) <= p_in(0);
		  
		--generating stage-1 p,g signals 
		
		  stage_1:
					 for i in 0 to 14 generate 
							--X: car port map ( g_in(i) ,  p_in(i) , g_in(i+1) , p_in(i+1) ,g1(i+1) , p1(i+1) );
							pm1: car port map (g_1 => g_in(i) , p_1 => p_in(i) , g_2 => g_in(i+1) , p_2 => p_in(i+1) , g0 => g1(i+1) , p0 => p1(i+1) );
	    			 end generate;
					 
		--stage-2 carry operations
		
		buffer_adder1:
						for i in 0 to 1 generate
							 g2(i) <= g1(i); 
							 p2(i) <= p1(i);
						end generate;
		stage_2:
					 for i in 0 to 13 generate
							pm2: car port map (g_1 => g1(i) , p_1 => p1(i) , g_2 => g1(i+2) , p_2 => p1(i+2) , g0 => g2(i+2) , p0 => p2(i+2));
					 end generate;
					 
		--stage-3 carry operations
		
		buffer_adder2:
						for i in 0 to 3 generate
							 g3(i) <= g2(i);
							 p3(i) <= p2(i);
						end generate;
		stage_3:
					 for i in 0 to 11 generate
							pm3: car port map (g_1 => g2(i) , p_1 => p2(i) , g_2 => g2(i+4) , p_2 => p2(i+4) , g0 => g3(i+4) , p0 => p3(i+4));
					 end generate;
					 
		--stage-4 carry operations
		
		buffer_adder3:
						for i in 0 to 7 generate
							 g4(i) <= g3(i);
							 p4(i) <= p3(i);
						end generate;
		stage_4:
					 for i in 0 to 7 generate
							pm4: car port map (g_1 => g3(i) , p_1 => p3(i) , g_2 => g3(i+8) , p_2 => p3(i+8) , g0 => g4(i+8) , p0 => p4(i+8));
					 end generate;
		
		--generation of carry 
		
		C_gen:
					 for i in 0 to 15 generate
						pm6: or_and_gate port map(x1(i) => g4(i) , x2(i) => p4(i) , x3 => C_in , output(i) => C_int(i));
					 end generate;
		
		C_out <= C_int(15);
		
		pm7: xor_gate2 port map (x1 => C_in , x2(0) => p_in(0), output(0) => Sum(0));
		
		
		adding:
				 for i in 1 to 15 generate
					 pm5: xor_gate port map(x1(i) =>C_int(i-1), x2(i) => p_in(i), output(i) => Sum(i));
				 end generate;
		
end arch;

library IEEE;
use ieee.std_logic_1164.all;
entity gen is
port (
			A : in std_logic;
			B : in std_logic;
			g : out std_logic;
			p : out std_logic
		);
end gen;
architecture arch of gen is
begin
p<= A XOR B;

g <= A AND B;

end arch;

library IEEE;
use ieee.std_logic_1164.all;
entity car is 
port(
			g_1 : in std_logic;
			p_1 : in std_logic;
			g_2 : in std_logic;
			p_2 : in std_logic;
			g0  : out std_logic;
			p0  : out std_logic
	 );
end car;
architecture arch of car is

begin
p0 <= p_1 AND p_2;
g0 <= (p_2 AND g_2) OR g_2;

end arch;

--------------------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
entity xor_gate is
port(
		x1,x2 : in std_logic_vector(15 downto 0);
		output : out std_logic_vector(15 downto 0));
end xor_gate;
architecture struct_xor of xor_gate is
begin
gen_xor:  
for i in 1 to 15 generate   
    output(i) <= x1(i) xor x2(i);
end generate gen_xor;  
end struct_xor;

--------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
entity or_and_gate is
port(
		x1,x2 : in std_logic_vector(15 downto 0);
		x3: in std_logic;
		output : out std_logic_vector(15 downto 0));
end or_and_gate;
architecture struct_or_and of or_and_gate is
begin
gen_or_and:  
for i in 0 to 15 generate   
    output(i) <= x1(i) or(x3 and x2(i));
end generate gen_or_and;  
end struct_or_and;

----------------------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
entity xor_gate2 is
port(
		x1 : in std_logic;
		x2 : in std_logic_vector(15 downto 0);
		output : out std_logic_vector(15 downto 0));
end xor_gate2;
architecture struct_xor2 of xor_gate2 is
begin
   
    output(0) <= x1 xor x2(0);
  
end struct_xor2;

-------------------------------------- THE END -------------------------------------------------