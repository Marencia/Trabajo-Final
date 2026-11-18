library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Global_types.all;

package Funciones_bitonic is

    constant N_DATOS : integer := 8; 
    constant N_BITS  : integer := 8;
	 
	 function N_ETAPAS(N_DATOS : integer) return natural;
	 function N_FASES (N_DATOS : integer) return natural;	
	 
end package Funciones_bitonic;

package body Funciones_bitonic is

		----------------- FUNCION PARA CALCULAR FASES ------------------
	
	function N_FASES (N_DATOS : integer) return natural is
		
		variable aux  : integer := N_DATOS;
		variable cont : natural := 0;
		
	begin
		L1: while aux > 1 loop
				aux  := aux / 2;
				cont := cont + 1;
			 end loop L1;
			 
		return cont;
			 
	end function N_FASES;
	
	----------------- FUNCION PARA CALCULAR ETAPAS -----------------
	
	function N_ETAPAS(N_DATOS : integer) return natural is
		
	begin
			  return (N_FASES(N_DATOS)*(N_FASES(N_DATOS)+1))/2;
			 
	end function N_ETAPAS;
	
	
end package body;
